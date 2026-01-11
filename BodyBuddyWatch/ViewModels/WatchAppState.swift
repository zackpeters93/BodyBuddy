// WatchAppState.swift
// Main state management for watchOS app

import SwiftUI
import Combine
import BodyBuddyCore

@MainActor
final class WatchAppState: ObservableObject {

    // MARK: - Published Properties

    @Published var todaySession: WorkoutSession?
    @Published var isWorkoutInProgress = false
    @Published var userName = ""
    @Published var currentExerciseIndex = 0
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isPhoneReachable = false

    // MARK: - Private Properties

    private let connectivity = WatchConnectivityService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var currentExercise: WorkoutExercise? {
        todaySession?.exercises[safe: currentExerciseIndex]
    }

    var exerciseCount: Int {
        todaySession?.exercises.count ?? 0
    }

    var isLastExercise: Bool {
        currentExerciseIndex >= exerciseCount - 1
    }

    var progress: Double {
        todaySession?.progress ?? 0
    }

    // MARK: - Initialization

    init() {
        setupObservers()
    }

    private func setupObservers() {
        // Observe connectivity changes
        connectivity.$isReachable
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPhoneReachable)

        // Observe workout updates from iPhone
        connectivity.$todayWorkout
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                guard let self = self, let payload = payload else { return }
                self.todaySession = payload.session
                self.isWorkoutInProgress = payload.isInProgress
                self.userName = payload.userName
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    /// Requests today's workout from iPhone
    func refreshWorkout() {
        isLoading = true
        error = nil

        Task {
            do {
                try await connectivity.requestTodayWorkout()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }

    /// Starts the workout (notifies iPhone)
    func startWorkout() {
        Task {
            do {
                try await connectivity.startWorkout()
                isWorkoutInProgress = true
                currentExerciseIndex = 0
            } catch {
                self.error = error
            }
        }
    }

    /// Completes the current set
    func completeSet() {
        guard let session = todaySession else { return }

        Task {
            do {
                try await connectivity.completeSet(
                    sessionId: session.id,
                    exerciseIndex: currentExerciseIndex
                )

                // Optimistic update - the real update will come from iPhone
                if var exercise = todaySession?.exercises[currentExerciseIndex] {
                    exercise.completeSet()
                    todaySession?.exercises[currentExerciseIndex] = exercise
                }
            } catch {
                self.error = error
            }
        }
    }

    /// Navigates to the next exercise
    func nextExercise() {
        guard !isLastExercise else { return }
        currentExerciseIndex += 1
    }

    /// Navigates to the previous exercise
    func previousExercise() {
        guard currentExerciseIndex > 0 else { return }
        currentExerciseIndex -= 1
    }

    /// Finishes the workout (notifies iPhone)
    func finishWorkout() {
        Task {
            do {
                try await connectivity.finishWorkout()
                isWorkoutInProgress = false
                currentExerciseIndex = 0
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
