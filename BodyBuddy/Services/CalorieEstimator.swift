// CalorieEstimator.swift
// Estimates calories burned based on workout type, duration, and user metrics

import Foundation
import BodyBuddyCore

/// Estimates calories burned during workouts using MET (Metabolic Equivalent of Task) values
public struct CalorieEstimator {

    /// User metrics for calorie calculation
    public struct UserMetrics {
        public let weightKg: Double
        public let age: Int

        public init(
            weightKg: Double = 70.0,
            age: Int = 35
        ) {
            self.weightKg = weightKg
            self.age = age
        }
    }

    /// MET values for different exercise intensities
    /// Source: Compendium of Physical Activities
    private enum METValue {
        /// Light weight lifting, general
        static let lightStrength: Double = 3.0
        /// Moderate effort strength training
        static let moderateStrength: Double = 4.5
        /// Vigorous effort, circuit training
        static let vigorousStrength: Double = 6.0
    }

    /// Workout intensity levels
    private enum Intensity {
        case light
        case moderate
        case vigorous
    }

    // MARK: - Public API

    /// Estimates calories burned for a workout session
    /// - Parameters:
    ///   - session: The completed workout session
    ///   - metrics: User metrics (weight, age)
    /// - Returns: Estimated calories burned
    public static func estimate(
        session: WorkoutSession,
        metrics: UserMetrics = UserMetrics()
    ) -> Double {
        guard let start = session.startedAt,
              let end = session.completedAt else {
            return 0
        }

        let durationMinutes = end.timeIntervalSince(start) / 60.0

        // Determine intensity based on workout characteristics
        let intensity = determineIntensity(for: session)
        let met = metValue(for: intensity)

        // Calories per minute using the standard MET formula:
        // Calories/min = (MET × 3.5 × body weight in kg) / 200
        let caloriesPerMinute = (met * 3.5 * metrics.weightKg) / 200.0

        return caloriesPerMinute * durationMinutes
    }

    /// Estimates calories for a given duration and intensity
    /// - Parameters:
    ///   - durationMinutes: Duration in minutes
    ///   - metrics: User metrics
    ///   - intensity: Workout intensity (nil for moderate default)
    /// - Returns: Estimated calories
    public static func estimate(
        durationMinutes: Double,
        metrics: UserMetrics = UserMetrics(),
        intensity: String? = nil
    ) -> Double {
        let met: Double
        switch intensity?.lowercased() {
        case "light":
            met = METValue.lightStrength
        case "vigorous", "intense":
            met = METValue.vigorousStrength
        default:
            met = METValue.moderateStrength
        }

        let caloriesPerMinute = (met * 3.5 * metrics.weightKg) / 200.0
        return caloriesPerMinute * durationMinutes
    }

    // MARK: - Private Helpers

    /// Determines workout intensity based on session characteristics
    private static func determineIntensity(for session: WorkoutSession) -> Intensity {
        let totalSets = session.exercises.reduce(0) { $0 + $1.completedSets }
        let exerciseCount = session.exercises.count

        // Count compound exercises (they typically require more effort)
        let compoundCount = session.exercises.filter { exercise in
            isCompoundExercise(exerciseId: exercise.exerciseId)
        }.count

        // Calculate effective workout density
        // More sets with more compound movements = higher intensity
        let hasHighVolume = totalSets >= 12
        let hasCompoundFocus = compoundCount >= 2
        let hasMultipleExercises = exerciseCount >= 4

        if hasHighVolume && hasCompoundFocus {
            return .vigorous
        } else if hasHighVolume || (hasCompoundFocus && hasMultipleExercises) {
            return .moderate
        } else {
            return .light
        }
    }

    /// Returns the MET value for a given intensity
    private static func metValue(for intensity: Intensity) -> Double {
        switch intensity {
        case .light:
            return METValue.lightStrength
        case .moderate:
            return METValue.moderateStrength
        case .vigorous:
            return METValue.vigorousStrength
        }
    }

    /// Checks if an exercise is a compound movement
    private static func isCompoundExercise(exerciseId: String) -> Bool {
        // Known compound exercises in the library
        let compoundIds = [
            "pushup", "pushup_incline",
            "squat", "goblet_squat",
            "lunge", "reverse_lunge",
            "bent_over_row", "single_arm_row",
            "shoulder_press",
            "deadlift_dumbbell"
        ]
        return compoundIds.contains(exerciseId)
    }
}

// MARK: - Extensions for Display

public extension CalorieEstimator {
    /// Returns a formatted string for displaying calories
    static func formattedCalories(_ calories: Double) -> String {
        let rounded = Int(calories.rounded())
        return "\(rounded) cal"
    }
}
