import XCTest
@testable import BodyBuddyCore

// MARK: - JSONDataStore Tests

final class JSONDataStoreTests: XCTestCase {

    var store: JSONDataStore!
    var testDirectory: URL!

    override func setUp() {
        super.setUp()
        // Create a unique test directory for each test
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BodyBuddyTests-\(UUID().uuidString)")
        store = JSONDataStore(directory: testDirectory)
    }

    override func tearDown() {
        // Clean up test directory
        try? FileManager.default.removeItem(at: testDirectory)
        super.tearDown()
    }

    // MARK: - Profile Tests

    func testSaveAndLoadProfile() throws {
        let profile = UserProfile(
            name: "Test User",
            primaryGoal: .arms,
            kneeProfile: .sensitive,
            schedule: WorkoutSchedule(daysPerWeek: 3, minutesPerSession: 30),
            equipment: [.bodyweight, .dumbbells]
        )

        try store.saveProfile(profile)
        let loaded = try store.loadProfile()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, profile.id)
        XCTAssertEqual(loaded?.name, profile.name)
        XCTAssertEqual(loaded?.primaryGoal, profile.primaryGoal)
        XCTAssertEqual(loaded?.kneeProfile, profile.kneeProfile)
        XCTAssertEqual(loaded?.equipment, profile.equipment)
    }

    func testLoadProfileReturnsNilWhenEmpty() throws {
        let loaded = try store.loadProfile()
        XCTAssertNil(loaded)
    }

    func testHasProfile() throws {
        XCTAssertFalse(store.hasProfile())

        try store.saveProfile(UserProfile())

        XCTAssertTrue(store.hasProfile())
    }

    func testDeleteProfile() throws {
        try store.saveProfile(UserProfile())
        XCTAssertTrue(store.hasProfile())

        try store.deleteProfile()
        XCTAssertFalse(store.hasProfile())
    }

    func testIsOnboardingComplete() throws {
        XCTAssertFalse(store.isOnboardingComplete())

        try store.saveProfile(UserProfile())

        XCTAssertTrue(store.isOnboardingComplete())
    }

    // MARK: - Weekly Plan Tests

    func testSaveAndLoadWeeklyPlan() throws {
        let profile = UserProfile(
            kneeProfile: .healthy,
            equipment: [.bodyweight, .dumbbells]
        )
        let plan = WorkoutEngine.generateWeek(for: profile)

        try store.saveWeeklyPlan(plan)
        let loaded = try store.loadWeeklyPlan()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, plan.id)
        XCTAssertEqual(loaded?.sessions.count, plan.sessions.count)
    }

    func testLoadWeeklyPlanReturnsNilWhenEmpty() throws {
        let loaded = try store.loadWeeklyPlan()
        XCTAssertNil(loaded)
    }

    func testDeleteWeeklyPlan() throws {
        let plan = WeeklyPlan(weekStartDate: Date(), sessions: [])
        try store.saveWeeklyPlan(plan)

        let loaded1 = try store.loadWeeklyPlan()
        XCTAssertNotNil(loaded1)

        try store.deleteWeeklyPlan()

        let loaded2 = try store.loadWeeklyPlan()
        XCTAssertNil(loaded2)
    }

    // MARK: - Session Tests

    func testSaveAndLoadSession() throws {
        let session = WorkoutSession(
            date: Date(),
            dayIndex: 1,
            exercises: [
                WorkoutExercise(
                    exerciseId: "pushup",
                    exerciseName: "Push-Up",
                    primaryMuscle: .chest,
                    kneeLoad: .low,
                    targetSets: 3
                )
            ]
        )

        try store.saveSession(session)
        let loaded = try store.loadSession(id: session.id)

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.id, session.id)
        XCTAssertEqual(loaded?.exercises.count, 1)
    }

    func testLoadAllSessions() throws {
        let session1 = WorkoutSession(date: Date(), dayIndex: 1)
        let session2 = WorkoutSession(date: Date(), dayIndex: 2)

        try store.saveSession(session1)
        try store.saveSession(session2)

        let all = try store.loadAllSessions()
        XCTAssertEqual(all.count, 2)
    }

    func testUpdateExistingSession() throws {
        var session = WorkoutSession(
            date: Date(),
            dayIndex: 1,
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

        try store.saveSession(session)

        // Update the session
        session.status = .completed
        try store.saveSession(session)

        let loaded = try store.loadSession(id: session.id)
        XCTAssertEqual(loaded?.status, .completed)

        // Should still only have one session
        let all = try store.loadAllSessions()
        XCTAssertEqual(all.count, 1)
    }

    // MARK: - App State Tests

    func testSaveAndLoadCurrentSessionId() throws {
        let sessionId = UUID()

        try store.saveCurrentSessionId(sessionId)
        let loaded = try store.loadCurrentSessionId()

        XCTAssertEqual(loaded, sessionId)
    }

    func testClearCurrentSessionId() throws {
        let sessionId = UUID()
        try store.saveCurrentSessionId(sessionId)

        try store.saveCurrentSessionId(nil)
        let loaded = try store.loadCurrentSessionId()

        XCTAssertNil(loaded)
    }

    // MARK: - Reset Tests

    func testDeleteAllData() throws {
        // Save some data
        try store.saveProfile(UserProfile())
        let plan = WeeklyPlan(weekStartDate: Date(), sessions: [])
        try store.saveWeeklyPlan(plan)
        try store.saveSession(WorkoutSession(date: Date(), dayIndex: 1))
        try store.saveCurrentSessionId(UUID())

        // Verify data exists
        XCTAssertNotNil(try store.loadProfile())
        XCTAssertNotNil(try store.loadWeeklyPlan())
        XCTAssertFalse(try store.loadAllSessions().isEmpty)
        XCTAssertNotNil(try store.loadCurrentSessionId())

        // Delete all
        try store.deleteAllData()

        // Verify all data is gone
        XCTAssertNil(try store.loadProfile())
        XCTAssertNil(try store.loadWeeklyPlan())
        XCTAssertTrue(try store.loadAllSessions().isEmpty)
        XCTAssertNil(try store.loadCurrentSessionId())
    }

    // MARK: - Convenience Method Tests

    func testSaveProfileAndGeneratePlan() throws {
        let profile = UserProfile(
            primaryGoal: .arms,
            kneeProfile: .sensitive,
            schedule: WorkoutSchedule(daysPerWeek: 3),
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = try store.saveProfileAndGeneratePlan(profile)

        XCTAssertEqual(plan.workoutDays.count, 3)

        // Verify both were saved
        XCTAssertNotNil(try store.loadProfile())
        XCTAssertNotNil(try store.loadWeeklyPlan())
    }

    func testUpdateSessionInPlan() throws {
        let profile = UserProfile(equipment: [.bodyweight, .dumbbells])
        _ = try store.saveProfileAndGeneratePlan(profile)

        var plan = try store.loadWeeklyPlan()!
        var session = plan.workoutDays.first!

        // Complete a set
        session.completeSet(forExerciseAt: 0)
        try store.updateSessionInPlan(session)

        // Reload and verify
        let updatedPlan = try store.loadWeeklyPlan()!
        let updatedSession = updatedPlan.sessions.first { $0.id == session.id }

        XCTAssertEqual(updatedSession?.exercises.first?.completedSets, 1)
    }

    func testStorageSize() throws {
        // Empty storage should be 0
        XCTAssertEqual(store.storageSize(), 0)

        // Save some data
        try store.saveProfile(UserProfile(name: "Test User with some data"))

        // Should have non-zero size now
        XCTAssertGreaterThan(store.storageSize(), 0)
    }

    // MARK: - Error Handling Tests

    func testLoadFromCorruptedFile() throws {
        // Write invalid JSON to the profile file
        let profileURL = testDirectory.appendingPathComponent("profile.json")
        try FileManager.default.createDirectory(
            at: testDirectory,
            withIntermediateDirectories: true
        )
        try "{ invalid json }".write(to: profileURL, atomically: true, encoding: .utf8)

        // Should throw a decoding error
        XCTAssertThrowsError(try store.loadProfile()) { error in
            if case DataStoreError.decodingFailed = error {
                // Expected error type
            } else {
                XCTFail("Expected decodingFailed error, got \(error)")
            }
        }
    }

    // MARK: - Persistence Tests

    func testDataPersistsAcrossStoreInstances() throws {
        let profile = UserProfile(name: "Persistent User", primaryGoal: .strength)

        try store.saveProfile(profile)

        // Create a new store instance pointing to the same directory
        let newStore = JSONDataStore(directory: testDirectory)

        let loaded = try newStore.loadProfile()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.name, "Persistent User")
        XCTAssertEqual(loaded?.primaryGoal, .strength)
    }
}

// MARK: - Integration Tests

final class DataStoreIntegrationTests: XCTestCase {

    var store: JSONDataStore!
    var testDirectory: URL!

    override func setUp() {
        super.setUp()
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BodyBuddyIntegrationTests-\(UUID().uuidString)")
        store = JSONDataStore(directory: testDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testDirectory)
        super.tearDown()
    }

    func testCompleteUserJourney() throws {
        // 1. New user - no profile
        XCTAssertFalse(store.isOnboardingComplete())

        // 2. Complete onboarding
        let profile = UserProfile(
            name: "Zack",
            primaryGoal: .arms,
            kneeProfile: .sensitive,
            schedule: WorkoutSchedule(daysPerWeek: 3, minutesPerSession: 30),
            equipment: [.bodyweight, .dumbbells]
        )

        let plan = try store.saveProfileAndGeneratePlan(profile)
        XCTAssertTrue(store.isOnboardingComplete())
        XCTAssertEqual(plan.workoutDays.count, 3)

        // 3. Start a workout
        var session = plan.workoutDays.first!
        session.start()
        try store.saveCurrentSessionId(session.id)
        try store.updateSessionInPlan(session)

        // 4. Complete sets
        for i in 0..<session.exercises.count {
            for _ in 0..<session.exercises[i].targetSets {
                session.completeSet(forExerciseAt: i)
            }
        }

        // 5. Finish workout
        session.complete()
        try store.saveCurrentSessionId(nil)
        try store.updateSessionInPlan(session)

        // 6. Verify workout was saved
        let updatedPlan = try store.loadWeeklyPlan()!
        let completedSession = updatedPlan.sessions.first { $0.id == session.id }
        XCTAssertEqual(completedSession?.status, .completed)

        // 7. Check session history
        let history = try store.loadAllSessions()
        XCTAssertFalse(history.isEmpty)

        // 8. Reset app
        try store.resetApp()
        XCTAssertFalse(store.isOnboardingComplete())
    }

    func testMidWorkoutPersistence() throws {
        // Setup
        let profile = UserProfile(equipment: [.bodyweight])
        let plan = try store.saveProfileAndGeneratePlan(profile)

        var session = plan.workoutDays.first!
        session.start()

        // Complete some sets
        session.completeSet(forExerciseAt: 0)
        session.completeSet(forExerciseAt: 0)

        // Save mid-workout state
        try store.saveCurrentSessionId(session.id)
        try store.updateSessionInPlan(session)

        // Simulate app restart with new store instance
        let newStore = JSONDataStore(directory: testDirectory)

        // Resume workout
        let currentId = try newStore.loadCurrentSessionId()
        XCTAssertEqual(currentId, session.id)

        let loadedPlan = try newStore.loadWeeklyPlan()!
        let resumedSession = loadedPlan.sessions.first { $0.id == session.id }

        XCTAssertEqual(resumedSession?.exercises.first?.completedSets, 2)
        XCTAssertEqual(resumedSession?.status, .inProgress)
    }
}
