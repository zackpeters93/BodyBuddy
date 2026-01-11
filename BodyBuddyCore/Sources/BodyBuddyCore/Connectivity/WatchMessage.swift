// WatchMessage.swift
// Shared message types for iPhone-Watch communication

import Foundation

/// Message types for WatchConnectivity communication
public enum WatchMessageType: String, Codable {
    case requestTodayWorkout = "request_today_workout"
    case todayWorkoutResponse = "today_workout_response"
    case completeSet = "complete_set"
    case setCompleted = "set_completed"
    case workoutStateUpdate = "workout_state_update"
    case startWorkout = "start_workout"
    case finishWorkout = "finish_workout"
    case syncUserProfile = "sync_user_profile"
}

/// Container for watch messages
public struct WatchMessage: Codable {
    public let type: WatchMessageType
    public let payload: Data?
    public let timestamp: Date

    public init(type: WatchMessageType, payload: Data? = nil) {
        self.type = type
        self.payload = payload
        self.timestamp = Date()
    }
}

/// Payload for today's workout request/response
public struct TodayWorkoutPayload: Codable {
    public let session: WorkoutSession?
    public let isInProgress: Bool
    public let userName: String

    public init(session: WorkoutSession?, isInProgress: Bool, userName: String) {
        self.session = session
        self.isInProgress = isInProgress
        self.userName = userName
    }
}

/// Payload for set completion requests
public struct SetCompletionPayload: Codable {
    public let sessionId: UUID
    public let exerciseIndex: Int
    public let reps: Int?
    public let weight: Double?

    public init(sessionId: UUID, exerciseIndex: Int, reps: Int? = nil, weight: Double? = nil) {
        self.sessionId = sessionId
        self.exerciseIndex = exerciseIndex
        self.reps = reps
        self.weight = weight
    }
}

/// Payload for workout state updates (iPhone → Watch)
public struct WorkoutStatePayload: Codable {
    public let session: WorkoutSession
    public let isInProgress: Bool

    public init(session: WorkoutSession, isInProgress: Bool) {
        self.session = session
        self.isInProgress = isInProgress
    }
}

// MARK: - Encoding/Decoding Helpers

public extension WatchMessage {
    /// Creates a message with an encoded payload
    static func create<T: Encodable>(type: WatchMessageType, payload: T) throws -> WatchMessage {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        return WatchMessage(type: type, payload: data)
    }

    /// Decodes the payload to a specific type
    func decodePayload<T: Decodable>(_ type: T.Type) throws -> T? {
        guard let data = payload else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }
}
