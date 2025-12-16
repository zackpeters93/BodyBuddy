// WorkoutSession.swift
// Workout session and exercise models for BodyBuddy

import Foundation

// MARK: - Workout Session

/// Represents a single workout on a specific date
public struct WorkoutSession: Codable, Identifiable, Equatable {
    public let id: UUID
    public let date: Date
    public let dayIndex: Int
    public let dayType: DayType
    public var exercises: [WorkoutExercise]
    public var status: WorkoutStatus
    public var checkIn: PreWorkoutCheckIn?
    public var startedAt: Date?
    public var completedAt: Date?
    public var notes: String

    public init(
        id: UUID = UUID(),
        date: Date,
        dayIndex: Int,
        dayType: DayType = .workout,
        exercises: [WorkoutExercise] = [],
        status: WorkoutStatus = .planned,
        checkIn: PreWorkoutCheckIn? = nil,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.dayIndex = dayIndex
        self.dayType = dayType
        self.exercises = exercises
        self.status = status
        self.checkIn = checkIn
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.notes = notes
    }

    /// Returns true if this is a workout day (not a rest day)
    public var isWorkoutDay: Bool {
        dayType == .workout
    }

    /// Returns true if the workout has been completed
    public var isCompleted: Bool {
        status == .completed
    }

    /// Returns true if the workout is in progress
    public var isInProgress: Bool {
        status == .inProgress
    }

    /// Returns the total number of exercises in this session
    public var exerciseCount: Int {
        exercises.count
    }

    /// Returns the number of completed exercises
    public var completedExerciseCount: Int {
        exercises.filter { $0.isCompleted }.count
    }

    /// Returns the overall progress percentage (0.0 to 1.0)
    public var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        let totalSets = exercises.reduce(0) { $0 + $1.targetSets }
        let completedSets = exercises.reduce(0) { $0 + $1.completedSets }
        return Double(completedSets) / Double(totalSets)
    }

    /// Returns the index of the current exercise (first incomplete)
    public var currentExerciseIndex: Int? {
        exercises.firstIndex { !$0.isCompleted }
    }

    /// Returns the current exercise (first incomplete)
    public var currentExercise: WorkoutExercise? {
        guard let index = currentExerciseIndex else { return nil }
        return exercises[index]
    }

    /// Marks a set as completed for the exercise at the given index
    public mutating func completeSet(forExerciseAt index: Int) {
        guard exercises.indices.contains(index) else { return }
        exercises[index].completeSet()
    }

    /// Marks the session as started
    public mutating func start() {
        status = .inProgress
        startedAt = Date()
    }

    /// Marks the session as completed
    public mutating func complete() {
        status = .completed
        completedAt = Date()
    }
}

// MARK: - Workout Exercise

/// Represents a planned exercise within a workout session
public struct WorkoutExercise: Codable, Identifiable, Equatable {
    public let id: UUID
    public let exerciseId: String
    public let exerciseName: String
    public let primaryMuscle: MuscleGroup
    public let kneeLoad: KneeLoadLevel
    public var targetSets: Int
    public let targetReps: String
    public var targetWeight: Double?
    public var completedSetsLog: [SetLog]
    public var kneePainFlagged: Bool

    public init(
        id: UUID = UUID(),
        exerciseId: String,
        exerciseName: String,
        primaryMuscle: MuscleGroup,
        kneeLoad: KneeLoadLevel,
        targetSets: Int = 3,
        targetReps: String = "8-12",
        targetWeight: Double? = nil,
        completedSetsLog: [SetLog] = [],
        kneePainFlagged: Bool = false
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.primaryMuscle = primaryMuscle
        self.kneeLoad = kneeLoad
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.completedSetsLog = completedSetsLog
        self.kneePainFlagged = kneePainFlagged
    }

    /// Convenience initializer from Exercise
    public init(from exercise: Exercise, sets: Int? = nil, weight: Double? = nil) {
        self.id = UUID()
        self.exerciseId = exercise.id
        self.exerciseName = exercise.name
        self.primaryMuscle = exercise.primaryMuscle
        self.kneeLoad = exercise.kneeLoad
        self.targetSets = sets ?? exercise.defaultSets
        self.targetReps = exercise.defaultReps
        self.targetWeight = weight
        self.completedSetsLog = []
        self.kneePainFlagged = false
    }

    /// Returns the number of completed sets
    public var completedSets: Int {
        completedSetsLog.count
    }

    /// Returns true if all target sets have been completed
    public var isCompleted: Bool {
        completedSets >= targetSets
    }

    /// Returns the current set number (1-based)
    public var currentSetNumber: Int {
        min(completedSets + 1, targetSets)
    }

    /// Returns the progress percentage (0.0 to 1.0)
    public var progress: Double {
        guard targetSets > 0 else { return 0 }
        return Double(completedSets) / Double(targetSets)
    }

    /// Completes the current set with optional rep and weight data
    public mutating func completeSet(reps: Int? = nil, weight: Double? = nil) {
        guard !isCompleted else { return }
        let log = SetLog(
            setNumber: currentSetNumber,
            reps: reps,
            weight: weight ?? targetWeight,
            completedAt: Date()
        )
        completedSetsLog.append(log)
    }

    /// Flags or unflags knee pain for this exercise
    public mutating func toggleKneePainFlag() {
        kneePainFlagged.toggle()
    }

    /// Reduces target sets by the given amount (minimum 1)
    public mutating func reduceSets(by amount: Int) {
        targetSets = max(1, targetSets - amount)
    }
}

// MARK: - Set Log

/// Represents a completed set within an exercise
public struct SetLog: Codable, Identifiable, Equatable {
    public let id: UUID
    public let setNumber: Int
    public let reps: Int?
    public let weight: Double?
    public let completedAt: Date

    public init(
        id: UUID = UUID(),
        setNumber: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.completedAt = completedAt
    }
}

// MARK: - Weekly Plan

/// Represents a week's worth of workout sessions
public struct WeeklyPlan: Codable, Identifiable, Equatable {
    public let id: UUID
    public let weekStartDate: Date
    public var sessions: [WorkoutSession]
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        weekStartDate: Date,
        sessions: [WorkoutSession] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.sessions = sessions
        self.createdAt = createdAt
    }

    /// Returns the session for today, if any
    public func sessionForToday() -> WorkoutSession? {
        let calendar = Calendar.current
        return sessions.first { calendar.isDateInToday($0.date) }
    }

    /// Returns the session for a specific date
    public func session(for date: Date) -> WorkoutSession? {
        let calendar = Calendar.current
        return sessions.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// Returns all workout days (excluding rest days)
    public var workoutDays: [WorkoutSession] {
        sessions.filter { $0.isWorkoutDay }
    }

    /// Returns the number of completed workouts
    public var completedWorkouts: Int {
        workoutDays.filter { $0.isCompleted }.count
    }

    /// Returns the total number of planned workouts
    public var plannedWorkouts: Int {
        workoutDays.count
    }
}
