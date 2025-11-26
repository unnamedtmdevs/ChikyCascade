import Foundation

struct GameSession: Identifiable, Codable {
    let id: UUID
    var level: Level
    var mode: GameMode
    var board: [[CoopTile]]
    var remainingMoves: Int
    var score: Int
    var comboMultiplier: Int
    var collectedFeathers: Int
    var powerCharge: Double
    var cascadesTriggered: Int
    var objectiveProgress: [LevelObjective.ObjectiveType: Int]
    var startDate: Date
    var lastClearedPositions: Set<TilePosition>

    init(
        id: UUID = UUID(),
        level: Level,
        mode: GameMode = .freePlay,
        board: [[CoopTile]],
        remainingMoves: Int,
        score: Int = 0,
        comboMultiplier: Int = 1,
        collectedFeathers: Int = 0,
        powerCharge: Double = 0,
        cascadesTriggered: Int = 0,
        objectiveProgress: [LevelObjective.ObjectiveType: Int] = [:],
        startDate: Date = Date(),
        lastClearedPositions: Set<TilePosition> = []
    ) {
        self.id = id
        self.level = level
        self.mode = mode
        self.board = board
        self.remainingMoves = remainingMoves
        self.score = score
        self.comboMultiplier = comboMultiplier
        self.collectedFeathers = collectedFeathers
        self.powerCharge = powerCharge
        self.cascadesTriggered = cascadesTriggered
        self.objectiveProgress = objectiveProgress
        self.startDate = startDate
        self.lastClearedPositions = lastClearedPositions
    }

    private enum CodingKeys: String, CodingKey {
        case id, level, mode, board, remainingMoves, score, comboMultiplier, collectedFeathers, powerCharge, cascadesTriggered, objectiveProgress, startDate, lastClearedPositions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        level = try container.decode(Level.self, forKey: .level)
        mode = try container.decodeIfPresent(GameMode.self, forKey: .mode) ?? .freePlay
        board = try container.decode([[CoopTile]].self, forKey: .board)
        remainingMoves = try container.decode(Int.self, forKey: .remainingMoves)
        score = try container.decode(Int.self, forKey: .score)
        comboMultiplier = try container.decode(Int.self, forKey: .comboMultiplier)
        collectedFeathers = try container.decode(Int.self, forKey: .collectedFeathers)
        powerCharge = try container.decode(Double.self, forKey: .powerCharge)
        cascadesTriggered = try container.decode(Int.self, forKey: .cascadesTriggered)
        objectiveProgress = try container.decode([LevelObjective.ObjectiveType: Int].self, forKey: .objectiveProgress)
        startDate = try container.decode(Date.self, forKey: .startDate)
        lastClearedPositions = try container.decodeIfPresent(Set<TilePosition>.self, forKey: .lastClearedPositions) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(level, forKey: .level)
        try container.encode(mode, forKey: .mode)
        try container.encode(board, forKey: .board)
        try container.encode(remainingMoves, forKey: .remainingMoves)
        try container.encode(score, forKey: .score)
        try container.encode(comboMultiplier, forKey: .comboMultiplier)
        try container.encode(collectedFeathers, forKey: .collectedFeathers)
        try container.encode(powerCharge, forKey: .powerCharge)
        try container.encode(cascadesTriggered, forKey: .cascadesTriggered)
        try container.encode(objectiveProgress, forKey: .objectiveProgress)
        try container.encode(startDate, forKey: .startDate)
        if !lastClearedPositions.isEmpty {
            try container.encode(lastClearedPositions, forKey: .lastClearedPositions)
        }
    }
}
