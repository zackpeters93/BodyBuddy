import XCTest
@testable import BodyBuddyCore

final class BodyBuddyCoreTests: XCTestCase {

    func testVersion() {
        XCTAssertEqual(BodyBuddyCore.version, "0.1.0")
    }
}

// MARK: - Enum Tests

final class EnumTests: XCTestCase {

    func testPrimaryGoalCodable() throws {
        let goal = PrimaryGoal.arms
        let data = try JSONEncoder().encode(goal)
        let decoded = try JSONDecoder().decode(PrimaryGoal.self, from: data)
        XCTAssertEqual(goal, decoded)
    }

    func testKneeProfileAllowedLevels() {
        XCTAssertEqual(KneeProfile.healthy.allowedKneeLoadLevels, [.low, .moderate, .high])
        XCTAssertEqual(KneeProfile.sensitive.allowedKneeLoadLevels, [.low, .moderate])
        XCTAssertEqual(KneeProfile.restricted.allowedKneeLoadLevels, [.low])
    }

    func testMuscleGroupIsArmMuscle() {
        XCTAssertTrue(MuscleGroup.biceps.isArmMuscle)
        XCTAssertTrue(MuscleGroup.triceps.isArmMuscle)
        XCTAssertFalse(MuscleGroup.chest.isArmMuscle)
        XCTAssertFalse(MuscleGroup.legs.isArmMuscle)
    }

    func testKneeLoadLevelComparable() {
        XCTAssertTrue(KneeLoadLevel.low < KneeLoadLevel.moderate)
        XCTAssertTrue(KneeLoadLevel.moderate < KneeLoadLevel.high)
        XCTAssertFalse(KneeLoadLevel.high < KneeLoadLevel.low)
    }
}

// MARK: - UserProfile Tests

final class UserProfileTests: XCTestCase {

    func testUserProfileCodable() throws {
        let profile = UserProfile(
            name: "Test User",
            primaryGoal: .arms,
            kneeProfile: .sensitive,
            schedule: WorkoutSchedule(daysPerWeek: 3, minutesPerSession: 30),
            equipment: [.bodyweight, .dumbbells]
        )

        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)

        XCTAssertEqual(profile.id, decoded.id)
        XCTAssertEqual(profile.name, decoded.name)
        XCTAssertEqual(profile.primaryGoal, decoded.primaryGoal)
        XCTAssertEqual(profile.kneeProfile, decoded.kneeProfile)
        XCTAssertEqual(profile.schedule, decoded.schedule)
        XCTAssertEqual(profile.equipment, decoded.equipment)
    }

    func testArmFocused() {
        var profile = UserProfile(primaryGoal: .arms)
        XCTAssertTrue(profile.isArmFocused)
        XCTAssertEqual(profile.armExercisesPerSession, 2)

        profile.primaryGoal = .generalFitness
        XCTAssertFalse(profile.isArmFocused)
        XCTAssertEqual(profile.armExercisesPerSession, 1)
    }

    func testScheduleClamping() {
        let schedule = WorkoutSchedule(daysPerWeek: 5, minutesPerSession: 30)
        XCTAssertEqual(schedule.daysPerWeek, 3) // Clamped to max

        let schedule2 = WorkoutSchedule(daysPerWeek: 0, minutesPerSession: 30)
        XCTAssertEqual(schedule2.daysPerWeek, 1) // Clamped to min
    }

    func testEstimatedExerciseCount() {
        XCTAssertEqual(WorkoutSchedule(minutesPerSession: 20).estimatedExerciseCount, 3)
        XCTAssertEqual(WorkoutSchedule(minutesPerSession: 30).estimatedExerciseCount, 4)
        XCTAssertEqual(WorkoutSchedule(minutesPerSession: 45).estimatedExerciseCount, 5)
    }
}

// MARK: - Exercise Tests

final class ExerciseTests: XCTestCase {

    func testExerciseCodable() throws {
        let exercise = Exercise(
            id: "pushup",
            name: "Push-Up",
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound,
            defaultSets: 3,
            defaultReps: "10-15"
        )

        let data = try JSONEncoder().encode(exercise)
        let decoded = try JSONDecoder().decode(Exercise.self, from: data)

        XCTAssertEqual(exercise.id, decoded.id)
        XCTAssertEqual(exercise.name, decoded.name)
        XCTAssertEqual(exercise.primaryMuscle, decoded.primaryMuscle)
        XCTAssertEqual(exercise.equipmentRequired, decoded.equipmentRequired)
    }

    func testCanPerformWithEquipment() {
        let exercise = Exercise(
            id: "curl",
            name: "Dumbbell Curl",
            primaryMuscle: .biceps,
            kneeLoad: .low,
            equipmentRequired: [.dumbbells],
            exerciseType: .isolation
        )

        XCTAssertTrue(exercise.canPerformWith(equipment: [.dumbbells]))
        XCTAssertTrue(exercise.canPerformWith(equipment: [.bodyweight, .dumbbells]))
        XCTAssertFalse(exercise.canPerformWith(equipment: [.bodyweight]))
    }

    func testIsAllowedForKneeProfile() {
        let highLoadExercise = Exercise(
            id: "squat",
            name: "Squat",
            primaryMuscle: .legs,
            kneeLoad: .high,
            equipmentRequired: [.bodyweight],
            exerciseType: .compound
        )

        let lowLoadExercise = Exercise(
            id: "glute_bridge",
            name: "Glute Bridge",
            primaryMuscle: .glutes,
            kneeLoad: .low,
            equipmentRequired: [.bodyweight],
            exerciseType: .isolation
        )

        XCTAssertTrue(highLoadExercise.isAllowedFor(kneeProfile: .healthy))
        XCTAssertFalse(highLoadExercise.isAllowedFor(kneeProfile: .sensitive))
        XCTAssertFalse(highLoadExercise.isAllowedFor(kneeProfile: .restricted))

        XCTAssertTrue(lowLoadExercise.isAllowedFor(kneeProfile: .healthy))
        XCTAssertTrue(lowLoadExercise.isAllowedFor(kneeProfile: .sensitive))
        XCTAssertTrue(lowLoadExercise.isAllowedFor(kneeProfile: .restricted))
    }
}

// MARK: - WorkoutSession Tests

final class WorkoutSessionTests: XCTestCase {

    func testWorkoutSessionCodable() throws {
        let session = WorkoutSession(
            date: Date(),
            dayIndex: 1,
            dayType: .workout,
            exercises: [
                WorkoutExercise(
                    exerciseId: "pushup",
                    exerciseName: "Push-Up",
                    primaryMuscle: .chest,
                    kneeLoad: .low,
                    targetSets: 3
                )
            ],
            status: .planned
        )

        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(WorkoutSession.self, from: data)

        XCTAssertEqual(session.id, decoded.id)
        XCTAssertEqual(session.dayIndex, decoded.dayIndex)
        XCTAssertEqual(session.exercises.count, decoded.exercises.count)
    }

    func testWorkoutProgress() {
        var session = WorkoutSession(
            date: Date(),
            dayIndex: 1,
            exercises: [
                WorkoutExercise(
                    exerciseId: "ex1",
                    exerciseName: "Exercise 1",
                    primaryMuscle: .chest,
                    kneeLoad: .low,
                    targetSets: 2
                ),
                WorkoutExercise(
                    exerciseId: "ex2",
                    exerciseName: "Exercise 2",
                    primaryMuscle: .back,
                    kneeLoad: .low,
                    targetSets: 2
                )
            ]
        )

        XCTAssertEqual(session.progress, 0.0)

        session.completeSet(forExerciseAt: 0)
        XCTAssertEqual(session.progress, 0.25)

        session.completeSet(forExerciseAt: 0)
        XCTAssertEqual(session.progress, 0.5)
    }

    func testWorkoutExerciseSetCompletion() {
        var exercise = WorkoutExercise(
            exerciseId: "test",
            exerciseName: "Test Exercise",
            primaryMuscle: .chest,
            kneeLoad: .low,
            targetSets: 3
        )

        XCTAssertEqual(exercise.completedSets, 0)
        XCTAssertFalse(exercise.isCompleted)

        exercise.completeSet()
        XCTAssertEqual(exercise.completedSets, 1)

        exercise.completeSet()
        exercise.completeSet()
        XCTAssertEqual(exercise.completedSets, 3)
        XCTAssertTrue(exercise.isCompleted)

        // Should not add more sets after completed
        exercise.completeSet()
        XCTAssertEqual(exercise.completedSets, 3)
    }
}

// MARK: - CheckIn Tests

final class CheckInTests: XCTestCase {

    func testCheckInCodable() throws {
        let checkIn = PreWorkoutCheckIn(
            energyLevel: 3,
            kneePainLevel: 1
        )

        let data = try JSONEncoder().encode(checkIn)
        let decoded = try JSONDecoder().decode(PreWorkoutCheckIn.self, from: data)

        XCTAssertEqual(checkIn.id, decoded.id)
        XCTAssertEqual(checkIn.energyLevel, decoded.energyLevel)
        XCTAssertEqual(checkIn.kneePainLevel, decoded.kneePainLevel)
    }

    func testLowEnergyDetection() {
        let lowEnergy = PreWorkoutCheckIn(energyLevel: 2)
        XCTAssertTrue(lowEnergy.isLowEnergy)
        XCTAssertTrue(lowEnergy.shouldAdjustWorkout)

        let normalEnergy = PreWorkoutCheckIn(energyLevel: 3)
        XCTAssertFalse(normalEnergy.isLowEnergy)
    }

    func testKneePainDetection() {
        let noPain = PreWorkoutCheckIn(kneePainLevel: 0)
        XCTAssertFalse(noPain.hasKneePain)

        let mildPain = PreWorkoutCheckIn(kneePainLevel: 1)
        XCTAssertTrue(mildPain.hasKneePain)
        XCTAssertFalse(mildPain.hasHighKneePain)

        let highPain = PreWorkoutCheckIn(kneePainLevel: 2)
        XCTAssertTrue(highPain.hasKneePain)
        XCTAssertTrue(highPain.hasHighKneePain)
    }

    func testSetsReduction() {
        let noAdjustment = PreWorkoutCheckIn(energyLevel: 4, kneePainLevel: 0)
        XCTAssertEqual(noAdjustment.setsReduction, 0)

        let lowEnergy = PreWorkoutCheckIn(energyLevel: 2, kneePainLevel: 0)
        XCTAssertEqual(lowEnergy.setsReduction, 1)

        let kneePain = PreWorkoutCheckIn(energyLevel: 4, kneePainLevel: 1)
        XCTAssertEqual(kneePain.setsReduction, 1)
    }

    func testCheckInAdjustsSession() {
        let checkIn = PreWorkoutCheckIn(energyLevel: 2, kneePainLevel: 0)

        var session = WorkoutSession(
            date: Date(),
            dayIndex: 1,
            exercises: [
                WorkoutExercise(
                    exerciseId: "ex1",
                    exerciseName: "Exercise",
                    primaryMuscle: .chest,
                    kneeLoad: .low,
                    targetSets: 3
                )
            ]
        )

        XCTAssertEqual(session.exercises[0].targetSets, 3)

        checkIn.adjust(&session)

        XCTAssertEqual(session.exercises[0].targetSets, 2)
        XCTAssertNotNil(session.checkIn)
    }

    func testValueClamping() {
        let checkIn = PreWorkoutCheckIn(energyLevel: 10, kneePainLevel: 5)
        XCTAssertEqual(checkIn.energyLevel, 5) // Clamped to max
        XCTAssertEqual(checkIn.kneePainLevel, 2) // Clamped to max

        let checkIn2 = PreWorkoutCheckIn(energyLevel: -1, kneePainLevel: -1)
        XCTAssertEqual(checkIn2.energyLevel, 1) // Clamped to min
        XCTAssertEqual(checkIn2.kneePainLevel, 0) // Clamped to min
    }
}
