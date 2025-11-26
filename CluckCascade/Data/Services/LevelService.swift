import Foundation

protocol LevelServicing {
    var levels: [Level] { get }
    func level(for index: Int) -> Level?
}

final class LevelService: LevelServicing {
    private(set) var levels: [Level] = []

    init() {
        levels = LevelService.buildLevels()
    }

    func level(for index: Int) -> Level? {
        guard index >= 0, index < levels.count else { return nil }
        return levels[index]
    }

    private static func buildLevels() -> [Level] {
        let baseObjectives: [LevelObjective] = [
            LevelObjective(type: .gatherEggs, targetCount: 15),
            LevelObjective(type: .clearStraw, targetCount: 8)
        ]

        var constructedLevels: [Level] = []
        var chapter = 0
        var chapterLevelIndex = 0

        for index in 0..<40 {
            if index % 10 == 0 && index > 0 {
                chapter += 1
                chapterLevelIndex = 0
            }

            let difficulty: LevelDifficulty
            switch chapter {
            case 0:
                difficulty = .cozy
            case 1:
                difficulty = .roost
            case 2:
                difficulty = .flock
            default:
                difficulty = .frenzy
            }

            let title = "Puzzle \(index + 1)"
            let description = "Guide the hens through the coop lanes and keep cascades flowing."

            var objectives = baseObjectives
            if chapter >= 1 {
                objectives.append(LevelObjective(type: .chargePower, targetCount: 3))
            }
            if chapter >= 2 {
                objectives.append(LevelObjective(type: .rescueChicks, targetCount: 4))
            }

            let moveLimit = max(18 - chapterLevelIndex, 12)
            let thresholds = [2000, 3500, 5000].map { base in
                base + chapter * 500 + chapterLevelIndex * 80
            }

            let level = Level(
                chapterIndex: chapter,
                levelIndex: index,
                title: title,
                description: description,
                difficulty: difficulty,
                objectives: objectives,
                moveLimit: moveLimit,
                scoreThresholds: thresholds
            )

            constructedLevels.append(level)
            chapterLevelIndex += 1
        }

        return constructedLevels
    }
}



