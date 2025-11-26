import Foundation

struct BoostMilestones: Codable {
    var streakMilestone: Int
    var featherMilestone: Int
}

enum BoostType: String, Codable, CaseIterable {
    case powerSurge
    case rowSweep
    case boardShuffle
    case coopHammer

    var title: String {
        switch self {
        case .powerSurge: return "Power Surge"
        case .rowSweep: return "Row Sweep"
        case .boardShuffle: return "Board Shuffle"
        case .coopHammer: return "Coop Hammer"
        }
    }

    var description: String {
        switch self {
        case .powerSurge:
            return "Instantly charge the coop meter by 50% to unleash big combos sooner."
        case .rowSweep:
            return "Clear a full row of tiles to open space for new cascades."
        case .boardShuffle:
            return "Remix the board when moves feel stuck—keeps objectives fresh."
        case .coopHammer:
            return "Smash a single tile and upgrade it into a gleaming golden egg wild."
        }
    }

    var iconName: String {
        switch self {
        case .powerSurge: return "bolt.circle"
        case .rowSweep: return "line.3.horizontal.decrease.circle"
        case .boardShuffle: return "arrow.triangle.2.circlepath.circle"
        case .coopHammer: return "hammer"
        }
    }

    var price: Int {
        switch self {
        case .powerSurge: return 280
        case .rowSweep: return 360
        case .boardShuffle: return 420
        case .coopHammer: return 300
        }
    }
}

struct Boost: Identifiable, Codable, Equatable {
    let id: UUID
    var type: BoostType
    var availableCount: Int

    init(id: UUID = UUID(), type: BoostType, availableCount: Int) {
        self.id = id
        self.type = type
        self.availableCount = availableCount
    }
}

struct BoostUsage: Identifiable, Codable {
    let id: UUID
    var type: BoostType
    var date: Date
    var context: String
}

protocol BoostsServicing {
    var boosts: [Boost] { get }
    var usageHistory: [BoostUsage] { get }
    func refreshInventory(progress: PlayerProgress)
    func price(for type: BoostType) -> Int
    func canPurchase(_ type: BoostType, feathers: Int) -> Bool
    func addBoost(_ type: BoostType) -> Bool
    func consumeBoost(of type: BoostType) -> Bool
    func refundBoost(of type: BoostType)
    func recordUsage(of type: BoostType, context: String)
}

final class BoostsService: ObservableObject, BoostsServicing {
    @Published private(set) var boosts: [Boost]
    @Published private(set) var usageHistory: [BoostUsage]

    private let storage: StorageServicing
    private var milestones: BoostMilestones

    init(storage: StorageServicing) {
        self.storage = storage
        let storedBoosts = storage.value(forKey: UserDefaultsKeys.availableBoosts, default: BoostsService.defaultBoosts)
        self.boosts = BoostsService.ensureAllBoostTypesPresent(in: storedBoosts)
        self.usageHistory = storage.value(forKey: UserDefaultsKeys.boostUsageHistory, default: [])
        self.milestones = storage.value(forKey: UserDefaultsKeys.boostMilestones, default: BoostMilestones(streakMilestone: 0, featherMilestone: 0))
    }

    func refreshInventory(progress: PlayerProgress) {
        var updated = boosts

        let streakMilestone = progress.dailyStreak / 3
        if streakMilestone > milestones.streakMilestone {
            let rewardCount = streakMilestone - milestones.streakMilestone
            for _ in 0..<rewardCount {
                updated = updated.map { boost in
                    var copy = boost
                    copy.availableCount += 1
                    return copy
                }
            }
            milestones.streakMilestone = streakMilestone
        }

        let featherMilestone = progress.totalFeathers / 500
        if featherMilestone > milestones.featherMilestone {
            let rewardCount = featherMilestone - milestones.featherMilestone
            for _ in 0..<rewardCount {
                updated = updated.map { boost in
                    var copy = boost
                    copy.availableCount = min(copy.availableCount + 1, 5)
                    return copy
                }
            }
            milestones.featherMilestone = featherMilestone
        }

        updated = BoostsService.ensureAllBoostTypesPresent(in: updated)
        boosts = updated
        storage.set(updated, forKey: UserDefaultsKeys.availableBoosts)
        storage.set(milestones, forKey: UserDefaultsKeys.boostMilestones)
    }

    func price(for type: BoostType) -> Int {
        type.price
    }

    func canPurchase(_ type: BoostType, feathers: Int) -> Bool {
        let cost = type.price
        guard cost > 0 else { return false }
        guard let boost = boosts.first(where: { $0.type == type }) else { return feathers >= cost }
        return boost.availableCount < 5 && feathers >= cost
    }

    func addBoost(_ type: BoostType) -> Bool {
        var updated = boosts
        if let index = updated.firstIndex(where: { $0.type == type }) {
            guard updated[index].availableCount < 5 else { return false }
            updated[index].availableCount += 1
        } else {
            updated.append(Boost(type: type, availableCount: 1))
        }
        updated = BoostsService.ensureAllBoostTypesPresent(in: updated)
        boosts = updated
        storage.set(updated, forKey: UserDefaultsKeys.availableBoosts)
        return true
    }

    func consumeBoost(of type: BoostType) -> Bool {
        guard let index = boosts.firstIndex(where: { $0.type == type }), boosts[index].availableCount > 0 else {
            return false
        }

        var updated = boosts
        updated[index].availableCount -= 1
        updated = BoostsService.ensureAllBoostTypesPresent(in: updated)
        boosts = updated
        storage.set(updated, forKey: UserDefaultsKeys.availableBoosts)
        return true
    }

    func refundBoost(of type: BoostType) {
        guard let index = boosts.firstIndex(where: { $0.type == type }) else { return }
        var updated = boosts
        updated[index].availableCount += 1
        updated = BoostsService.ensureAllBoostTypesPresent(in: updated)
        boosts = updated
        storage.set(updated, forKey: UserDefaultsKeys.availableBoosts)
    }

    func recordUsage(of type: BoostType, context: String) {
        var history = usageHistory
        let entry = BoostUsage(id: UUID(), type: type, date: Date(), context: context)
        history.insert(entry, at: 0)
        usageHistory = Array(history.prefix(30))
        storage.set(usageHistory, forKey: UserDefaultsKeys.boostUsageHistory)
    }


    private static func ensureAllBoostTypesPresent(in list: [Boost]) -> [Boost] {
        var inventory = Dictionary(uniqueKeysWithValues: list.map { ($0.type, $0) })
        for type in BoostType.allCases where inventory[type] == nil {
            inventory[type] = Boost(type: type, availableCount: 0)
        }
        return BoostType.allCases.map { inventory[$0]! }
    }

    func reset() {
        boosts = BoostsService.ensureAllBoostTypesPresent(in: BoostsService.defaultBoosts)
        usageHistory = []
        milestones = BoostMilestones(streakMilestone: 0, featherMilestone: 0)
        storage.set(boosts, forKey: UserDefaultsKeys.availableBoosts)
        storage.set(usageHistory, forKey: UserDefaultsKeys.boostUsageHistory)
        storage.set(milestones, forKey: UserDefaultsKeys.boostMilestones)
    }

    private static var defaultBoosts: [Boost] {
        [
            Boost(type: .powerSurge, availableCount: 3),
            Boost(type: .rowSweep, availableCount: 2),
            Boost(type: .boardShuffle, availableCount: 1),
            Boost(type: .coopHammer, availableCount: 2)
        ]
    }
}
