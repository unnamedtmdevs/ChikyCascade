import Foundation

enum LevelDifficulty: String, Codable, CaseIterable {
    case cozy
    case roost
    case flock
    case frenzy
}

struct LevelObjective: Codable, Equatable {
    enum ObjectiveType: String, Codable {
        case gatherEggs
        case clearStraw
        case chargePower
        case rescueChicks
    }

    var type: ObjectiveType
    var targetCount: Int
}

struct Level: Identifiable, Codable, Equatable {
    let id: UUID
    var chapterIndex: Int
    var levelIndex: Int
    var title: String
    var description: String
    var difficulty: LevelDifficulty
    var objectives: [LevelObjective]
    var moveLimit: Int
    var scoreThresholds: [Int]

    init(
        id: UUID = UUID(),
        chapterIndex: Int,
        levelIndex: Int,
        title: String,
        description: String,
        difficulty: LevelDifficulty,
        objectives: [LevelObjective],
        moveLimit: Int,
        scoreThresholds: [Int]
    ) {
        self.id = id
        self.chapterIndex = chapterIndex
        self.levelIndex = levelIndex
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.objectives = objectives
        self.moveLimit = moveLimit
        self.scoreThresholds = scoreThresholds
    }
}



