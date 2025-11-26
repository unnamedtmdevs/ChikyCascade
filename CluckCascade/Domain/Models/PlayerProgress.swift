import Foundation

struct LevelCompletion: Codable, Equatable {
    var levelID: UUID
    var bestScore: Int
    var bestFeatherCount: Int
    var bestMovesRemaining: Int
    var completionDate: Date
}

struct PlayerProgress: Codable {
    var currentLevelIndex: Int
    var completedLevels: [LevelCompletion]
    var totalFeathers: Int
    var dailyStreak: Int
    var longestCombo: Int
    var deepestCascade: Int
    var totalPlayTime: TimeInterval

    static let initial = PlayerProgress(
        currentLevelIndex: 0,
        completedLevels: [],
        totalFeathers: 0,
        dailyStreak: 0,
        longestCombo: 0,
        deepestCascade: 0,
        totalPlayTime: 0
    )
}



