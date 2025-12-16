// UserProfile.swift
// User profile model for BodyBuddy

import Foundation

/// Represents the user's fitness profile with goals, constraints, and preferences
public struct UserProfile: Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var primaryGoal: PrimaryGoal
    public var kneeProfile: KneeProfile
    public var schedule: WorkoutSchedule
    public var equipment: Set<EquipmentType>
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String = "",
        primaryGoal: PrimaryGoal = .generalFitness,
        kneeProfile: KneeProfile = .healthy,
        schedule: WorkoutSchedule = WorkoutSchedule(),
        equipment: Set<EquipmentType> = [.bodyweight],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.primaryGoal = primaryGoal
        self.kneeProfile = kneeProfile
        self.schedule = schedule
        self.equipment = equipment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Returns true if the user's goal emphasizes arm training
    public var isArmFocused: Bool {
        primaryGoal == .arms
    }

    /// Returns the number of arm exercises per session based on goal
    public var armExercisesPerSession: Int {
        isArmFocused ? 2 : 1
    }

    /// Returns true if the profile has been fully configured
    public var isComplete: Bool {
        !name.isEmpty || primaryGoal != .generalFitness
    }
}

// MARK: - Workout Schedule

/// Represents the user's workout schedule preferences
public struct WorkoutSchedule: Codable, Equatable {
    /// Number of workout days per week (1-3)
    public var daysPerWeek: Int

    /// Target minutes per workout session
    public var minutesPerSession: Int

    public init(
        daysPerWeek: Int = 3,
        minutesPerSession: Int = 30
    ) {
        self.daysPerWeek = min(max(daysPerWeek, 1), 3)
        self.minutesPerSession = minutesPerSession
    }

    /// Valid options for days per week
    public static let daysPerWeekOptions = [1, 2, 3]

    /// Valid options for minutes per session
    public static let minutesPerSessionOptions = [20, 30, 45]

    /// Estimated number of exercises based on session duration
    public var estimatedExerciseCount: Int {
        switch minutesPerSession {
        case 20: return 3
        case 30: return 4
        case 45: return 5
        default: return 4
        }
    }
}

// MARK: - Codable Conformance for Set<EquipmentType>

extension UserProfile {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case primaryGoal
        case kneeProfile
        case schedule
        case equipment
        case createdAt
        case updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        primaryGoal = try container.decode(PrimaryGoal.self, forKey: .primaryGoal)
        kneeProfile = try container.decode(KneeProfile.self, forKey: .kneeProfile)
        schedule = try container.decode(WorkoutSchedule.self, forKey: .schedule)
        let equipmentArray = try container.decode([EquipmentType].self, forKey: .equipment)
        equipment = Set(equipmentArray)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(primaryGoal, forKey: .primaryGoal)
        try container.encode(kneeProfile, forKey: .kneeProfile)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(Array(equipment), forKey: .equipment)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
