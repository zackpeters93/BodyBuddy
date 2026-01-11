// HealthKitManager.swift
// HealthKit integration for saving workouts and reading user health data

import HealthKit
import BodyBuddyCore

/// Manages all HealthKit interactions for the app
@MainActor
public final class HealthKitManager: ObservableObject {

    // MARK: - Singleton

    public static let shared = HealthKitManager()

    // MARK: - Properties

    private let healthStore: HKHealthStore?
    @Published public private(set) var isAuthorized = false
    @Published public private(set) var authorizationError: Error?

    /// Cached user metrics for calorie calculation
    @Published public private(set) var userWeight: Double?
    @Published public private(set) var userAge: Int?

    // MARK: - Types to Read

    private var typesToRead: Set<HKObjectType> {
        var types = Set<HKObjectType>()

        // Body measurements for calorie calculation
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(bodyMass)
        }
        if let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) {
            types.insert(dateOfBirth)
        }
        if let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) {
            types.insert(biologicalSex)
        }
        if let height = HKObjectType.quantityType(forIdentifier: .height) {
            types.insert(height)
        }

        return types
    }

    // MARK: - Types to Write

    private var typesToWrite: Set<HKSampleType> {
        var types = Set<HKSampleType>()

        // Workout
        types.insert(HKObjectType.workoutType())

        // Active energy burned (for Activity rings)
        if let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(activeEnergy)
        }

        return types
    }

    // MARK: - Initialization

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        } else {
            self.healthStore = nil
        }
    }

    // MARK: - Availability

    /// Checks if HealthKit is available on this device
    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    /// Requests authorization for reading and writing health data
    public func requestAuthorization() async throws {
        guard let healthStore = healthStore else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typesToRead
        )

        // Check if we have write permission for workouts
        let workoutStatus = healthStore.authorizationStatus(for: .workoutType())
        isAuthorized = workoutStatus == .sharingAuthorized

        // Fetch user metrics if authorized
        if isAuthorized {
            await fetchUserMetrics()
        }
    }

    /// Checks if authorization has been requested (not necessarily granted)
    public var authorizationRequested: Bool {
        guard let healthStore = healthStore else { return false }
        return healthStore.authorizationStatus(for: .workoutType()) != .notDetermined
    }

    // MARK: - Reading User Data

    /// Fetches and caches user metrics for calorie calculation
    private func fetchUserMetrics() async {
        do {
            userWeight = try await fetchWeight()
            userAge = try fetchAge()
        } catch {
            // Non-critical - we'll use defaults if this fails
            print("Failed to fetch user metrics: \(error)")
        }
    }

    /// Fetches the user's most recent weight in kg
    public func fetchWeight() async throws -> Double? {
        guard let healthStore = healthStore,
              let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return nil
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let weightInKg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: weightInKg)
            }

            healthStore.execute(query)
        }
    }

    /// Fetches the user's age in years
    public func fetchAge() throws -> Int? {
        guard let healthStore = healthStore else { return nil }

        let dateOfBirth = try healthStore.dateOfBirthComponents()
        guard let birthDate = dateOfBirth.date else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        return ageComponents.year
    }

    /// Fetches the user's biological sex
    public func fetchBiologicalSex() throws -> HKBiologicalSex? {
        guard let healthStore = healthStore else { return nil }
        let biologicalSex = try healthStore.biologicalSex()
        return biologicalSex.biologicalSex
    }

    // MARK: - Saving Workouts

    /// Saves a completed workout session to HealthKit
    public func saveWorkout(_ session: WorkoutSession) async throws {
        guard let healthStore = healthStore else {
            throw HealthKitError.notAvailable
        }

        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }

        guard session.status == .completed,
              let startDate = session.startedAt,
              let endDate = session.completedAt else {
            throw HealthKitError.invalidSession
        }

        // Calculate duration and calories
        let duration = endDate.timeIntervalSince(startDate)
        let metrics = CalorieEstimator.UserMetrics(
            weightKg: userWeight ?? 70.0,
            age: userAge ?? 35
        )
        let calories = CalorieEstimator.estimate(session: session, metrics: metrics)

        // Create workout configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        // Build workout using the modern HKWorkoutBuilder API
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: nil)

        try await builder.beginCollection(at: startDate)

        // Add energy burned sample
        if let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let energySample = HKQuantitySample(
                type: activeEnergyType,
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
                start: startDate,
                end: endDate
            )
            try await builder.addSamples([energySample])
        }

        try await builder.endCollection(at: endDate)

        // Add metadata
        let metadata = buildMetadata(for: session)

        // Finish and save the workout
        try await builder.finishWorkout()
    }

    /// Builds metadata dictionary for the workout
    private func buildMetadata(for session: WorkoutSession) -> [String: Any] {
        var metadata: [String: Any] = [
            HKMetadataKeyIndoorWorkout: true,
            "BodyBuddySessionId": session.id.uuidString,
            "ExerciseCount": session.exercises.count,
            "TotalSets": session.exercises.reduce(0) { $0 + $1.completedSets }
        ]

        // Add muscle groups worked
        let muscleGroups = Set(session.exercises.map { $0.primaryMuscle.displayName })
        metadata["MuscleGroups"] = Array(muscleGroups).joined(separator: ", ")

        return metadata
    }
}

// MARK: - Errors

public enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case invalidSession
    case saveFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .invalidSession:
            return "Cannot save incomplete workout session"
        case .saveFailed(let error):
            return "Failed to save workout: \(error.localizedDescription)"
        }
    }
}
