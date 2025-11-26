
import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case freePlay
    case timeAttack
    case moveChallenge

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .freePlay: return "Free Play"
        case .timeAttack: return "Time Attack"
        case .moveChallenge: return "Move Challenge"
        }
    }

    var description: String {
        switch self {
        case .freePlay:
            return "Settle into cosy cascades with no limits or pressure."
        case .timeAttack:
            return "Stack hefty combos before the coop timer winds down."
        case .moveChallenge:
            return "Plan every swap carefully to squeeze the highest score."
        }
    }

    var iconName: String {
        switch self {
        case .freePlay: return "infinity"
        case .timeAttack: return "timer"
        case .moveChallenge: return "target"
        }
    }

    var persistenceID: UUID {
        switch self {
        case .freePlay:
            return UUID(uuidString: "6D6D1412-6D47-4D81-AEB0-8D7A07B9A2A0") ?? UUID()
        case .timeAttack:
            return UUID(uuidString: "D93BE4A0-0834-4CF5-A64A-67F4AE5280CF") ?? UUID()
        case .moveChallenge:
            return UUID(uuidString: "91F5D93A-5A7D-47AB-A5CD-3A91A9A8C2E1") ?? UUID()
        }
    }

    var consumesMoves: Bool {
        switch self {
        case .moveChallenge: return true
        case .freePlay, .timeAttack: return false
        }
    }

    var defaultMoveLimit: Int? {
        switch self {
        case .moveChallenge: return 25
        default: return nil
        }
    }

    var timeLimit: Int? {
        switch self {
        case .timeAttack: return 90
        default: return nil
        }
    }

    var sessionTagline: String {
        switch self {
        case .freePlay: return "Relaxed cascades. Experiment with tiles."
        case .timeAttack: return "Score as much as you can before the timer buzzes."
        case .moveChallenge: return "Finite swaps – every move matters."
        }
    }

    var pauseTitle: String {
        switch self {
        case .freePlay: return "Free Play Paused"
        case .timeAttack: return "Time Attack Paused"
        case .moveChallenge: return "Challenge Paused"
        }
    }

    var restartTitle: String {
        switch self {
        case .freePlay: return "Restart Free Play"
        case .timeAttack: return "Restart Time Attack"
        case .moveChallenge: return "Restart Challenge"
        }
    }

    var exitTitle: String {
        switch self {
        case .freePlay: return "End Session"
        case .timeAttack: return "End Session"
        case .moveChallenge: return "End Session"
        }
    }

    var resultTitleVictory: String {
        switch self {
        case .freePlay: return "Free Play Summary"
        case .timeAttack: return "Time Attack Complete"
        case .moveChallenge: return "Challenge Complete"
        }
    }

    var resultTitleDefeat: String {
        switch self {
        case .freePlay: return "Session Ended"
        case .timeAttack: return "Timer Ended"
        case .moveChallenge: return "Session Ended"
        }
    }

    var badgeText: String? {
        switch self {
        case .freePlay: return "Relaxed"
        case .timeAttack:
            if let limit = timeLimit { return "\(limit)s" } else { return nil }
        case .moveChallenge:
            if let limit = defaultMoveLimit { return "\(limit) moves" } else { return nil }
        }
    }

    static var playOptions: [GameMode] {
        [.freePlay, .timeAttack, .moveChallenge]
    }
}
