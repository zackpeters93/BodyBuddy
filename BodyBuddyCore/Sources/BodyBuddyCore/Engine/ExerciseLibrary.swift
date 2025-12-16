// ExerciseLibrary.swift
// Hard-coded exercise library for BodyBuddy v0.1

import Foundation

/// Central repository of all available exercises
public struct ExerciseLibrary {

    /// All available exercises in the library
    public static let exercises: [Exercise] = [
        // MARK: - Chest Exercises

        Exercise(
            id: "pushup",
            name: "Push-Up",
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10-15",
            instructions: "Keep body straight, lower chest to floor, push back up"
        ),

        Exercise(
            id: "incline_pushup",
            name: "Incline Push-Up",
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "12-15",
            instructions: "Hands elevated on bench or step, easier variation"
        ),

        Exercise(
            id: "dumbbell_chest_press",
            name: "Dumbbell Chest Press",
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "8-12",
            instructions: "Lie on back, press dumbbells up from chest level"
        ),

        // MARK: - Back Exercises

        Exercise(
            id: "dumbbell_row",
            name: "Dumbbell Row",
            primaryMuscle: .back,
            secondaryMuscles: [.biceps],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "8-12",
            instructions: "Hinge at hips, pull dumbbell to hip, squeeze back"
        ),

        Exercise(
            id: "superman",
            name: "Superman Hold",
            primaryMuscle: .back,
            secondaryMuscles: [.glutes],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "10-15",
            instructions: "Lie face down, lift arms and legs off ground, hold"
        ),

        // MARK: - Shoulder Exercises

        Exercise(
            id: "dumbbell_shoulder_press",
            name: "Dumbbell Shoulder Press",
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "8-12",
            instructions: "Press dumbbells overhead from shoulder height"
        ),

        Exercise(
            id: "lateral_raise",
            name: "Lateral Raise",
            primaryMuscle: .shoulders,
            secondaryMuscles: [],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "12-15",
            instructions: "Raise arms out to sides until parallel to floor"
        ),

        Exercise(
            id: "pike_pushup",
            name: "Pike Push-Up",
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "8-12",
            instructions: "Hips high, body in inverted V, lower head toward floor"
        ),

        // MARK: - Biceps Exercises

        Exercise(
            id: "dumbbell_curl",
            name: "Dumbbell Curl",
            primaryMuscle: .biceps,
            secondaryMuscles: [],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "10-12",
            instructions: "Curl dumbbells up, squeeze at top, control the descent"
        ),

        Exercise(
            id: "hammer_curl",
            name: "Hammer Curl",
            primaryMuscle: .biceps,
            secondaryMuscles: [],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "10-12",
            instructions: "Curl with palms facing each other (neutral grip)"
        ),

        // MARK: - Triceps Exercises

        Exercise(
            id: "tricep_dip",
            name: "Tricep Dip (Chair)",
            primaryMuscle: .triceps,
            secondaryMuscles: [.shoulders],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10-15",
            instructions: "Hands on chair behind you, lower body, push back up"
        ),

        Exercise(
            id: "tricep_kickback",
            name: "Tricep Kickback",
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "10-12",
            instructions: "Hinge forward, extend arm back, squeeze tricep"
        ),

        Exercise(
            id: "diamond_pushup",
            name: "Diamond Push-Up",
            primaryMuscle: .triceps,
            secondaryMuscles: [.chest],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "8-12",
            instructions: "Hands close together forming diamond shape"
        ),

        // MARK: - Leg Exercises

        Exercise(
            id: "bodyweight_squat",
            name: "Bodyweight Squat",
            primaryMuscle: .legs,
            secondaryMuscles: [.glutes],
            kneeLoad: .high,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "12-15",
            instructions: "Feet shoulder-width, squat down until thighs parallel"
        ),

        Exercise(
            id: "goblet_squat",
            name: "Goblet Squat",
            primaryMuscle: .legs,
            secondaryMuscles: [.glutes, .core],
            kneeLoad: .high,
            equipmentRequired: [.dumbbells],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10-12",
            instructions: "Hold dumbbell at chest, squat deep with upright torso"
        ),

        Exercise(
            id: "lunge",
            name: "Forward Lunge",
            primaryMuscle: .legs,
            secondaryMuscles: [.glutes],
            kneeLoad: .high,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10 each leg",
            instructions: "Step forward, lower back knee toward floor, push back"
        ),

        Exercise(
            id: "step_up",
            name: "Step-Up",
            primaryMuscle: .legs,
            secondaryMuscles: [.glutes],
            kneeLoad: .moderate,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10 each leg",
            instructions: "Step onto elevated surface, drive through front heel"
        ),

        // MARK: - Glute Exercises

        Exercise(
            id: "glute_bridge",
            name: "Glute Bridge",
            primaryMuscle: .glutes,
            secondaryMuscles: [.core],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "15-20",
            instructions: "Lie on back, drive hips up, squeeze glutes at top"
        ),

        Exercise(
            id: "romanian_deadlift",
            name: "Romanian Deadlift",
            primaryMuscle: .glutes,
            secondaryMuscles: [.back],
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10-12",
            instructions: "Hinge at hips, lower dumbbells along legs, squeeze glutes to stand"
        ),

        // MARK: - Core Exercises

        Exercise(
            id: "plank",
            name: "Plank",
            primaryMuscle: .core,
            secondaryMuscles: [.shoulders],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "30-60 sec",
            instructions: "Hold straight body position on forearms and toes"
        ),

        Exercise(
            id: "dead_bug",
            name: "Dead Bug",
            primaryMuscle: .core,
            secondaryMuscles: [],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .isolation,
            defaultSets: 3,
            defaultReps: "10 each side",
            instructions: "Lie on back, alternate extending opposite arm and leg"
        )
    ]

    // MARK: - Filtering Methods

    /// Returns all exercises that can be performed with the given equipment
    public static func exercises(forEquipment equipment: Set<EquipmentType>) -> [Exercise] {
        exercises.filter { $0.canPerformWith(equipment: equipment) }
    }

    /// Returns all exercises allowed for the given knee profile
    public static func exercises(forKneeProfile profile: KneeProfile) -> [Exercise] {
        exercises.filter { $0.isAllowedFor(kneeProfile: profile) }
    }

    /// Returns all exercises matching both equipment and knee profile constraints
    public static func exercises(
        forEquipment equipment: Set<EquipmentType>,
        kneeProfile: KneeProfile
    ) -> [Exercise] {
        exercises.filter {
            $0.canPerformWith(equipment: equipment) &&
            $0.isAllowedFor(kneeProfile: kneeProfile)
        }
    }

    /// Returns all exercises targeting a specific muscle group
    public static func exercises(forMuscleGroup muscle: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.primaryMuscle == muscle }
    }

    /// Returns all arm exercises (biceps and triceps)
    public static var armExercises: [Exercise] {
        exercises.filter { $0.isArmExercise }
    }

    /// Returns all compound exercises
    public static var compoundExercises: [Exercise] {
        exercises.filter { $0.isCompound }
    }

    /// Returns an exercise by ID
    public static func exercise(byId id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }

    // MARK: - Statistics

    /// Total number of exercises in the library
    public static var count: Int {
        exercises.count
    }

    /// Breakdown of exercises by knee load level
    public static var kneeLoadBreakdown: [KneeLoadLevel: Int] {
        Dictionary(grouping: exercises, by: { $0.kneeLoad })
            .mapValues { $0.count }
    }

    /// Breakdown of exercises by muscle group
    public static var muscleGroupBreakdown: [MuscleGroup: Int] {
        Dictionary(grouping: exercises, by: { $0.primaryMuscle })
            .mapValues { $0.count }
    }
}
