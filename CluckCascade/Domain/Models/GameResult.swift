import Foundation

struct GameResult: Codable {
    enum Outcome: String, Codable {
        case victory
        case defeat
    }

    var outcome: Outcome
    var score: Int
    var feathers: Int
    var movesUsed: Int
    var cascades: Int
    var completionDate: Date
}



