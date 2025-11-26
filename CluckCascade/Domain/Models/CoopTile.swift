import Foundation

enum CoopTileKind: String, Codable, CaseIterable {
    case egg
    case nest
    case corn
    case broodyHen
    case goldenEgg
    case featherFan
}

struct CoopTile: Identifiable, Codable, Equatable {
    let id: UUID
    var kind: CoopTileKind
    var position: TilePosition
    var isStatic: Bool
    var powerCharge: Int

    init(id: UUID = UUID(), kind: CoopTileKind, position: TilePosition, isStatic: Bool = false, powerCharge: Int = 0) {
        self.id = id
        self.kind = kind
        self.position = position
        self.isStatic = isStatic
        self.powerCharge = powerCharge
    }
}

struct TilePosition: Codable, Hashable {
    var row: Int
    var column: Int
}



