// WorkoutEngine.swift
// Rules-based workout generation engine for BodyBuddy

import Foundation

/// Engine for generating personalized workout plans
public struct WorkoutEngine {

    // MARK: - Configuration

    /// Default workout day schedule (Mon, Wed, Fri)
    private static let defaultWorkoutDays = [1, 3, 5] // Monday = 1, Sunday = 7

    /// Muscle group rotation for balanced training
    private static let muscleRotation: [[MuscleGroup]] = [
        [.chest, .triceps, .shoulders],  // Day 1: Push
        [.back, .biceps],                 // Day 2: Pull
        [.legs, .glutes, .core]           // Day 3: Lower + Core
    ]

    // MARK: - Public API

    /// Generates a weekly workout plan for the user
    /// - Parameters:
    ///   - profile: User's fitness profile
    ///   - startDate: First day of the week (typically Monday)
    /// - Returns: A WeeklyPlan with workout sessions
    public static func generateWeek(
        for profile: UserProfile,
        startDate: Date = Self.startOfCurrentWeek()
    ) -> WeeklyPlan {
        let calendar = Calendar.current
        var sessions: [WorkoutSession] = []

        // Get workout days based on user's schedule
        let workoutDayIndices = getWorkoutDayIndices(daysPerWeek: profile.schedule.daysPerWeek)

        // Generate sessions for each day of the week (Mon-Fri)
        for dayOffset in 0..<5 {
            guard let sessionDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else {
                continue
            }

            let dayIndex = dayOffset + 1 // 1-indexed (Mon=1, Tue=2, etc.)

            if workoutDayIndices.contains(dayIndex) {
                // Workout day
                let workoutDayNumber = workoutDayIndices.firstIndex(of: dayIndex)! + 1
                let session = generateSession(
                    for: profile,
                    dayIndex: workoutDayNumber,
                    date: sessionDate
                )
                sessions.append(session)
            } else {
                // Rest day
                let restSession = WorkoutSession(
                    date: sessionDate,
                    dayIndex: dayIndex,
                    dayType: .rest,
                    exercises: [],
                    status: .planned
                )
                sessions.append(restSession)
            }
        }

        return WeeklyPlan(
            weekStartDate: startDate,
            sessions: sessions
        )
    }

    /// Generates a single workout session
    /// - Parameters:
    ///   - profile: User's fitness profile
    ///   - dayIndex: Which workout day (1, 2, or 3)
    ///   - date: Date of the workout
    /// - Returns: A WorkoutSession with exercises
    public static func generateSession(
        for profile: UserProfile,
        dayIndex: Int,
        date: Date
    ) -> WorkoutSession {
        let exercises = selectExercises(for: profile, dayIndex: dayIndex)

        let workoutExercises = exercises.map { exercise in
            WorkoutExercise(from: exercise)
        }

        return WorkoutSession(
            date: date,
            dayIndex: dayIndex,
            dayType: .workout,
            exercises: workoutExercises,
            status: .planned
        )
    }

    /// Checks if an exercise is allowed for a user's profile
    /// - Parameters:
    ///   - exercise: The exercise to check
    ///   - profile: User's fitness profile
    /// - Returns: True if the exercise meets all constraints
    public static func isAllowed(exercise: Exercise, for profile: UserProfile) -> Bool {
        // Check knee profile
        guard exercise.isAllowedFor(kneeProfile: profile.kneeProfile) else {
            return false
        }

        // Check equipment
        guard exercise.canPerformWith(equipment: profile.equipment) else {
            return false
        }

        return true
    }

    /// Adjusts a workout session based on pre-workout check-in
    /// - Parameters:
    ///   - session: The session to adjust
    ///   - checkIn: Pre-workout check-in data
    /// - Returns: Adjusted workout session
    public static func adjust(
        session: WorkoutSession,
        with checkIn: PreWorkoutCheckIn
    ) -> WorkoutSession {
        return checkIn.adjustedSession(from: session)
    }

    /// Returns available exercises for a user's profile
    public static func availableExercises(for profile: UserProfile) -> [Exercise] {
        ExerciseLibrary.exercises(
            forEquipment: profile.equipment,
            kneeProfile: profile.kneeProfile
        )
    }

    // MARK: - Private Helpers

    /// Selects exercises for a workout day based on profile and rotation
    private static func selectExercises(
        for profile: UserProfile,
        dayIndex: Int
    ) -> [Exercise] {
        let availableExercises = availableExercises(for: profile)
        let exerciseCount = profile.schedule.estimatedExerciseCount

        // Get target muscle groups for this day
        let rotationIndex = (dayIndex - 1) % muscleRotation.count
        let targetMuscles = muscleRotation[rotationIndex]

        var selectedExercises: [Exercise] = []

        // First, add exercises for target muscle groups
        for muscle in targetMuscles {
            let muscleExercises = availableExercises.filter { $0.primaryMuscle == muscle }
            if let exercise = muscleExercises.first {
                selectedExercises.append(exercise)
            }
        }

        // Handle arm-focused goal: ensure 2 arm exercises per session
        if profile.isArmFocused {
            let currentArmCount = selectedExercises.filter { $0.isArmExercise }.count
            let neededArmExercises = max(0, profile.armExercisesPerSession - currentArmCount)

            if neededArmExercises > 0 {
                let availableArmExercises = availableExercises.filter {
                    $0.isArmExercise && !selectedExercises.contains($0)
                }

                for exercise in availableArmExercises.prefix(neededArmExercises) {
                    selectedExercises.append(exercise)
                }
            }
        }

        // Fill remaining slots with compound exercises if needed
        while selectedExercises.count < exerciseCount {
            let remaining = availableExercises.filter {
                !selectedExercises.contains($0) && $0.isCompound
            }

            if let exercise = remaining.first {
                selectedExercises.append(exercise)
            } else {
                // Fall back to any remaining exercises
                let anyRemaining = availableExercises.filter {
                    !selectedExercises.contains($0)
                }
                if let exercise = anyRemaining.first {
                    selectedExercises.append(exercise)
                } else {
                    break // No more exercises available
                }
            }
        }

        // Limit to exercise count
        return Array(selectedExercises.prefix(exerciseCount))
    }

    /// Returns workout day indices based on days per week
    private static func getWorkoutDayIndices(daysPerWeek: Int) -> [Int] {
        switch daysPerWeek {
        case 1: return [3]           // Wednesday only
        case 2: return [1, 4]        // Monday, Thursday
        case 3: return [1, 3, 5]     // Monday, Wednesday, Friday
        default: return [1, 3, 5]
        }
    }

    /// Returns the start of the current week (Monday)
    public static func startOfCurrentWeek() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        return calendar.date(from: components) ?? Date()
    }
}

// MARK: - Workout Validation

extension WorkoutEngine {

    /// Validates that a workout plan meets all constraints
    public static func validate(plan: WeeklyPlan, for profile: UserProfile) -> ValidationResult {
        var issues: [String] = []

        for session in plan.workoutDays {
            // Check each exercise is allowed
            for exercise in session.exercises {
                if let libraryExercise = ExerciseLibrary.exercise(byId: exercise.exerciseId) {
                    if !isAllowed(exercise: libraryExercise, for: profile) {
                        issues.append("Exercise '\(exercise.exerciseName)' not allowed for profile")
                    }
                }
            }

            // Check arm exercise count for arm-focused users
            if profile.isArmFocused {
                let armCount = session.exercises.filter {
                    $0.primaryMuscle.isArmMuscle
                }.count

                if armCount < profile.armExercisesPerSession {
                    issues.append("Day \(session.dayIndex): Only \(armCount) arm exercises, expected \(profile.armExercisesPerSession)")
                }
            }
        }

        return ValidationResult(isValid: issues.isEmpty, issues: issues)
    }

    /// Result of workout validation
    public struct ValidationResult {
        public let isValid: Bool
        public let issues: [String]

        public init(isValid: Bool, issues: [String]) {
            self.isValid = isValid
            self.issues = issues
        }
    }
}

// MARK: - Workout Statistics

extension WorkoutEngine {

    /// Returns statistics about a workout session
    public static func statistics(for session: WorkoutSession) -> SessionStatistics {
        let totalSets = session.exercises.reduce(0) { $0 + $1.targetSets }
        let completedSets = session.exercises.reduce(0) { $0 + $1.completedSets }

        let muscleGroups = Set(session.exercises.map { $0.primaryMuscle })

        return SessionStatistics(
            exerciseCount: session.exerciseCount,
            totalSets: totalSets,
            completedSets: completedSets,
            muscleGroups: muscleGroups,
            progress: session.progress
        )
    }

    /// Statistics about a workout session
    public struct SessionStatistics {
        public let exerciseCount: Int
        public let totalSets: Int
        public let completedSets: Int
        public let muscleGroups: Set<MuscleGroup>
        public let progress: Double

        public var remainingSets: Int {
            totalSets - completedSets
        }
    }
}
