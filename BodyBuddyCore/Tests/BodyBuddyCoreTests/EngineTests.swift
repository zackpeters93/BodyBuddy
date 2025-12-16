import XCTest
@testable import BodyBuddyCore

// MARK: - Exercise Library Tests

final class ExerciseLibraryTests: XCTestCase {

    func testLibraryHasExercises() {
        XCTAssertGreaterThanOrEqual(ExerciseLibrary.count, 15)
        XCTAssertLessThanOrEqual(ExerciseLibrary.count, 25)
    }

    func testExercisesByEquipment() {
        let bodyweightOnly = ExerciseLibrary.exercises(forEquipment: [.bodyweight])
        XCTAssertFalse(bodyweightOnly.isEmpty)

        // All bodyweight exercises should require only bodyweight
        for exercise in bodyweightOnly {
            XCTAssertTrue(exercise.equipmentRequired.isSubset(of: [.bodyweight]))
        }

        let withDumbbells = ExerciseLibrary.exercises(forEquipment: [.bodyweight, .dumbbells])
        XCTAssertGreaterThan(withDumbbells.count, bodyweightOnly.count)
    }

    func testExercisesByKneeProfile() {
        let healthyExercises = ExerciseLibrary.exercises(forKneeProfile: .healthy)
        let sensitiveExercises = ExerciseLibrary.exercises(forKneeProfile: .sensitive)
        let restrictedExercises = ExerciseLibrary.exercises(forKneeProfile: .restricted)

        // Healthy allows all exercises
        XCTAssertEqual(healthyExercises.count, ExerciseLibrary.count)

        // Sensitive excludes high knee load
        XCTAssertLessThan(sensitiveExercises.count, healthyExercises.count)
        for exercise in sensitiveExercises {
            XCTAssertNotEqual(exercise.kneeLoad, .high)
        }

        // Restricted allows only low knee load
        XCTAssertLessThan(restrictedExercises.count, sensitiveExercises.count)
        for exercise in restrictedExercises {
            XCTAssertEqual(exercise.kneeLoad, .low)
        }
    }

    func testKneeLoadBreakdown() {
        let breakdown = ExerciseLibrary.kneeLoadBreakdown

        XCTAssertNotNil(breakdown[.low])
        XCTAssertNotNil(breakdown[.high])

        // Should have exercises at different knee load levels
        XCTAssertGreaterThan(breakdown[.low] ?? 0, 0)
    }

    func testArmExercises() {
        let armExercises = ExerciseLibrary.armExercises

        XCTAssertFalse(armExercises.isEmpty)

        for exercise in armExercises {
            XCTAssertTrue(
                exercise.primaryMuscle == .biceps || exercise.primaryMuscle == .triceps,
                "Arm exercise \(exercise.name) should target biceps or triceps"
            )
        }
    }

    func testExerciseById() {
        let pushup = ExerciseLibrary.exercise(byId: "pushup")
        XCTAssertNotNil(pushup)
        XCTAssertEqual(pushup?.name, "Push-Up")

        let nonexistent = ExerciseLibrary.exercise(byId: "nonexistent")
        XCTAssertNil(nonexistent)
    }

    func testCompoundExercises() {
        let compounds = ExerciseLibrary.compoundExercises
        XCTAssertFalse(compounds.isEmpty)

        for exercise in compounds {
            XCTAssertEqual(exercise.exerciseType, .compound)
        }
    }
}

// MARK: - Workout Engine Tests

final class WorkoutEngineTests: XCTestCase {

    func testGenerateWeekReturnsCorrectDays() {
        let profile = UserProfile(
            primaryGoal: .generalFitness,
            kneeProfile: .healthy,
            schedule: WorkoutSchedule(daysPerWeek: 3),
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = WorkoutEngine.generateWeek(for: profile)

        XCTAssertEqual(plan.sessions.count, 5) // Mon-Fri
        XCTAssertEqual(plan.workoutDays.count, 3)
    }

    func testGenerateWeekRespectsDaysPerWeek() {
        let oneDay = UserProfile(schedule: WorkoutSchedule(daysPerWeek: 1))
        let twoDays = UserProfile(schedule: WorkoutSchedule(daysPerWeek: 2))
        let threeDays = UserProfile(schedule: WorkoutSchedule(daysPerWeek: 3))

        XCTAssertEqual(WorkoutEngine.generateWeek(for: oneDay).workoutDays.count, 1)
        XCTAssertEqual(WorkoutEngine.generateWeek(for: twoDays).workoutDays.count, 2)
        XCTAssertEqual(WorkoutEngine.generateWeek(for: threeDays).workoutDays.count, 3)
    }

    func testExercisesRespectKneeProfile() {
        let restrictedProfile = UserProfile(
            kneeProfile: .restricted,
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = WorkoutEngine.generateWeek(for: restrictedProfile)

        for session in plan.workoutDays {
            for exercise in session.exercises {
                XCTAssertEqual(
                    exercise.kneeLoad, .low,
                    "Restricted profile should only have low knee load exercises, found \(exercise.exerciseName) with \(exercise.kneeLoad)"
                )
            }
        }
    }

    func testSensitiveKneeProfileExcludesHighLoad() {
        let sensitiveProfile = UserProfile(
            kneeProfile: .sensitive,
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = WorkoutEngine.generateWeek(for: sensitiveProfile)

        for session in plan.workoutDays {
            for exercise in session.exercises {
                XCTAssertNotEqual(
                    exercise.kneeLoad, .high,
                    "Sensitive profile should not have high knee load exercises, found \(exercise.exerciseName)"
                )
            }
        }
    }

    func testArmFocusedGoalIncreasesArmExercises() {
        let armFocused = UserProfile(
            primaryGoal: .arms,
            kneeProfile: .healthy,
            schedule: WorkoutSchedule(daysPerWeek: 3, minutesPerSession: 30),
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = WorkoutEngine.generateWeek(for: armFocused)

        // At least one session should have 2 arm exercises
        let sessionsWithTwoArmExercises = plan.workoutDays.filter { session in
            let armCount = session.exercises.filter { $0.primaryMuscle.isArmMuscle }.count
            return armCount >= 2
        }

        XCTAssertFalse(sessionsWithTwoArmExercises.isEmpty, "Arm-focused goal should have sessions with 2+ arm exercises")
    }

    func testExercisesRespectEquipment() {
        let bodyweightOnly = UserProfile(
            kneeProfile: .healthy,
            equipment: [.bodyweight]
        )

        let plan = WorkoutEngine.generateWeek(for: bodyweightOnly)

        for session in plan.workoutDays {
            for exercise in session.exercises {
                if let libraryExercise = ExerciseLibrary.exercise(byId: exercise.exerciseId) {
                    XCTAssertTrue(
                        libraryExercise.equipmentRequired.isSubset(of: [.bodyweight]),
                        "Bodyweight-only profile got exercise requiring dumbbells: \(exercise.exerciseName)"
                    )
                }
            }
        }
    }

    func testIsAllowedRespectsConstraints() {
        let restrictedProfile = UserProfile(
            kneeProfile: .restricted,
            equipment: [.bodyweight]
        )

        let squat = ExerciseLibrary.exercise(byId: "bodyweight_squat")!
        XCTAssertFalse(WorkoutEngine.isAllowed(exercise: squat, for: restrictedProfile))

        let gluteBridge = ExerciseLibrary.exercise(byId: "glute_bridge")!
        XCTAssertTrue(WorkoutEngine.isAllowed(exercise: gluteBridge, for: restrictedProfile))

        let dumbbellCurl = ExerciseLibrary.exercise(byId: "dumbbell_curl")!
        XCTAssertFalse(WorkoutEngine.isAllowed(exercise: dumbbellCurl, for: restrictedProfile))
    }

    func testAdjustWithCheckIn() {
        let profile = UserProfile()
        let session = WorkoutEngine.generateSession(for: profile, dayIndex: 1, date: Date())

        let originalSets = session.exercises.first?.targetSets ?? 0

        let lowEnergyCheckIn = PreWorkoutCheckIn(energyLevel: 2, kneePainLevel: 0)
        let adjustedSession = WorkoutEngine.adjust(session: session, with: lowEnergyCheckIn)

        XCTAssertEqual(
            adjustedSession.exercises.first?.targetSets,
            originalSets - 1,
            "Low energy should reduce sets by 1"
        )
        XCTAssertNotNil(adjustedSession.checkIn)
    }

    func testNoAdjustmentForNormalCheckIn() {
        let profile = UserProfile()
        let session = WorkoutEngine.generateSession(for: profile, dayIndex: 1, date: Date())

        let originalSets = session.exercises.first?.targetSets ?? 0

        let normalCheckIn = PreWorkoutCheckIn(energyLevel: 4, kneePainLevel: 0)
        let adjustedSession = WorkoutEngine.adjust(session: session, with: normalCheckIn)

        XCTAssertEqual(
            adjustedSession.exercises.first?.targetSets,
            originalSets,
            "Normal check-in should not reduce sets"
        )
    }

    func testValidationPassesForValidPlan() {
        let profile = UserProfile(
            kneeProfile: .healthy,
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = WorkoutEngine.generateWeek(for: profile)
        let result = WorkoutEngine.validate(plan: plan, for: profile)

        XCTAssertTrue(result.isValid, "Generated plan should be valid: \(result.issues)")
    }

    func testSessionStatistics() {
        let profile = UserProfile(schedule: WorkoutSchedule(minutesPerSession: 30))
        var session = WorkoutEngine.generateSession(for: profile, dayIndex: 1, date: Date())

        let stats = WorkoutEngine.statistics(for: session)

        XCTAssertGreaterThan(stats.exerciseCount, 0)
        XCTAssertGreaterThan(stats.totalSets, 0)
        XCTAssertEqual(stats.completedSets, 0)
        XCTAssertEqual(stats.progress, 0)

        // Complete a set
        session.completeSet(forExerciseAt: 0)
        let updatedStats = WorkoutEngine.statistics(for: session)

        XCTAssertEqual(updatedStats.completedSets, 1)
        XCTAssertGreaterThan(updatedStats.progress, 0)
    }
}

// MARK: - Integration Tests

final class WorkoutEngineIntegrationTests: XCTestCase {

    func testCompleteWorkoutFlow() {
        // 1. Create profile
        let profile = UserProfile(
            name: "Test User",
            primaryGoal: .arms,
            kneeProfile: .sensitive,
            schedule: WorkoutSchedule(daysPerWeek: 3, minutesPerSession: 30),
            equipment: [.bodyweight, .dumbbells]
        )

        // 2. Generate weekly plan
        let plan = WorkoutEngine.generateWeek(for: profile)
        XCTAssertEqual(plan.workoutDays.count, 3)

        // 3. Get today's session
        guard var session = plan.workoutDays.first else {
            XCTFail("No workout session found")
            return
        }

        // 4. Do pre-workout check-in
        let checkIn = PreWorkoutCheckIn(energyLevel: 3, kneePainLevel: 0)
        session = WorkoutEngine.adjust(session: session, with: checkIn)

        // 5. Start workout
        session.start()
        XCTAssertEqual(session.status, .inProgress)

        // 6. Complete all exercises
        for i in 0..<session.exercises.count {
            let targetSets = session.exercises[i].targetSets
            for _ in 0..<targetSets {
                session.completeSet(forExerciseAt: i)
            }
        }

        // 7. Finish workout
        session.complete()
        XCTAssertEqual(session.status, .completed)
        XCTAssertEqual(session.progress, 1.0)
    }

    func testRestrictedUserCanStillWorkout() {
        let profile = UserProfile(
            kneeProfile: .restricted,
            equipment: [.bodyweight]
        )

        let exercises = WorkoutEngine.availableExercises(for: profile)
        XCTAssertFalse(exercises.isEmpty, "Restricted users should still have exercise options")

        let plan = WorkoutEngine.generateWeek(for: profile)
        XCTAssertFalse(plan.workoutDays.isEmpty)

        for session in plan.workoutDays {
            XCTAssertFalse(session.exercises.isEmpty, "Each workout should have exercises")
        }
    }
}
