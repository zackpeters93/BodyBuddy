// Exercise.swift
// Exercise definition model for BodyBuddy

import Foundation

/// Represents a specific exercise movement in the exercise library
public struct Exercise: Codable, Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let primaryMuscle: MuscleGroup
    public let secondaryMuscles: [MuscleGroup]
    public let kneeLoad: KneeLoadLevel
    public let equipmentRequired: Set<EquipmentType>
    public let exerciseType: ExerciseType
    public let defaultSets: Int
    public let defaultReps: String
    public let instructions: String

    public init(
        id: String,
        name: String,
        primaryMuscle: MuscleGroup,
        secondaryMuscles: [MuscleGroup] = [],
        kneeLoad: KneeLoadLevel,
        equipmentRequired: Set<EquipmentType>,
        exerciseType: ExerciseType,
        defaultSets: Int = 3,
        defaultReps: String = "8-12",
        instructions: String = ""
    ) {
        self.id = id
        self.name = name
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles
        self.kneeLoad = kneeLoad
        self.equipmentRequired = equipmentRequired
        self.exerciseType = exerciseType
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.instructions = instructions
    }

    /// Returns true if this is an arm exercise (biceps or triceps)
    public var isArmExercise: Bool {
        primaryMuscle.isArmMuscle
    }

    /// Returns true if the exercise is compound (multi-joint)
    public var isCompound: Bool {
        exerciseType == .compound
    }

    /// Returns true if the exercise can be performed with the given equipment
    public func canPerformWith(equipment: Set<EquipmentType>) -> Bool {
        equipmentRequired.isSubset(of: equipment)
    }

    /// Returns true if the exercise is allowed for the given knee profile
    public func isAllowedFor(kneeProfile: KneeProfile) -> Bool {
        kneeProfile.allowedKneeLoadLevels.contains(kneeLoad)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Codable Conformance for Set<EquipmentType>

extension Exercise {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case primaryMuscle
        case secondaryMuscles
        case kneeLoad
        case equipmentRequired
        case exerciseType
        case defaultSets
        case defaultReps
        case instructions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        primaryMuscle = try container.decode(MuscleGroup.self, forKey: .primaryMuscle)
        secondaryMuscles = try container.decodeIfPresent([MuscleGroup].self, forKey: .secondaryMuscles) ?? []
        kneeLoad = try container.decode(KneeLoadLevel.self, forKey: .kneeLoad)
        let equipmentArray = try container.decode([EquipmentType].self, forKey: .equipmentRequired)
        equipmentRequired = Set(equipmentArray)
        exerciseType = try container.decode(ExerciseType.self, forKey: .exerciseType)
        defaultSets = try container.decodeIfPresent(Int.self, forKey: .defaultSets) ?? 3
        defaultReps = try container.decodeIfPresent(String.self, forKey: .defaultReps) ?? "8-12"
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions) ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(primaryMuscle, forKey: .primaryMuscle)
        try container.encode(secondaryMuscles, forKey: .secondaryMuscles)
        try container.encode(kneeLoad, forKey: .kneeLoad)
        try container.encode(Array(equipmentRequired), forKey: .equipmentRequired)
        try container.encode(exerciseType, forKey: .exerciseType)
        try container.encode(defaultSets, forKey: .defaultSets)
        try container.encode(defaultReps, forKey: .defaultReps)
        try container.encode(instructions, forKey: .instructions)
    }
}
