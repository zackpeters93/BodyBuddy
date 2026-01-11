// WatchTodayView.swift
// Shows today's workout on Apple Watch

import SwiftUI
import BodyBuddyCore

struct WatchTodayView: View {
    @EnvironmentObject var appState: WatchAppState

    var body: some View {
        NavigationStack {
            Group {
                if appState.isLoading {
                    loadingView
                } else if !appState.isPhoneReachable {
                    notReachableView
                } else if let session = appState.todaySession {
                    workoutPreview(session)
                } else {
                    restDayView
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appState.refreshWorkout()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(appState.isLoading)
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Not Reachable View

    private var notReachableView: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone.slash")
                .font(.title)
                .foregroundColor(.orange)

            Text("iPhone Not Reachable")
                .font(.headline)

            Text("Make sure your iPhone is nearby")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                appState.refreshWorkout()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Workout Preview

    private func workoutPreview(_ session: WorkoutSession) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                // Status
                if session.status == .completed {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Text("\(session.exercises.count) exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Exercise list
                ForEach(session.exercises.prefix(4)) { exercise in
                    HStack {
                        Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(exercise.isCompleted ? .green : .gray)
                            .font(.caption2)

                        Text(exercise.exerciseName)
                            .font(.caption2)
                            .lineLimit(1)

                        Spacer()

                        Text("\(exercise.targetSets)×")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                if session.exercises.count > 4 {
                    Text("+\(session.exercises.count - 4) more")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Start button
                if session.status != .completed && !appState.isWorkoutInProgress {
                    Button {
                        appState.startWorkout()
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }

    // MARK: - Rest Day View

    private var restDayView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bed.double.fill")
                .font(.title)
                .foregroundColor(.blue.opacity(0.6))

            Text("Rest Day")
                .font(.headline)

            Text("Recovery is important!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    WatchTodayView()
        .environmentObject(WatchAppState())
}
