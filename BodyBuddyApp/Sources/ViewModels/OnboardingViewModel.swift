// OnboardingViewModel.swift
// View model for the onboarding flow

import SwiftUI
import BodyBuddyCore

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentStep: Int = 1

    // Step 1: Goal
    @Published var selectedGoal: PrimaryGoal = .generalFitness

    // Step 2: Knee Status
    @Published var kneeProfile: KneeProfile = .healthy

    // Step 3: Schedule
    @Published var daysPerWeek: Int = 3
    @Published var minutesPerSession: Int = 30

    // Step 4: Equipment
    @Published var selectedEquipment: Set<EquipmentType> = [.bodyweight]

    // MARK: - Computed Properties

    var canProceed: Bool {
        switch currentStep {
        case 1:
            return true // Goal always has a default
        case 2:
            return true // Knee profile always has a default
        case 3:
            return true // Schedule always has defaults
        case 4:
            return !selectedEquipment.isEmpty
        default:
            return true
        }
    }

    var stepTitle: String {
        switch currentStep {
        case 1: return "Goals"
        case 2: return "Knee Status"
        case 3: return "Schedule"
        case 4: return "Equipment"
        default: return ""
        }
    }

    // MARK: - Navigation

    func nextStep() {
        guard currentStep < 4 else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 1 else { return }
        currentStep -= 1
    }

    // MARK: - Equipment Toggle

    func toggleEquipment(_ equipment: EquipmentType) {
        if selectedEquipment.contains(equipment) {
            // Don't allow removing the last equipment
            if selectedEquipment.count > 1 {
                selectedEquipment.remove(equipment)
            }
        } else {
            selectedEquipment.insert(equipment)
        }
    }

    // MARK: - Build Profile

    func buildProfile() -> UserProfile {
        UserProfile(
            name: "",
            primaryGoal: selectedGoal,
            kneeProfile: kneeProfile,
            schedule: WorkoutSchedule(
                daysPerWeek: daysPerWeek,
                minutesPerSession: minutesPerSession
            ),
            equipment: selectedEquipment
        )
    }
}
