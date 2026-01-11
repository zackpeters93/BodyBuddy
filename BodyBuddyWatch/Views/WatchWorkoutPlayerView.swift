// WatchWorkoutPlayerView.swift
// Active workout view for Apple Watch

import SwiftUI
import BodyBuddyCore

struct WatchWorkoutPlayerView: View {
    @EnvironmentObject var appState: WatchAppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $appState.currentExerciseIndex) {
            ForEach(Array((appState.todaySession?.exercises ?? []).enumerated()), id: \.element.id) { index, exercise in
                ExerciseCardView(
                    exercise: exercise,
                    exerciseNumber: index + 1,
                    totalExercises: appState.exerciseCount,
                    onCompleteSet: { appState.completeSet() },
                    isLast: index == appState.exerciseCount - 1,
                    onFinish: {
                        appState.finishWorkout()
                        dismiss()
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Exercise Card View

struct ExerciseCardView: View {
    let exercise: WorkoutExercise
    let exerciseNumber: Int
    let totalExercises: Int
    let onCompleteSet: () -> Void
    let isLast: Bool
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Exercise header
            Text("\(exerciseNumber)/\(totalExercises)")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Exercise name
            Text(exercise.exerciseName)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)

            // Set progress circles
            HStack(spacing: 6) {
                ForEach(0..<exercise.targetSets, id: \.self) { setIndex in
                    Circle()
                        .fill(setIndex < exercise.completedSets ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 14, height: 14)
                }
            }

            // Reps info
            Text(exercise.targetReps)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            // Action button
            actionButton
        }
        .padding()
    }

    @ViewBuilder
    private var actionButton: some View {
        if exercise.isCompleted {
            if isLast {
                Button {
                    onFinish()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("Swipe up for next")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        } else {
            Button {
                onCompleteSet()
            } label: {
                Text("Set \(exercise.completedSets + 1)")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }
}

#Preview {
    WatchWorkoutPlayerView()
        .environmentObject(WatchAppState())
}
