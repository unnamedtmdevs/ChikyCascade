import Foundation

struct CascadeResolution {
    var clearedPositions: Set<TilePosition>
    var clearedByKind: [CoopTileKind: Int]
    var scoreAwarded: Int
    var feathersEarned: Int
    var powerGain: Double
    var cascades: Int
}

protocol CascadeSolverServicing {
    func isSwapValid(board: [[CoopTile]], origin: TilePosition, target: TilePosition) -> Bool
    func resolve(board: [[CoopTile]]) -> (board: [[CoopTile]], resolution: CascadeResolution)
    func refill(board: [[CoopTile]]) -> [[CoopTile]]
    func hasMatches(on board: [[CoopTile]]) -> Bool
}

final class CascadeSolverService: CascadeSolverServicing {
    private let boardSize = 6
    private let baseScore = 120

    func isSwapValid(board: [[CoopTile]], origin: TilePosition, target: TilePosition) -> Bool {
        var simulated = board
        guard swap(&simulated, origin: origin, target: target) else { return false }
        let chains = discoverChains(on: simulated)
        return !chains.isEmpty
    }

    func resolve(board: [[CoopTile]]) -> (board: [[CoopTile]], resolution: CascadeResolution) {
        var workingBoard = board
        var totalCleared: Set<TilePosition> = []
        var totalScore = 0
        var totalFeathers = 0
        var powerGain: Double = 0
        var cascadeCount = 0
        var clearedKindCounter: [CoopTileKind: Int] = [:]

        while true {
            let chains = discoverChains(on: workingBoard)
            guard !chains.isEmpty else { break }

            cascadeCount += 1
            let cleared = Set(chains.flatMap { $0 })
            totalCleared.formUnion(cleared)
            totalScore += baseScore * cleared.count * cascadeCount
            totalFeathers += max(1, cleared.count / 2)
            powerGain += Double(cleared.count) * 0.05

            cleared.forEach { position in
                let kind = workingBoard[position.row][position.column].kind
                clearedKindCounter[kind, default: 0] += 1
            }

            workingBoard = clearTiles(workingBoard, at: cleared)
            workingBoard = applyGravity(to: workingBoard, clearedPositions: cleared)
            workingBoard = refill(board: workingBoard)
        }

        let resolution = CascadeResolution(
            clearedPositions: totalCleared,
            clearedByKind: clearedKindCounter,
            scoreAwarded: totalScore,
            feathersEarned: totalFeathers,
            powerGain: min(1.0, powerGain),
            cascades: cascadeCount
        )

        return (workingBoard, resolution)
    }

    func refill(board: [[CoopTile]]) -> [[CoopTile]] {
        var updated = board
        for row in 0..<boardSize {
            for column in 0..<boardSize {
                if updated[row][column].kind == .corn && updated[row][column].isStatic == false {
                    updated[row][column].kind = CoopTileKind.allCases.randomElement() ?? .egg
                }
            }
        }
        return updated
    }

    func hasMatches(on board: [[CoopTile]]) -> Bool {
        !discoverChains(on: board).isEmpty
    }

    private func swap(_ board: inout [[CoopTile]], origin: TilePosition, target: TilePosition) -> Bool {
        guard origin.row >= 0, origin.row < boardSize,
              origin.column >= 0, origin.column < boardSize,
              target.row >= 0, target.row < boardSize,
              target.column >= 0, target.column < boardSize else { return false }

        guard abs(origin.row - target.row) + abs(origin.column - target.column) == 1 else { return false }

        var originTile = board[origin.row][origin.column]
        var targetTile = board[target.row][target.column]

        originTile.position = target
        targetTile.position = origin

        board[origin.row][origin.column] = targetTile
        board[target.row][target.column] = originTile

        return true
    }

    private func discoverChains(on board: [[CoopTile]]) -> [[TilePosition]] {
        var chains: [[TilePosition]] = []

        // Horizontal chains
        for row in 0..<boardSize {
            var currentChain: [TilePosition] = []
            var previousKind: CoopTileKind?
            for column in 0..<boardSize {
                let tile = board[row][column]
                if tile.kind == previousKind {
                    currentChain.append(TilePosition(row: row, column: column))
                } else {
                    if currentChain.count >= 3 {
                        chains.append(currentChain)
                    }
                    currentChain = [TilePosition(row: row, column: column)]
                }
                previousKind = tile.kind
            }
            if currentChain.count >= 3 {
                chains.append(currentChain)
            }
        }

        // Vertical chains
        for column in 0..<boardSize {
            var currentChain: [TilePosition] = []
            var previousKind: CoopTileKind?
            for row in 0..<boardSize {
                let tile = board[row][column]
                if tile.kind == previousKind {
                    currentChain.append(TilePosition(row: row, column: column))
                } else {
                    if currentChain.count >= 3 {
                        chains.append(currentChain)
                    }
                    currentChain = [TilePosition(row: row, column: column)]
                }
                previousKind = tile.kind
            }
            if currentChain.count >= 3 {
                chains.append(currentChain)
            }
        }

        return chains
    }

    private func applyGravity(to board: [[CoopTile]], clearedPositions: Set<TilePosition>) -> [[CoopTile]] {
        var result = board
        for column in 0..<boardSize {
            var availableRow = boardSize - 1
            for row in stride(from: boardSize - 1, through: 0, by: -1) {
                let position = TilePosition(row: row, column: column)
                if clearedPositions.contains(position) {
                    continue
                }
                result[availableRow][column] = board[row][column]
                result[availableRow][column].position = TilePosition(row: availableRow, column: column)
                availableRow -= 1
            }

            if availableRow >= 0 {
                for fillerRow in stride(from: availableRow, through: 0, by: -1) {
                    result[fillerRow][column] = CoopTile(
                        kind: CoopTileKind.allCases.randomElement() ?? .egg,
                        position: TilePosition(row: fillerRow, column: column)
                    )
                }
            }
        }
        return result
    }

    private func clearTiles(_ board: [[CoopTile]], at positions: Set<TilePosition>) -> [[CoopTile]] {
        var updated = board
        for position in positions {
            updated[position.row][position.column].kind = .corn
            updated[position.row][position.column].isStatic = false
        }
        return updated
    }
}
