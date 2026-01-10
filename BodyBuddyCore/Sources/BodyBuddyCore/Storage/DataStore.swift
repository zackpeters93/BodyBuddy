// DataStore.swift
// Data persistence protocol for BodyBuddy

import Foundation

/// Errors that can occur during data storage operations
public enum DataStoreError: Error, LocalizedError {
    case fileNotFound
    case encodingFailed(Error)
    case decodingFailed(Error)
    case writeFailed(Error)
    case readFailed(Error)
    case directoryCreationFailed(Error)
    case deleteFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The requested file was not found"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .writeFailed(let error):
            return "Failed to write data: \(error.localizedDescription)"
        case .readFailed(let error):
            return "Failed to read data: \(error.localizedDescription)"
        case .directoryCreationFailed(let error):
            return "Failed to create directory: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        }
    }
}

/// Protocol defining data persistence operations
public protocol DataStore {

    // MARK: - User Profile

    /// Loads the user profile from storage
    /// - Returns: The saved UserProfile, or nil if none exists
    func loadProfile() throws -> UserProfile?

    /// Saves the user profile to storage
    /// - Parameter profile: The profile to save
    func saveProfile(_ profile: UserProfile) throws

    /// Deletes the user profile from storage
    func deleteProfile() throws

    /// Returns true if a user profile exists in storage
    func hasProfile() -> Bool

    // MARK: - Weekly Plan

    /// Loads the current weekly plan from storage
    /// - Returns: The saved WeeklyPlan, or nil if none exists
    func loadWeeklyPlan() throws -> WeeklyPlan?

    /// Saves the weekly plan to storage
    /// - Parameter plan: The plan to save
    func saveWeeklyPlan(_ plan: WeeklyPlan) throws

    /// Deletes the weekly plan from storage
    func deleteWeeklyPlan() throws

    // MARK: - Workout Sessions

    /// Loads a specific workout session by ID
    /// - Parameter id: The session ID
    /// - Returns: The session, or nil if not found
    func loadSession(id: UUID) throws -> WorkoutSession?

    /// Saves a workout session (updates if exists, creates if new)
    /// - Parameter session: The session to save
    func saveSession(_ session: WorkoutSession) throws

    /// Loads all workout sessions (for history)
    /// - Returns: Array of all saved sessions
    func loadAllSessions() throws -> [WorkoutSession]

    // MARK: - App State

    /// Loads the current in-progress session ID, if any
    func loadCurrentSessionId() throws -> UUID?

    /// Saves the current in-progress session ID
    func saveCurrentSessionId(_ id: UUID?) throws

    // MARK: - Reset

    /// Deletes all stored data (profile, plans, sessions)
    func deleteAllData() throws
}

// MARK: - Default Implementations

public extension DataStore {

    /// Convenience method to check if onboarding is complete
    func isOnboardingComplete() -> Bool {
        hasProfile()
    }

    /// Convenience method to load today's session from the weekly plan
    func loadTodaySession() throws -> WorkoutSession? {
        guard let plan = try loadWeeklyPlan() else { return nil }
        return plan.sessionForToday()
    }
}
