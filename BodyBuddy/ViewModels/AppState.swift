// AppState.swift
// Global app state management for BodyBuddy

import SwiftUI
import BodyBuddyCore

/// Main app state that manages navigation and data flow
@MainActor
final class AppState: ObservableObject {

    // MARK: - Published Properties

    /// Current navigation state
    @Published var navigationState: NavigationState = .loading

    /// User's profile (nil if not onboarded)
    @Published var userProfile: UserProfile?

    /// Current weekly workout plan
    @Published var weeklyPlan: WeeklyPlan?

    /// Today's workout session
    @Published var todaySession: WorkoutSession?

    /// Whether a workout is currently in progress
    @Published var isWorkoutInProgress: Bool = false

    /// Current error to display
    @Published var currentError: AppError?

    // MARK: - Dependencies

    private let dataStore: JSONDataStore

    // MARK: - Initialization

    init(dataStore: JSONDataStore = JSONDataStore()) {
        self.dataStore = dataStore
        loadInitialState()
    }

    // MARK: - Navigation State

    enum NavigationState {
        case loading
        case onboarding
        case main
    }

    // MARK: - Initial Load

    private func loadInitialState() {
        do {
            if let profile = try dataStore.loadProfile() {
                self.userProfile = profile
                self.weeklyPlan = try dataStore.loadWeeklyPlan()
                self.todaySession = weeklyPlan?.sessionForToday()

                // Check for in-progress workout
                if let currentId = try dataStore.loadCurrentSessionId(),
                   let plan = weeklyPlan,
                   let session = plan.sessions.first(where: { $0.id == currentId }) {
                    self.todaySession = session
                    self.isWorkoutInProgress = session.status == .inProgress
                }

                self.navigationState = .main
            } else {
                self.navigationState = .onboarding
            }
        } catch {
            self.currentError = AppError.loadFailed(error)
            self.navigationState = .onboarding
        }
    }

    // MARK: - Onboarding

    /// Completes onboarding with the given profile
    func completeOnboarding(with profile: UserProfile) {
        do {
            let plan = try dataStore.saveProfileAndGeneratePlan(profile)
            self.userProfile = profile
            self.weeklyPlan = plan
            self.todaySession = plan.sessionForToday()
            self.navigationState = .main
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    // MARK: - Workout Management

    /// Starts today's workout with optional check-in adjustment
    func startWorkout(with checkIn: PreWorkoutCheckIn? = nil) {
        guard var session = todaySession else { return }

        // Apply check-in adjustments if provided
        if let checkIn = checkIn {
            session = WorkoutEngine.adjust(session: session, with: checkIn)
        }

        session.start()

        do {
            try dataStore.saveCurrentSessionId(session.id)
            try dataStore.updateSessionInPlan(session)

            self.todaySession = session
            self.isWorkoutInProgress = true

            // Update the session in the weekly plan
            if var plan = weeklyPlan,
               let index = plan.sessions.firstIndex(where: { $0.id == session.id }) {
                plan.sessions[index] = session
                self.weeklyPlan = plan
            }
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    /// Completes a set for the current exercise
    func completeSet(forExerciseAt index: Int) {
        guard var session = todaySession else { return }

        session.completeSet(forExerciseAt: index)

        do {
            try dataStore.updateSessionInPlan(session)
            self.todaySession = session

            // Update weekly plan
            if var plan = weeklyPlan,
               let planIndex = plan.sessions.firstIndex(where: { $0.id == session.id }) {
                plan.sessions[planIndex] = session
                self.weeklyPlan = plan
            }
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    /// Finishes the current workout
    func finishWorkout() {
        guard var session = todaySession else { return }

        session.complete()

        do {
            try dataStore.saveCurrentSessionId(nil)
            try dataStore.updateSessionInPlan(session)

            self.todaySession = session
            self.isWorkoutInProgress = false

            // Update weekly plan
            if var plan = weeklyPlan,
               let index = plan.sessions.firstIndex(where: { $0.id == session.id }) {
                plan.sessions[index] = session
                self.weeklyPlan = plan
            }
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    /// Flags knee pain for the current exercise
    func flagKneePain(forExerciseAt index: Int) {
        guard var session = todaySession else { return }

        session.exercises[index].toggleKneePainFlag()

        do {
            try dataStore.updateSessionInPlan(session)
            self.todaySession = session
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    // MARK: - Profile Management

    /// Updates the user profile
    func updateProfile(_ profile: UserProfile) {
        do {
            try dataStore.saveProfile(profile)
            self.userProfile = profile
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    /// Regenerates the workout plan with current profile
    func regeneratePlan() {
        guard let profile = userProfile else { return }

        do {
            let plan = WorkoutEngine.generateWeek(for: profile)
            try dataStore.saveWeeklyPlan(plan)
            self.weeklyPlan = plan
            self.todaySession = plan.sessionForToday()
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    /// Creates an ad-hoc workout for today (used when user wants to work out on a rest day)
    func createAdHocWorkout() {
        guard let profile = userProfile else { return }

        // Generate a single workout session for today
        let session = WorkoutEngine.generateSession(for: profile, dayIndex: 0, date: Date())

        do {
            // Save the session
            try dataStore.saveSession(session)

            // Update the weekly plan to include this session
            if var plan = weeklyPlan {
                // Replace or add today's session
                if let index = plan.sessions.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
                    plan.sessions[index] = session
                } else {
                    plan.sessions.append(session)
                }
                try dataStore.saveWeeklyPlan(plan)
                self.weeklyPlan = plan
            }

            self.todaySession = session
        } catch {
            self.currentError = AppError.saveFailed(error)
        }
    }

    /// Resets all app data
    func resetApp() {
        do {
            try dataStore.resetApp()
            self.userProfile = nil
            self.weeklyPlan = nil
            self.todaySession = nil
            self.isWorkoutInProgress = false
            self.navigationState = .onboarding
        } catch {
            self.currentError = AppError.deleteFailed(error)
        }
    }

    // MARK: - Error Handling

    /// Dismisses the current error
    func dismissError() {
        currentError = nil
    }
}

// MARK: - App Errors

enum AppError: LocalizedError, Identifiable {
    case loadFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)

    var id: String {
        switch self {
        case .loadFailed: return "loadFailed"
        case .saveFailed: return "saveFailed"
        case .deleteFailed: return "deleteFailed"
        }
    }

    var errorDescription: String? {
        switch self {
        case .loadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        }
    }
}
