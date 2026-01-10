// OnboardingContainerView.swift
// Container for the multi-step onboarding flow

import SwiftUI
import BodyBuddyCore

struct OnboardingContainerView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                OnboardingProgressBar(currentStep: viewModel.currentStep, totalSteps: 4)
                    .padding(.horizontal)
                    .padding(.top)

                // Step content
                TabView(selection: $viewModel.currentStep) {
                    GoalSelectionView(viewModel: viewModel)
                        .tag(1)

                    KneeStatusView(viewModel: viewModel)
                        .tag(2)

                    ScheduleView(viewModel: viewModel)
                        .tag(3)

                    EquipmentView(viewModel: viewModel)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)

                // Navigation buttons
                OnboardingNavigationButtons(viewModel: viewModel) {
                    appState.completeOnboarding(with: viewModel.buildProfile())
                }
                .padding()
            }
            .navigationTitle("Welcome to BodyBuddy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Navigation Buttons

struct OnboardingNavigationButtons: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        HStack {
            if viewModel.currentStep > 1 {
                Button("Back") {
                    viewModel.previousStep()
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            if viewModel.currentStep < 4 {
                Button("Continue") {
                    viewModel.nextStep()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canProceed)
            } else {
                Button("Get Started") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canProceed)
            }
        }
    }
}

// MARK: - Step 1: Goal Selection

struct GoalSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's your primary goal?")
                .font(.title2)
                .fontWeight(.bold)

            Text("We'll customize your workouts based on your goal.")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(PrimaryGoal.allCases) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: viewModel.selectedGoal == goal
                    ) {
                        viewModel.selectedGoal = goal
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct GoalOptionCard: View {
    let goal: PrimaryGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 2: Knee Status

struct KneeStatusView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How are your knees?")
                .font(.title2)
                .fontWeight(.bold)

            Text("We'll filter exercises to keep you safe.")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(KneeProfile.allCases) { profile in
                    KneeOptionCard(
                        profile: profile,
                        isSelected: viewModel.kneeProfile == profile
                    ) {
                        viewModel.kneeProfile = profile
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct KneeOptionCard: View {
    let profile: KneeProfile
    let isSelected: Bool
    let action: () -> Void

    private var iconName: String {
        switch profile {
        case .healthy: return "checkmark.shield.fill"
        case .sensitive: return "exclamationmark.shield.fill"
        case .restricted: return "xmark.shield.fill"
        }
    }

    private var iconColor: Color {
        switch profile {
        case .healthy: return .green
        case .sensitive: return .yellow
        case .restricted: return .red
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(profile.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 3: Schedule

struct ScheduleView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Set your schedule")
                .font(.title2)
                .fontWeight(.bold)

            Text("How often and how long do you want to work out?")
                .foregroundColor(.secondary)

            // Days per week
            VStack(alignment: .leading, spacing: 12) {
                Text("Days per week")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(WorkoutSchedule.daysPerWeekOptions, id: \.self) { days in
                        ScheduleOptionButton(
                            label: "\(days)",
                            sublabel: days == 1 ? "day" : "days",
                            isSelected: viewModel.daysPerWeek == days
                        ) {
                            viewModel.daysPerWeek = days
                        }
                    }
                }
            }

            // Minutes per session
            VStack(alignment: .leading, spacing: 12) {
                Text("Minutes per session")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(WorkoutSchedule.minutesPerSessionOptions, id: \.self) { minutes in
                        ScheduleOptionButton(
                            label: "\(minutes)",
                            sublabel: "min",
                            isSelected: viewModel.minutesPerSession == minutes
                        ) {
                            viewModel.minutesPerSession = minutes
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct ScheduleOptionButton: View {
    let label: String
    let sublabel: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.title)
                    .fontWeight(.bold)

                Text(sublabel)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 4: Equipment

struct EquipmentView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What equipment do you have?")
                .font(.title2)
                .fontWeight(.bold)

            Text("Select all that apply. You can always change this later.")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(EquipmentType.allCases) { equipment in
                    EquipmentOptionCard(
                        equipment: equipment,
                        isSelected: viewModel.selectedEquipment.contains(equipment)
                    ) {
                        viewModel.toggleEquipment(equipment)
                    }
                }
            }

            if viewModel.selectedEquipment.isEmpty {
                Text("Select at least one option to continue")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Spacer()
        }
        .padding()
    }
}

struct EquipmentOptionCard: View {
    let equipment: EquipmentType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: equipment.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                    .frame(width: 40)

                Text(equipment.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView()
        .environmentObject(AppState())
}
