import SwiftUI

struct GameBoardView: View {
    let tiles: [[CoopTile]]
    let selectedPosition: TilePosition?
    var clearedPositions: Set<TilePosition> = []
    let onTileTap: (TilePosition) -> Void
    var tileSize: CGFloat = 48

    @Environment(\.animationsEnabled) private var animationsEnabled

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: tiles.first?.count ?? 6)
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(tiles.flatMap { $0 }, id: \.id) { tile in
                    GameBoardTileView(
                        tile: tile,
                        isSelected: isSelected(tile.position),
                        isClearing: animationsEnabled && clearedPositions.contains(tile.position),
                        size: tileSize
                    )
                    .onTapGesture {
                        onTileTap(tile.position)
                    }
                    .accessibilityLabel(tileAccessibility(for: tile))
                }
            }
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.appColors.surfaceSecondary.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.6), lineWidth: 3)
                )
        )
        .padding(.horizontal, AppSpacing.md)
        .animation(animationsEnabled ? .spring(response: 0.45, dampingFraction: 0.8) : nil, value: tiles)
    }

    private func isSelected(_ position: TilePosition) -> Bool {
        guard let selected = selectedPosition else { return false }
        return selected == position
    }

    private func tileAccessibility(for tile: CoopTile) -> String {
        switch tile.kind {
        case .egg: return "Egg tile"
        case .nest: return "Nest tile"
        case .corn: return "Corn tile"
        case .broodyHen: return "Broody hen tile"
        case .goldenEgg: return "Golden egg tile"
        case .featherFan: return "Feather fan tile"
        }
    }
}
