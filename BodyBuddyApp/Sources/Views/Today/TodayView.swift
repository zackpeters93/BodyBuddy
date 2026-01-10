// TodayView.swift
// Main dashboard showing today's workout and weekly overview

import SwiftUI
import BodyBuddyCore

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingCheckIn = false
    @State private var showingWorkoutPlayer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Overview
                    WeeklyOverviewCard(weeklyPlan: appState.weeklyPlan)

                    // Today's Workout Card
                    if let session = appState.todaySession {
                        TodayWorkoutCard(
                            session: session,
                            isInProgress: appState.isWorkoutInProgress,
                            onStartTap: { showingCheckIn = true },
                            onResumeTap: { showingWorkoutPlayer = true }
                        )
                    } else {
                        RestDayCard()
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showingCheckIn) {
                CheckInSheet { checkIn in
                    appState.startWorkout(with: checkIn)
                    showingCheckIn = false
                    showingWorkoutPlayer = true
                }
            }
            .fullScreenCover(isPresented: $showingWorkoutPlayer) {
                if let session = appState.todaySession {
                    WorkoutPlayerView(session: session)
                }
            }
        }
    }
}

// MARK: - Weekly Overview Card

struct WeeklyOverviewCard: View {
    let weeklyPlan: WeeklyPlan?

    private let weekdays = ["M", "T", "W", "T", "F"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    let session = weeklyPlan?.sessions[safe: index]
                    DayIndicator(
                        label: weekdays[index],
                        status: dayStatus(for: session, dayIndex: index)
                    )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }

    private func dayStatus(for session: WorkoutSession?, dayIndex: Int) -> DayStatus {
        guard let session = session else { return .rest }

        if session.dayType == .rest {
            return .rest
        }

        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(session.date)

        switch session.status {
        case .completed:
            return .completed
        case .inProgress:
            return .inProgress
        case .planned:
            return isToday ? .today : .planned
        case .skipped:
            return .rest
        }
    }
}

enum DayStatus {
    case completed, today, planned, rest, inProgress
}

struct DayIndicator: View {
    let label: String
    let status: DayStatus

    private var backgroundColor: Color {
        switch status {
        case .completed: return .green
        case .today, .inProgress: return .blue
        case .planned: return .gray.opacity(0.3)
        case .rest: return .clear
        }
    }

    private var icon: String? {
        switch status {
        case .completed: return "checkmark"
        case .inProgress: return "play.fill"
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)

                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.caption)
                } else if status == .today {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Today Workout Card

struct TodayWorkoutCard: View {
    let session: WorkoutSession
    let isInProgress: Bool
    let onStartTap: () -> Void
    let onResumeTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isInProgress ? "Workout In Progress" : "Today's Workout")
                        .font(.headline)

                    Text("\(session.exercises.count) exercises")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if session.status == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title)
                }
            }

            // Progress bar if in progress
            if isInProgress {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: session.progress)
                        .tint(.blue)

                    Text("\(Int(session.progress * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Exercise preview
            VStack(alignment: .leading, spacing: 8) {
                ForEach(session.exercises.prefix(3)) { exercise in
                    HStack {
                        Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(exercise.isCompleted ? .green : .gray)

                        Text(exercise.exerciseName)
                            .font(.subheadline)

                        Spacer()

                        Text("\(exercise.targetSets) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if session.exercises.count > 3 {
                    Text("+ \(session.exercises.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Action button
            if session.status != .completed {
                Button(action: isInProgress ? onResumeTap : onStartTap) {
                    Text(isInProgress ? "Resume Workout" : "Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

// MARK: - Rest Day Card

struct RestDayCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bed.double.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue.opacity(0.5))

            Text("Rest Day")
                .font(.title2)
                .fontWeight(.bold)

            Text("Recovery is just as important as training. Take it easy today!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

// MARK: - Check-In Sheet

struct CheckInSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var energyLevel: Double = 3
    @State private var kneePainLevel: Double = 0

    let onStart: (PreWorkoutCheckIn?) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("How are you feeling?")
                    .font(.title2)
                    .fontWeight(.bold)

                // Energy Level
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Energy Level")
                            .font(.headline)

                        Spacer()

                        Text(energyDescription)
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $energyLevel, in: 1...5, step: 1)
                        .tint(.blue)

                    HStack {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("High")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Knee Pain
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Knee Pain")
                            .font(.headline)

                        Spacer()

                        Text(kneePainDescription)
                            .foregroundColor(kneePainLevel > 0 ? .orange : .secondary)
                    }

                    Slider(value: $kneePainLevel, in: 0...2, step: 1)
                        .tint(kneePainLevel > 0 ? .orange : .blue)

                    HStack {
                        Text("None")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("Significant")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Adjustment notice
                if shouldAdjust {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)

                        Text("Sets will be reduced by 1 based on your check-in")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        let checkIn = PreWorkoutCheckIn(
                            energyLevel: Int(energyLevel),
                            kneePainLevel: Int(kneePainLevel)
                        )
                        onStart(checkIn)
                    } label: {
                        Text("Adjust & Start Workout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button {
                        onStart(nil)
                    } label: {
                        Text("Skip Check-in & Start")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .navigationTitle("Pre-Workout Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var energyDescription: String {
        switch Int(energyLevel) {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Moderate"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return ""
        }
    }

    private var kneePainDescription: String {
        switch Int(kneePainLevel) {
        case 0: return "None"
        case 1: return "Mild"
        case 2: return "Significant"
        default: return ""
        }
    }

    private var shouldAdjust: Bool {
        Int(energyLevel) <= 2 || Int(kneePainLevel) >= 1
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .environmentObject(AppState())
}
