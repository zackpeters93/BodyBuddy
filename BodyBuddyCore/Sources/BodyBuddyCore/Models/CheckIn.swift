// CheckIn.swift
// Pre-workout check-in model for BodyBuddy

import Foundation

/// Represents the user's pre-workout state assessment
public struct PreWorkoutCheckIn: Codable, Identifiable, Equatable {
    public let id: UUID
    public let date: Date
    public var energyLevel: Int
    public var kneePainLevel: Int
    public var notes: String

    /// Energy level range (1-5)
    public static let energyRange = 1...5

    /// Knee pain level range (0-2)
    public static let kneePainRange = 0...2

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        energyLevel: Int = 3,
        kneePainLevel: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.energyLevel = min(max(energyLevel, Self.energyRange.lowerBound), Self.energyRange.upperBound)
        self.kneePainLevel = min(max(kneePainLevel, Self.kneePainRange.lowerBound), Self.kneePainRange.upperBound)
        self.notes = notes
    }

    /// Returns true if energy is low (≤ 2)
    public var isLowEnergy: Bool {
        energyLevel <= 2
    }

    /// Returns true if knee pain is present (≥ 1)
    public var hasKneePain: Bool {
        kneePainLevel >= 1
    }

    /// Returns true if knee pain is high (= 2)
    public var hasHighKneePain: Bool {
        kneePainLevel == 2
    }

    /// Returns true if the workout should be adjusted (low energy or knee pain)
    public var shouldAdjustWorkout: Bool {
        isLowEnergy || hasKneePain
    }

    /// Returns the number of sets to reduce based on check-in
    /// - Low energy (≤ 2): reduce by 1
    /// - High knee pain (= 2): reduce by 1
    /// - Both: reduce by 1 (not cumulative in v0.1)
    public var setsReduction: Int {
        shouldAdjustWorkout ? 1 : 0
    }

    /// Returns the energy level as a descriptive string
    public var energyDescription: String {
        switch energyLevel {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Moderate"
        case 4: return "Good"
        case 5: return "Excellent"
        default: return "Unknown"
        }
    }

    /// Returns the knee pain level as a descriptive string
    public var kneePainDescription: String {
        switch kneePainLevel {
        case 0: return "None"
        case 1: return "Mild"
        case 2: return "Significant"
        default: return "Unknown"
        }
    }

    /// Returns an emoji representation of energy level
    public var energyEmoji: String {
        switch energyLevel {
        case 1: return "😴"
        case 2: return "😐"
        case 3: return "🙂"
        case 4: return "😊"
        case 5: return "💪"
        default: return "❓"
        }
    }

    /// Returns an emoji representation of knee pain level
    public var kneePainEmoji: String {
        switch kneePainLevel {
        case 0: return "✅"
        case 1: return "⚠️"
        case 2: return "🔴"
        default: return "❓"
        }
    }
}

// MARK: - Check-In Adjustment

extension PreWorkoutCheckIn {
    /// Applies this check-in's adjustments to a workout session
    public func adjust(_ session: inout WorkoutSession) {
        guard shouldAdjustWorkout else { return }

        for index in session.exercises.indices {
            session.exercises[index].reduceSets(by: setsReduction)
        }

        session.checkIn = self
    }

    /// Returns an adjusted copy of the workout session
    public func adjustedSession(from session: WorkoutSession) -> WorkoutSession {
        var adjusted = session
        adjust(&adjusted)
        return adjusted
    }
}
