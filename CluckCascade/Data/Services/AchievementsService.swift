import Foundation

protocol AchievementsServicing {
    func evaluate(progress: PlayerProgress, existing: [Achievement]) -> [Achievement]
}

final class AchievementsService: AchievementsServicing {
    private struct Definition {
        let id: UUID
        let title: String
        let description: String
        let category: Achievement.Category
        let iconName: String
        let requirement: (PlayerProgress) -> Bool
    }

    private let definitions: [Definition]
    private let dateProvider: () -> Date

    init(dateProvider: @escaping () -> Date = Date.init) {
        self.dateProvider = dateProvider
        self.definitions = [
            Definition(
                id: UUID(uuidString: "5B30ED4B-82E9-46C6-846B-0638C407F412")!,
                title: "Feather Collector",
                description: "Earn 1,000 feathers across puzzles.",
                category: .collection,
                iconName: "leaf.fill"
            ) { progress in
                progress.totalFeathers >= 1_000
            },
            Definition(
                id: UUID(uuidString: "7F9E42DF-8CF3-45C7-948C-9B0E9C414B8C")!,
                title: "Feather Tycoon",
                description: "Accumulate 10,000 feathers across your career.",
                category: .collection,
                iconName: "coins"
            ) { progress in
                progress.totalFeathers >= 10_000
            },
            Definition(
                id: UUID(uuidString: "4B03D091-0CB2-4FD1-880F-ADFBC7A78039")!,
                title: "Cascade Maestro",
                description: "Trigger a five-step cascade in one puzzle.",
                category: .skill,
                iconName: "waveform.path.ecg"
            ) { progress in
                progress.deepestCascade >= 5
            },
            Definition(
                id: UUID(uuidString: "C787C7E2-518A-49EE-A6D2-7A9F51B7F5C4")!,
                title: "Combo Conductor",
                description: "Chain seven cascades in a single match.",
                category: .skill,
                iconName: "sparkles"
            ) { progress in
                progress.longestCombo >= 7
            },
            Definition(
                id: UUID(uuidString: "3F6B9DD5-95F1-41B4-BC92-9F609F8D0C82")!,
                title: "Tempo Chaser",
                description: "Score 25,000 points in a Time Attack run.",
                category: .skill,
                iconName: "timer"
            ) { progress in
                Self.bestScore(for: GameMode.timeAttack.persistenceID, in: progress) >= 25_000
            },
            Definition(
                id: UUID(uuidString: "4CA7A383-7D5A-4F8C-A754-71FAD88856F7")!,
                title: "Move Maestro",
                description: "Reach 15,000 points in a Move Challenge session.",
                category: .progression,
                iconName: "target"
            ) { progress in
                Self.bestScore(for: GameMode.moveChallenge.persistenceID, in: progress) >= 15_000
            },
            Definition(
                id: UUID(uuidString: "D9A4C9F0-5B58-489F-9C0C-2A67B1C1244E")!,
                title: "Streak Guardian",
                description: "Keep a seven-day streak alive.",
                category: .streak,
                iconName: "calendar"
            ) { progress in
                progress.dailyStreak >= 7
            },
            Definition(
                id: UUID(uuidString: "E53F4355-4970-4F6E-AD05-716B4C559F2E")!,
                title: "Marathon Runner",
                description: "Play for three consecutive hours in a single day.",
                category: .streak,
                iconName: "figure.run"
            ) { progress in
                progress.totalPlayTime >= 10_800
            }
        ]
    }

    func evaluate(progress: PlayerProgress, existing: [Achievement]) -> [Achievement] {
        let existingMap = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
        let now = dateProvider()

        return definitions.map { definition in
            let previouslyUnlockedDate = existingMap[definition.id]?.unlockedDate
            let meetsRequirement = definition.requirement(progress)
            let unlockedDate: Date?

            if let priorDate = previouslyUnlockedDate {
                unlockedDate = priorDate
            } else if meetsRequirement {
                unlockedDate = now
            } else {
                unlockedDate = nil
            }

            return Achievement(
                id: definition.id,
                title: definition.title,
                description: definition.description,
                category: definition.category,
                iconName: definition.iconName,
                unlockedDate: unlockedDate
            )
        }
    }

    private static func bestScore(for levelID: UUID, in progress: PlayerProgress) -> Int {
        progress.completedLevels
            .first(where: { $0.levelID == levelID })?
            .bestScore ?? 0
    }
}
