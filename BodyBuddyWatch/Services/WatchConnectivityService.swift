// WatchConnectivityService.swift
// Watch-side WatchConnectivity implementation

import WatchConnectivity
import BodyBuddyCore

@MainActor
final class WatchConnectivityService: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = WatchConnectivityService()

    // MARK: - Published Properties

    @Published private(set) var isReachable = false
    @Published var todayWorkout: TodayWorkoutPayload?

    // MARK: - Private Properties

    private var session: WCSession?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    private override init() {
        super.init()

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Public Methods

    /// Requests today's workout from iPhone
    func requestTodayWorkout() async throws {
        guard let session = session, session.isReachable else {
            throw WatchError.phoneNotReachable
        }

        let message = WatchMessage(type: .requestTodayWorkout)
        let messageData = try encoder.encode(message)

        let responseData = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            session.sendMessageData(messageData, replyHandler: { data in
                continuation.resume(returning: data)
            }, errorHandler: { error in
                continuation.resume(throwing: error)
            })
        }

        let response = try decoder.decode(WatchMessage.self, from: responseData)
        if let payload = try response.decodePayload(TodayWorkoutPayload.self) {
            self.todayWorkout = payload
        }
    }

    /// Sends set completion to iPhone
    func completeSet(sessionId: UUID, exerciseIndex: Int, reps: Int? = nil, weight: Double? = nil) async throws {
        guard let session = session, session.isReachable else {
            throw WatchError.phoneNotReachable
        }

        let payload = SetCompletionPayload(
            sessionId: sessionId,
            exerciseIndex: exerciseIndex,
            reps: reps,
            weight: weight
        )

        let message = try WatchMessage.create(type: .completeSet, payload: payload)
        let messageData = try encoder.encode(message)

        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            session.sendMessageData(messageData, replyHandler: { data in
                continuation.resume(returning: data)
            }, errorHandler: { error in
                continuation.resume(throwing: error)
            })
        }
    }

    /// Notifies iPhone to start workout
    func startWorkout() async throws {
        guard let session = session, session.isReachable else {
            throw WatchError.phoneNotReachable
        }

        let message = WatchMessage(type: .startWorkout)
        let messageData = try encoder.encode(message)

        session.sendMessageData(messageData, replyHandler: nil) { error in
            print("Failed to send start: \(error)")
        }
    }

    /// Notifies iPhone to finish workout
    func finishWorkout() async throws {
        guard let session = session, session.isReachable else {
            throw WatchError.phoneNotReachable
        }

        let message = WatchMessage(type: .finishWorkout)
        let messageData = try encoder.encode(message)

        session.sendMessageData(messageData, replyHandler: nil) { error in
            print("Failed to send finish: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable

            // Request workout when phone becomes reachable
            if session.isReachable {
                try? await self.requestTodayWorkout()
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessageData messageData: Data
    ) {
        do {
            let message = try decoder.decode(WatchMessage.self, from: messageData)

            Task { @MainActor in
                self.handleMessage(message)
            }
        } catch {
            print("Failed to decode: \(error)")
        }
    }

    @MainActor
    private func handleMessage(_ message: WatchMessage) {
        switch message.type {
        case .workoutStateUpdate:
            if let payload = try? message.decodePayload(WorkoutStatePayload.self) {
                self.todayWorkout = TodayWorkoutPayload(
                    session: payload.session,
                    isInProgress: payload.isInProgress,
                    userName: todayWorkout?.userName ?? ""
                )
            }

        case .todayWorkoutResponse:
            if let payload = try? message.decodePayload(TodayWorkoutPayload.self) {
                self.todayWorkout = payload
            }

        default:
            break
        }
    }
}

// MARK: - Errors

enum WatchError: LocalizedError {
    case phoneNotReachable

    var errorDescription: String? {
        switch self {
        case .phoneNotReachable:
            return "iPhone not reachable. Make sure it's nearby."
        }
    }
}
