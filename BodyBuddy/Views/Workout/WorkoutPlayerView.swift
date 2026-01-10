// WorkoutPlayerView.swift
// Full-screen workout player for tracking exercise sets

import SwiftUI
import BodyBuddyCore

struct WorkoutPlayerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    let session: WorkoutSession
    @State private var currentExerciseIndex: Int = 0
    @State private var showingExitConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress header
                WorkoutProgressHeader(
                    currentIndex: currentExerciseIndex,
                    totalCount: session.exercises.count,
                    progress: session.progress
                )

                // Exercise content
                if let exercise = currentExercise {
                    ExerciseCard(
                        exercise: exercise,
                        onCompleteSet: completeSet,
                        onFlagKneePain: flagKneePain
                    )
                }

                Spacer()

                // Navigation footer
                WorkoutNavigationFooter(
                    currentIndex: currentExerciseIndex,
                    totalCount: session.exercises.count,
                    isCurrentComplete: currentExercise?.isCompleted ?? false,
                    onPrevious: previousExercise,
                    onNext: nextExercise,
                    onFinish: finishWorkout
                )
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") {
                        showingExitConfirmation = true
                    }
                }
            }
            .confirmationDialog(
                "Exit Workout?",
                isPresented: $showingExitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Save & Exit") {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your progress will be saved and you can resume later.")
            }
            .onAppear {
                // Start at first incomplete exercise
                if let index = session.currentExerciseIndex {
                    currentExerciseIndex = index
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var currentExercise: WorkoutExercise? {
        appState.todaySession?.exercises[safe: currentExerciseIndex]
    }

    // MARK: - Actions

    private func completeSet() {
        appState.completeSet(forExerciseAt: currentExerciseIndex)
    }

    private func flagKneePain() {
        appState.flagKneePain(forExerciseAt: currentExerciseIndex)
    }

    private func previousExercise() {
        guard currentExerciseIndex > 0 else { return }
        withAnimation {
            currentExerciseIndex -= 1
        }
    }

    private func nextExercise() {
        guard currentExerciseIndex < session.exercises.count - 1 else { return }
        withAnimation {
            currentExerciseIndex += 1
        }
    }

    private func finishWorkout() {
        appState.finishWorkout()
        dismiss()
    }
}

// MARK: - Progress Header

struct WorkoutProgressHeader: View {
    let currentIndex: Int
    let totalCount: Int
    let progress: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Exercise \(currentIndex + 1) of \(totalCount)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            ProgressView(value: progress)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: WorkoutExercise
    let onCompleteSet: () -> Void
    let onFlagKneePain: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Exercise info
                VStack(spacing: 8) {
                    Text(exercise.exerciseName)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 16) {
                        Label(exercise.primaryMuscle.displayName, systemImage: "figure.strengthtraining.traditional")
                        Label(exercise.kneeLoad.displayName, systemImage: "knee")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }

                // Target info
                HStack(spacing: 32) {
                    VStack {
                        Text("\(exercise.targetSets)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        Text(exercise.targetReps)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let weight = exercise.targetWeight {
                        VStack {
                            Text("\(Int(weight))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("lbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)

                // Set tracking
                VStack(spacing: 12) {
                    Text("Track Your Sets")
                        .font(.headline)

                    HStack(spacing: 16) {
                        ForEach(0..<exercise.targetSets, id: \.self) { setIndex in
                            SetIndicator(
                                setNumber: setIndex + 1,
                                isCompleted: setIndex < exercise.completedSets,
                                isCurrent: setIndex == exercise.completedSets
                            )
                        }
                    }

                    if !exercise.isCompleted {
                        Button(action: onCompleteSet) {
                            Label("Complete Set \(exercise.currentSetNumber)", systemImage: "checkmark.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("All sets completed!")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }

                // Knee pain flag
                Button(action: onFlagKneePain) {
                    HStack {
                        Image(systemName: exercise.kneePainFlagged ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
                            .foregroundColor(exercise.kneePainFlagged ? .orange : .gray)

                        Text(exercise.kneePainFlagged ? "Knee pain flagged" : "Flag knee pain")
                            .foregroundColor(exercise.kneePainFlagged ? .orange : .secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(exercise.kneePainFlagged ? Color.orange : Color.gray.opacity(0.3))
                    )
                }
            }
            .padding()
        }
    }
}

struct SetIndicator: View {
    let setNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green : (isCurrent ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)))
                .frame(width: 50, height: 50)

            if isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            } else {
                Text("\(setNumber)")
                    .font(.headline)
                    .foregroundColor(isCurrent ? .blue : .gray)
            }
        }
        .overlay(
            Circle()
                .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 3)
        )
    }
}

// MARK: - Navigation Footer

struct WorkoutNavigationFooter: View {
    let currentIndex: Int
    let totalCount: Int
    let isCurrentComplete: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onFinish: () -> Void

    private var isFirstExercise: Bool { currentIndex == 0 }
    private var isLastExercise: Bool { currentIndex == totalCount - 1 }

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .frame(width: 60, height: 44)
            }
            .disabled(isFirstExercise)

            Spacer()

            if isLastExercise && isCurrentComplete {
                Button(action: onFinish) {
                    Text("Finish Workout")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .frame(width: 60, height: 44)
            }
            .disabled(isLastExercise)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
    }
}

// MARK: - Preview

#Preview {
    let session = WorkoutSession(
        date: Date(),
        dayIndex: 1,
        exercises: [
            WorkoutExercise(
                exerciseId: "pushup",
                exerciseName: "Push-Up",
                primaryMuscle: .chest,
                kneeLoad: .low,
                targetSets: 3,
                targetReps: "10-15"
            ),
            WorkoutExercise(
                exerciseId: "row",
                exerciseName: "Dumbbell Row",
                primaryMuscle: .back,
                kneeLoad: .low,
                targetSets: 3,
                targetReps: "8-12"
            )
        ]
    )

    WorkoutPlayerView(session: session)
        .environmentObject(AppState())
}
