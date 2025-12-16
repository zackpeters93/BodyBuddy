// Enums.swift
// Core enum types for BodyBuddy

import Foundation

// MARK: - Primary Goal

/// User's primary fitness goal
public enum PrimaryGoal: String, Codable, CaseIterable, Identifiable {
    case generalFitness = "general_fitness"
    case arms = "arms"
    case knees = "knees"
    case fatLoss = "fat_loss"
    case strength = "strength"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .generalFitness: return "General Fitness"
        case .arms: return "Build Stronger Arms"
        case .knees: return "Knee-Friendly Training"
        case .fatLoss: return "Fat Loss"
        case .strength: return "Build Strength"
        }
    }

    public var description: String {
        switch self {
        case .generalFitness: return "Balanced full-body training"
        case .arms: return "Extra focus on biceps and triceps"
        case .knees: return "Low-impact exercises for knee health"
        case .fatLoss: return "Higher rep ranges and metabolic focus"
        case .strength: return "Heavy compound movements"
        }
    }
}

// MARK: - Knee Profile

/// User's knee health status for exercise filtering
public enum KneeProfile: String, Codable, CaseIterable, Identifiable {
    case healthy = "healthy"
    case sensitive = "sensitive"
    case restricted = "restricted"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .sensitive: return "Sensitive"
        case .restricted: return "Restricted"
        }
    }

    public var description: String {
        switch self {
        case .healthy: return "No knee issues - all exercises allowed"
        case .sensitive: return "Some discomfort - avoid high knee-load exercises"
        case .restricted: return "Significant issues - low knee-load only"
        }
    }

    /// Returns allowed knee load levels for this profile
    public var allowedKneeLoadLevels: Set<KneeLoadLevel> {
        switch self {
        case .healthy: return [.low, .moderate, .high]
        case .sensitive: return [.low, .moderate]
        case .restricted: return [.low]
        }
    }
}

// MARK: - Muscle Group

/// Primary muscle groups targeted by exercises
public enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "chest"
    case back = "back"
    case shoulders = "shoulders"
    case biceps = "biceps"
    case triceps = "triceps"
    case legs = "legs"
    case glutes = "glutes"
    case core = "core"
    case fullBody = "full_body"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .legs: return "Legs"
        case .glutes: return "Glutes"
        case .core: return "Core"
        case .fullBody: return "Full Body"
        }
    }

    /// Whether this muscle group counts as "arms" for arm-focused goals
    public var isArmMuscle: Bool {
        self == .biceps || self == .triceps
    }
}

// MARK: - Equipment Type

/// Types of equipment available for workouts
public enum EquipmentType: String, Codable, CaseIterable, Identifiable {
    case bodyweight = "bodyweight"
    case dumbbells = "dumbbells"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .bodyweight: return "Bodyweight"
        case .dumbbells: return "Dumbbells"
        }
    }

    public var icon: String {
        switch self {
        case .bodyweight: return "figure.stand"
        case .dumbbells: return "dumbbell.fill"
        }
    }
}

// MARK: - Knee Load Level

/// How much stress an exercise places on the knees
public enum KneeLoadLevel: String, Codable, CaseIterable, Identifiable, Comparable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }

    public var colorName: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "red"
        }
    }

    private var sortOrder: Int {
        switch self {
        case .low: return 0
        case .moderate: return 1
        case .high: return 2
        }
    }

    public static func < (lhs: KneeLoadLevel, rhs: KneeLoadLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Day Type

/// Type of day in the workout schedule
public enum DayType: String, Codable, CaseIterable, Identifiable {
    case workout = "workout"
    case rest = "rest"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .workout: return "Workout Day"
        case .rest: return "Rest Day"
        }
    }
}

// MARK: - Workout Status

/// Status of a workout session
public enum WorkoutStatus: String, Codable, CaseIterable, Identifiable {
    case planned = "planned"
    case inProgress = "in_progress"
    case completed = "completed"
    case skipped = "skipped"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .planned: return "Planned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .skipped: return "Skipped"
        }
    }

    public var icon: String {
        switch self {
        case .planned: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        case .skipped: return "xmark.circle"
        }
    }
}

// MARK: - Exercise Type

/// Whether an exercise is compound or isolation
public enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case compound = "compound"
    case isolation = "isolation"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .compound: return "Compound"
        case .isolation: return "Isolation"
        }
    }

    public var description: String {
        switch self {
        case .compound: return "Multi-joint movement"
        case .isolation: return "Single-joint movement"
        }
    }
}
