// JSONDataStore.swift
// JSON-based data persistence implementation for BodyBuddy

import Foundation

/// JSON file-based implementation of DataStore
public final class JSONDataStore: DataStore {

    // MARK: - File Names

    private enum FileName {
        static let profile = "profile.json"
        static let weeklyPlan = "weekly_plan.json"
        static let sessions = "sessions.json"
        static let appState = "app_state.json"
    }

    // MARK: - Properties

    private let fileManager: FileManager
    private let baseDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /// Creates a new JSONDataStore
    /// - Parameter directory: Optional custom directory. Defaults to app's documents directory.
    public init(directory: URL? = nil) {
        self.fileManager = FileManager.default
        self.baseDirectory = directory ?? Self.defaultDirectory()

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        // Ensure directory exists
        try? createDirectoryIfNeeded()
    }

    /// Returns the default storage directory
    private static func defaultDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("BodyBuddy", isDirectory: true)
    }

    // MARK: - User Profile

    public func loadProfile() throws -> UserProfile? {
        let url = fileURL(for: FileName.profile)
        return try loadJSON(from: url)
    }

    public func saveProfile(_ profile: UserProfile) throws {
        let url = fileURL(for: FileName.profile)
        try saveJSON(profile, to: url)
    }

    public func deleteProfile() throws {
        let url = fileURL(for: FileName.profile)
        try deleteFile(at: url)
    }

    public func hasProfile() -> Bool {
        let url = fileURL(for: FileName.profile)
        return fileManager.fileExists(atPath: url.path)
    }

    // MARK: - Weekly Plan

    public func loadWeeklyPlan() throws -> WeeklyPlan? {
        let url = fileURL(for: FileName.weeklyPlan)
        return try loadJSON(from: url)
    }

    public func saveWeeklyPlan(_ plan: WeeklyPlan) throws {
        let url = fileURL(for: FileName.weeklyPlan)
        try saveJSON(plan, to: url)
    }

    public func deleteWeeklyPlan() throws {
        let url = fileURL(for: FileName.weeklyPlan)
        try deleteFile(at: url)
    }

    // MARK: - Workout Sessions

    public func loadSession(id: UUID) throws -> WorkoutSession? {
        let sessions = try loadAllSessions()
        return sessions.first { $0.id == id }
    }

    public func saveSession(_ session: WorkoutSession) throws {
        var sessions = try loadAllSessions()

        // Update existing or append new
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }

        let url = fileURL(for: FileName.sessions)
        try saveJSON(sessions, to: url)
    }

    public func loadAllSessions() throws -> [WorkoutSession] {
        let url = fileURL(for: FileName.sessions)
        return try loadJSON(from: url) ?? []
    }

    // MARK: - App State

    public func loadCurrentSessionId() throws -> UUID? {
        let url = fileURL(for: FileName.appState)
        let state: AppState? = try loadJSON(from: url)
        return state?.currentSessionId
    }

    public func saveCurrentSessionId(_ id: UUID?) throws {
        let state = AppState(currentSessionId: id)
        let url = fileURL(for: FileName.appState)
        try saveJSON(state, to: url)
    }

    // MARK: - Reset

    public func deleteAllData() throws {
        try deleteProfile()
        try deleteWeeklyPlan()

        let sessionsURL = fileURL(for: FileName.sessions)
        try deleteFile(at: sessionsURL)

        let stateURL = fileURL(for: FileName.appState)
        try deleteFile(at: stateURL)
    }

    // MARK: - Private Helpers

    private func fileURL(for fileName: String) -> URL {
        baseDirectory.appendingPathComponent(fileName)
    }

    private func createDirectoryIfNeeded() throws {
        guard !fileManager.fileExists(atPath: baseDirectory.path) else { return }

        do {
            try fileManager.createDirectory(
                at: baseDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw DataStoreError.directoryCreationFailed(error)
        }
    }

    private func loadJSON<T: Decodable>(from url: URL) throws -> T? {
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw DataStoreError.decodingFailed(error)
        } catch {
            throw DataStoreError.readFailed(error)
        }
    }

    private func saveJSON<T: Encodable>(_ value: T, to url: URL) throws {
        try createDirectoryIfNeeded()

        do {
            let data = try encoder.encode(value)

            // Atomic write: write to temp file first, then rename
            let tempURL = url.appendingPathExtension("tmp")

            try data.write(to: tempURL, options: .atomic)

            // Remove existing file if present
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }

            // Rename temp to final
            try fileManager.moveItem(at: tempURL, to: url)

        } catch let error as EncodingError {
            throw DataStoreError.encodingFailed(error)
        } catch {
            throw DataStoreError.writeFailed(error)
        }
    }

    private func deleteFile(at url: URL) throws {
        guard fileManager.fileExists(atPath: url.path) else { return }

        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw DataStoreError.deleteFailed(error)
        }
    }
}

// MARK: - App State Model

/// Internal model for persisting app state
private struct AppState: Codable {
    let currentSessionId: UUID?
}

// MARK: - Convenience Extensions

public extension JSONDataStore {

    /// Saves both the profile and generates a new weekly plan
    func saveProfileAndGeneratePlan(_ profile: UserProfile) throws -> WeeklyPlan {
        try saveProfile(profile)

        let plan = WorkoutEngine.generateWeek(for: profile)
        try saveWeeklyPlan(plan)

        return plan
    }

    /// Updates a session within the current weekly plan
    func updateSessionInPlan(_ session: WorkoutSession) throws {
        guard var plan = try loadWeeklyPlan() else { return }

        if let index = plan.sessions.firstIndex(where: { $0.id == session.id }) {
            plan.sessions[index] = session
            try saveWeeklyPlan(plan)
        }

        // Also save to session history
        try saveSession(session)
    }

    /// Clears all data and returns to initial state (for app reset)
    func resetApp() throws {
        try deleteAllData()
    }

    /// Returns storage directory size in bytes
    func storageSize() -> Int64 {
        guard let enumerator = fileManager.enumerator(
            at: baseDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        var totalSize: Int64 = 0

        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = resourceValues.fileSize else {
                continue
            }
            totalSize += Int64(fileSize)
        }

        return totalSize
    }

    /// Returns storage directory path for debugging
    var storagePath: String {
        baseDirectory.path
    }
}
