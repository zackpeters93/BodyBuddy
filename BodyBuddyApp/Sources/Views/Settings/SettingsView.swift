// SettingsView.swift
// Settings screen for profile editing and app management

import SwiftUI
import BodyBuddyCore

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingResetConfirmation = false
    @State private var showingProfileEditor = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section("Profile") {
                    if let profile = appState.userProfile {
                        ProfileSummaryRow(profile: profile)
                            .onTapGesture {
                                showingProfileEditor = true
                            }
                    }

                    Button("Edit Profile") {
                        showingProfileEditor = true
                    }
                }

                // Workout Section
                Section("Workout") {
                    Button("Regenerate Weekly Plan") {
                        appState.regeneratePlan()
                    }

                    if let plan = appState.weeklyPlan {
                        HStack {
                            Text("Workouts Completed")
                            Spacer()
                            Text("\(plan.completedWorkouts)/\(plan.plannedWorkouts)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("0.1.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Exercise Library")
                        Spacer()
                        Text("\(ExerciseLibrary.count) exercises")
                            .foregroundColor(.secondary)
                    }
                }

                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Reset App Data")
                        }
                    }
                } footer: {
                    Text("This will delete all your data and return to onboarding.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset App Data?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset All Data", role: .destructive) {
                    appState.resetApp()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete your profile, workout history, and all settings. This cannot be undone.")
            }
            .sheet(isPresented: $showingProfileEditor) {
                if let profile = appState.userProfile {
                    ProfileEditorView(profile: profile)
                }
            }
        }
    }
}

// MARK: - Profile Summary Row

struct ProfileSummaryRow: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(profile.name.isEmpty ? "Your Profile" : profile.name)
                        .font(.headline)

                    Text(profile.primaryGoal.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 16) {
                Label(profile.kneeProfile.displayName, systemImage: "knee")

                Label("\(profile.schedule.daysPerWeek)x/week", systemImage: "calendar")

                Label("\(profile.schedule.minutesPerSession) min", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Profile Editor View

struct ProfileEditorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    let profile: UserProfile

    @State private var name: String = ""
    @State private var selectedGoal: PrimaryGoal = .generalFitness
    @State private var kneeProfile: KneeProfile = .healthy
    @State private var daysPerWeek: Int = 3
    @State private var minutesPerSession: Int = 30
    @State private var selectedEquipment: Set<EquipmentType> = [.bodyweight]

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal") {
                    TextField("Name (optional)", text: $name)
                }

                Section("Goal") {
                    Picker("Primary Goal", selection: $selectedGoal) {
                        ForEach(PrimaryGoal.allCases) { goal in
                            Text(goal.displayName).tag(goal)
                        }
                    }
                }

                Section("Knee Health") {
                    Picker("Knee Profile", selection: $kneeProfile) {
                        ForEach(KneeProfile.allCases) { profile in
                            Text(profile.displayName).tag(profile)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(kneeProfile.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Schedule") {
                    Picker("Days per Week", selection: $daysPerWeek) {
                        ForEach(WorkoutSchedule.daysPerWeekOptions, id: \.self) { days in
                            Text("\(days)").tag(days)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Minutes per Session", selection: $minutesPerSession) {
                        ForEach(WorkoutSchedule.minutesPerSessionOptions, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Equipment") {
                    ForEach(EquipmentType.allCases) { equipment in
                        Toggle(isOn: Binding(
                            get: { selectedEquipment.contains(equipment) },
                            set: { isOn in
                                if isOn {
                                    selectedEquipment.insert(equipment)
                                } else if selectedEquipment.count > 1 {
                                    selectedEquipment.remove(equipment)
                                }
                            }
                        )) {
                            Label(equipment.displayName, systemImage: equipment.icon)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }

    private func loadProfile() {
        name = profile.name
        selectedGoal = profile.primaryGoal
        kneeProfile = profile.kneeProfile
        daysPerWeek = profile.schedule.daysPerWeek
        minutesPerSession = profile.schedule.minutesPerSession
        selectedEquipment = profile.equipment
    }

    private func saveProfile() {
        let updatedProfile = UserProfile(
            id: profile.id,
            name: name,
            primaryGoal: selectedGoal,
            kneeProfile: kneeProfile,
            schedule: WorkoutSchedule(
                daysPerWeek: daysPerWeek,
                minutesPerSession: minutesPerSession
            ),
            equipment: selectedEquipment,
            createdAt: profile.createdAt,
            updatedAt: Date()
        )

        appState.updateProfile(updatedProfile)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
