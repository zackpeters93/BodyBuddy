// WatchConnectivityManager.swift
// Manages communication between iPhone and Apple Watch

import WatchConnectivity
import BodyBuddyCore
import Combine

/// Manages WatchConnectivity on iOS
@MainActor
public final class WatchConnectivityManager: NSObject, ObservableObject {

    // MARK: - Singleton

    public static let shared = WatchConnectivityManager()

    // MARK: - Published Properties

    @Published public private(set) var isReachable = false
    @Published public private(set) var isPaired = false
    @Published public private(set) var isWatchAppInstalled = false

    // MARK: - Properties

    private var session: WCSession?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Closure called when watch requests today's workout
    public var onTodayWorkoutRequest: (() -> TodayWorkoutPayload)?

    /// Closure called when watch completes a set
    public var onSetCompletion: ((SetCompletionPayload) -> Void)?

    /// Closure called when watch starts workout
    public var onStartWorkout: (() -> Void)?

    /// Closure called when watch finishes workout
    public var onFinishWorkout: (() -> Void)?

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

    /// Sends workout state update to watch
    public func sendWorkoutState(_ session: WorkoutSession, isInProgress: Bool) {
        guard let wcSession = self.session, wcSession.isReachable else { return }

        let payload = WorkoutStatePayload(session: session, isInProgress: isInProgress)

        do {
            let message = try WatchMessage.create(type: .workoutStateUpdate, payload: payload)
            let messageData = try encoder.encode(message)

            wcSession.sendMessageData(messageData, replyHandler: nil) { error in
                print("Failed to send workout state: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to encode workout state: \(error)")
        }
    }

    /// Sends today's workout to watch (called when watch becomes reachable)
    public func sendTodayWorkout(_ payload: TodayWorkoutPayload) {
        guard let wcSession = session, wcSession.isReachable else { return }

        do {
            let message = try WatchMessage.create(type: .todayWorkoutResponse, payload: payload)
            let messageData = try encoder.encode(message)

            wcSession.sendMessageData(messageData, replyHandler: nil) { error in
                print("Failed to send today workout: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to encode today workout: \(error)")
        }
    }

    /// Syncs user profile to watch via application context
    public func syncUserProfile(_ profile: UserProfile) {
        guard let wcSession = session else { return }

        do {
            let data = try encoder.encode(profile)
            let message = try WatchMessage.create(type: .syncUserProfile, payload: profile)
            let messageData = try encoder.encode(message)

            // Use application context for non-urgent data that persists
            try wcSession.updateApplicationContext(["profile": messageData])
        } catch {
            print("Failed to sync profile: \(error)")
        }
    }

    /// Checks if watch communication is available
    public var isAvailable: Bool {
        WCSession.isSupported() && (session?.activationState == .activated)
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {

    nonisolated public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }
    }

    nonisolated public func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }

    nonisolated public func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate session for multi-watch support
        session.activate()
    }

    nonisolated public func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable

            // Send current workout when watch becomes reachable
            if session.isReachable, let payload = self.onTodayWorkoutRequest?() {
                self.sendTodayWorkout(payload)
            }
        }
    }

    // Handle messages with reply
    nonisolated public func session(
        _ session: WCSession,
        didReceiveMessageData messageData: Data,
        replyHandler: @escaping (Data) -> Void
    ) {
        do {
            let message = try decoder.decode(WatchMessage.self, from: messageData)

            Task { @MainActor in
                self.handleMessage(message, replyHandler: replyHandler)
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }

    // Handle messages without reply
    nonisolated public func session(
        _ session: WCSession,
        didReceiveMessageData messageData: Data
    ) {
        do {
            let message = try decoder.decode(WatchMessage.self, from: messageData)

            Task { @MainActor in
                self.handleMessage(message, replyHandler: nil)
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }

    @MainActor
    private func handleMessage(_ message: WatchMessage, replyHandler: ((Data) -> Void)?) {
        switch message.type {
        case .requestTodayWorkout:
            if let payload = onTodayWorkoutRequest?() {
                do {
                    let response = try WatchMessage.create(type: .todayWorkoutResponse, payload: payload)
                    let responseData = try encoder.encode(response)
                    replyHandler?(responseData)
                } catch {
                    print("Failed to encode response: \(error)")
                }
            }

        case .completeSet:
            if let payload = try? message.decodePayload(SetCompletionPayload.self) {
                onSetCompletion?(payload)

                // Send acknowledgment
                do {
                    let ack = WatchMessage(type: .setCompleted)
                    let ackData = try encoder.encode(ack)
                    replyHandler?(ackData)
                } catch {
                    print("Failed to send ack: \(error)")
                }
            }

        case .startWorkout:
            onStartWorkout?()

        case .finishWorkout:
            onFinishWorkout?()

        default:
            break
        }
    }
}
