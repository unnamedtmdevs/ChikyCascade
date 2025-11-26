
import Foundation

protocol GameServicing: ObservableObject {
    var session: GameSession? { get }
    var lastResult: GameResult? { get }
    var activeMode: GameMode { get }
    var timeRemaining: Int? { get }
    var lastResultMode: GameMode { get }
    func startGame(mode: GameMode)
    func performSwap(origin: TilePosition, target: TilePosition)
    func activateCoopPower()
    func applyPowerSurgeBoost() -> Bool
    func applyRowSweepBoost() -> Bool
    func applyBoardShuffleBoost() -> Bool
    func applyCoopHammerBoost() -> Bool
    func spendFeathers(_ amount: Int) -> Bool
    func refundFeathers(_ amount: Int)
    func forfeit()
    func dismissResult()
    func abandonSession()
}

final class GameService: GameServicing {
    @Published private(set) var session: GameSession?
    @Published private(set) var lastResult: GameResult?
    @Published private(set) var playerProgress: PlayerProgress
    @Published private(set) var activeMode: GameMode
    @Published private(set) var timeRemaining: Int?
    @Published private(set) var lastResultMode: GameMode

    var levelsCatalogue: [Level] {
        levelService.levels
    }

    private let levelService: LevelServicing
    private let cascadeService: CascadeSolverServicing
    private let storage: StorageServicing
    private let haptics: HapticsServicing
    private var modeTimer: Timer?

    init(
        levelService: LevelServicing,
        cascadeService: CascadeSolverServicing,
        storage: StorageServicing,
        haptics: HapticsServicing
    ) {
        self.levelService = levelService
        self.cascadeService = cascadeService
        self.storage = storage
        self.haptics = haptics
        self.playerProgress = storage.value(forKey: UserDefaultsKeys.levelProgress, default: PlayerProgress.initial)
        self.activeMode = .freePlay
        self.timeRemaining = nil
        self.lastResultMode = .freePlay
    }

    deinit {
        modeTimer?.invalidate()
    }

    func startGame(mode: GameMode) {
        stopModeTimer()
        lastResult = nil
        activeMode = mode

        let board = generateInitialBoard()

        switch mode {
        case .freePlay:
            let level = Level(
                id: GameMode.freePlay.persistenceID,
                chapterIndex: -1,
                levelIndex: -1,
                title: "Free Play",
                description: "Relax and experiment with unlimited cascades.",
                difficulty: .cozy,
                objectives: [],
                moveLimit: Int.max,
                scoreThresholds: []
            )
            session = GameSession(
                level: level,
                mode: .freePlay,
                board: board,
                remainingMoves: 0
            )
            timeRemaining = nil

        case .timeAttack:
            let duration = mode.timeLimit ?? 90
            let level = Level(
                id: GameMode.timeAttack.persistenceID,
                chapterIndex: -1,
                levelIndex: -1,
                title: "Time Attack",
                description: "Race the timer to set new high scores.",
                difficulty: .frenzy,
                objectives: [],
                moveLimit: Int.max,
                scoreThresholds: []
            )
            session = GameSession(
                level: level,
                mode: .timeAttack,
                board: board,
                remainingMoves: 0
            )
            startModeTimer(duration: duration)

        case .moveChallenge:
            let moveLimit = mode.defaultMoveLimit ?? 25
            let level = Level(
                id: GameMode.moveChallenge.persistenceID,
                chapterIndex: -1,
                levelIndex: -1,
                title: "Move Challenge",
                description: "Limited swaps – plan every move carefully.",
                difficulty: .frenzy,
                objectives: [],
                moveLimit: moveLimit,
                scoreThresholds: []
            )
            session = GameSession(
                level: level,
                mode: .moveChallenge,
                board: board,
                remainingMoves: moveLimit
            )
            timeRemaining = nil
        }

        lastResultMode = mode
    }

    func performSwap(origin: TilePosition, target: TilePosition) {
        guard var currentSession = session else { return }
        let consumesMoves = currentSession.mode.consumesMoves
        if consumesMoves && currentSession.remainingMoves <= 0 {
            haptics.warning()
            return
        }

        currentSession.lastClearedPositions = []

        guard let swappedBoard = swapBoard(in: currentSession.board, origin: origin, target: target) else {
            haptics.warning()
            session = currentSession
            return
        }

        let originalBoard = currentSession.board
        currentSession.board = swappedBoard

        let resolved = cascadeService.resolve(board: swappedBoard)
        let clearedPositions = resolved.resolution.clearedPositions

        guard resolved.resolution.cascades > 0 else {
            currentSession.board = originalBoard
            currentSession.comboMultiplier = 1
            currentSession.lastClearedPositions = []
            session = currentSession
            haptics.warning()
            return
        }

        if consumesMoves {
            currentSession.remainingMoves = max(currentSession.remainingMoves - 1, 0)
        }

        currentSession.board = resolved.board
        currentSession.score += resolved.resolution.scoreAwarded
        currentSession.collectedFeathers += resolved.resolution.feathersEarned
        currentSession.powerCharge = min(1.0, currentSession.powerCharge + resolved.resolution.powerGain)
        currentSession.cascadesTriggered += resolved.resolution.cascades
        currentSession.lastClearedPositions = clearedPositions
        currentSession.comboMultiplier = min(currentSession.comboMultiplier + 1, 5)

        haptics.success()
        session = currentSession
        evaluateSessionCompletion()

        if !clearedPositions.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard var session = self?.session else { return }
                if session.lastClearedPositions == clearedPositions {
                    session.lastClearedPositions = []
                    self?.session = session
                }
            }
        }
    }

    func activateCoopPower() {
        guard var currentSession = session else { return }
        guard currentSession.powerCharge >= 1.0 else { return }

        currentSession.powerCharge = 0
        currentSession.score += 750
        currentSession.collectedFeathers += 5
        currentSession.comboMultiplier = min(currentSession.comboMultiplier + 2, 6)
        haptics.heavyImpact()
        session = currentSession
    }

    @discardableResult
    func spendFeathers(_ amount: Int) -> Bool {
        guard amount > 0 else { return true }
        guard playerProgress.totalFeathers >= amount else { return false }
        playerProgress.totalFeathers -= amount
        storage.set(playerProgress, forKey: UserDefaultsKeys.levelProgress)
        return true
    }

    func refundFeathers(_ amount: Int) {
        guard amount > 0 else { return }
        playerProgress.totalFeathers += amount
        storage.set(playerProgress, forKey: UserDefaultsKeys.levelProgress)
    }

    func forfeit() {
        guard let currentSession = session else { return }
        finalizeResult(for: currentSession, outcome: .defeat)
        session = nil
    }

    func dismissResult() {
        lastResult = nil
    }

    func abandonSession() {
        stopModeTimer()
        if let currentSession = session, currentSession.mode == .freePlay {
            finalizeResult(for: currentSession, outcome: .victory)
        }
        session = nil
        lastResult = nil
        activeMode = .freePlay
        timeRemaining = nil
    }

    func applyPowerSurgeBoost() -> Bool {
        guard var currentSession = session else { return false }
        guard currentSession.powerCharge < 1.0 else { return false }
        currentSession.powerCharge = min(1.0, currentSession.powerCharge + 0.5)
        currentSession.lastClearedPositions = []
        session = currentSession
        haptics.mediumImpact()
        return true
    }

    func applyRowSweepBoost() -> Bool {
        guard var currentSession = session else { return false }
        guard !currentSession.board.isEmpty else { return false }

        let targetRow = Int.random(in: 0..<currentSession.board.count)
        var workingBoard = currentSession.board
        var clearedPositions: Set<TilePosition> = []
        var manualKinds: [CoopTileKind: Int] = [:]

        for column in 0..<workingBoard[targetRow].count {
            let position = TilePosition(row: targetRow, column: column)
            let originalKind = workingBoard[targetRow][column].kind
            manualKinds[originalKind, default: 0] += 1
            workingBoard[targetRow][column].kind = .corn
            workingBoard[targetRow][column].isStatic = false
            clearedPositions.insert(position)
        }

        let resolved = cascadeService.resolve(board: workingBoard)

        currentSession.board = resolved.board
        currentSession.score += resolved.resolution.scoreAwarded + manualKinds.values.reduce(0, +) * 120
        currentSession.collectedFeathers += resolved.resolution.feathersEarned + max(1, manualKinds.values.reduce(0, +) / 3)
        currentSession.powerCharge = min(1.0, currentSession.powerCharge + resolved.resolution.powerGain)
        currentSession.cascadesTriggered += resolved.resolution.cascades
        currentSession.lastClearedPositions = clearedPositions.union(resolved.resolution.clearedPositions)

        session = currentSession
        evaluateSessionCompletion()
        haptics.success()
        return true
    }

    func applyCoopHammerBoost() -> Bool {
        guard var currentSession = session else { return false }
        guard !currentSession.board.isEmpty else { return false }

        let size = currentSession.board.count
        let randomRow = Int.random(in: 0..<size)
        let randomColumn = Int.random(in: 0..<currentSession.board[randomRow].count)
        let targetPosition = TilePosition(row: randomRow, column: randomColumn)

        var tile = currentSession.board[randomRow][randomColumn]
        tile.kind = .goldenEgg
        tile.isStatic = false
        currentSession.board[randomRow][randomColumn] = tile
        currentSession.score += 150
        currentSession.collectedFeathers += 1
        currentSession.lastClearedPositions = [targetPosition]

        session = currentSession
        haptics.heavyImpact()
        return true
    }

    func applyBoardShuffleBoost() -> Bool {
        guard var currentSession = session else { return false }
        guard !currentSession.board.isEmpty else { return false }

        var shuffled = reshuffledBoard(from: currentSession.board)
        var attempts = 0
        while cascadeService.hasMatches(on: shuffled) && attempts < 40 {
            shuffled = reshuffledBoard(from: currentSession.board)
            attempts += 1
        }

        currentSession.board = shuffled
        currentSession.lastClearedPositions = []
        session = currentSession
        haptics.lightImpact()
        return true
    }

    private func evaluateSessionCompletion() {
        guard let currentSession = session else { return }

        switch currentSession.mode {
        case .moveChallenge:
            if currentSession.remainingMoves <= 0 {
                finalizeResult(for: currentSession, outcome: .victory)
                session = nil
            }
        case .timeAttack:
            // handled by timer
            break
        case .freePlay:
            break
        }
    }

    private func finalizeResult(for session: GameSession, outcome: GameResult.Outcome) {
        stopModeTimer()

        let elapsedTime = Date().timeIntervalSince(session.startDate)
        playerProgress.totalPlayTime += elapsedTime
        playerProgress.totalFeathers += session.collectedFeathers
        playerProgress.longestCombo = max(playerProgress.longestCombo, session.comboMultiplier)
        playerProgress.deepestCascade = max(playerProgress.deepestCascade, session.cascadesTriggered)

        let existing = playerProgress.completedLevels.first(where: { $0.levelID == session.level.id })
        let completion = LevelCompletion(
            levelID: session.level.id,
            bestScore: max(session.score, existing?.bestScore ?? 0),
            bestFeatherCount: max(session.collectedFeathers, existing?.bestFeatherCount ?? 0),
            bestMovesRemaining: max(session.remainingMoves, existing?.bestMovesRemaining ?? 0),
            completionDate: Date()
        )

        playerProgress.completedLevels.removeAll { $0.levelID == session.level.id }
        playerProgress.completedLevels.append(completion)
        storage.set(playerProgress, forKey: UserDefaultsKeys.levelProgress)

        let movesUsed: Int
        if session.mode.consumesMoves {
            movesUsed = max(0, session.level.moveLimit - session.remainingMoves)
        } else {
            movesUsed = session.cascadesTriggered
        }

        let result = GameResult(
            outcome: outcome,
            score: session.score,
            feathers: session.collectedFeathers,
            movesUsed: movesUsed,
            cascades: session.cascadesTriggered,
            completionDate: Date()
        )

        lastResultMode = session.mode
        lastResult = result
    }

    private func startModeTimer(duration: Int) {
        stopModeTimer()
        timeRemaining = duration
        modeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard let remaining = self.timeRemaining else {
                timer.invalidate()
                return
            }

            if remaining <= 1 {
                timer.invalidate()
                self.timeRemaining = 0
                if let currentSession = self.session {
                    self.finalizeResult(for: currentSession, outcome: .victory)
                    self.session = nil
                }
                self.stopModeTimer()
            } else {
                self.timeRemaining = remaining - 1
            }
        }

        if let modeTimer = modeTimer {
            RunLoop.main.add(modeTimer, forMode: .common)
        }
    }

    private func stopModeTimer() {
        modeTimer?.invalidate()
        modeTimer = nil
        timeRemaining = nil
    }

    private func generateInitialBoard() -> [[CoopTile]] {
        var attempts = 0
        var board = randomBoard()
        while cascadeService.hasMatches(on: board) && attempts < 40 {
            board = randomBoard()
            attempts += 1
        }
        if cascadeService.hasMatches(on: board) {
            board = cascadeService.resolve(board: board).board
        }
        return board
    }

    private func randomBoard() -> [[CoopTile]] {
        var board: [[CoopTile]] = []
        for row in 0..<6 {
            var rowTiles: [CoopTile] = []
            for column in 0..<6 {
                let kind = CoopTileKind.allCases.randomElement() ?? .egg
                rowTiles.append(CoopTile(kind: kind, position: TilePosition(row: row, column: column)))
            }
            board.append(rowTiles)
        }
        return board
    }

    private func reshuffledBoard(from board: [[CoopTile]]) -> [[CoopTile]] {
        var flatTiles = board.flatMap { $0 }
        flatTiles.shuffle()
        var index = 0
        var shuffled = board
        for row in 0..<board.count {
            for column in 0..<board[row].count {
                var tile = flatTiles[index]
                tile.position = TilePosition(row: row, column: column)
                shuffled[row][column] = tile
                index += 1
            }
        }
        return shuffled
    }

    private func swapBoard(in board: [[CoopTile]], origin: TilePosition, target: TilePosition) -> [[CoopTile]]? {
        guard origin.row >= 0, origin.row < board.count,
              target.row >= 0, target.row < board.count else { return nil }
        guard origin.column >= 0, origin.column < board[origin.row].count,
              target.column >= 0, target.column < board[target.row].count else { return nil }
        guard abs(origin.row - target.row) + abs(origin.column - target.column) == 1 else { return nil }

        var updated = board
        var originTile = updated[origin.row][origin.column]
        var targetTile = updated[target.row][target.column]

        originTile.position = target
        targetTile.position = origin

        updated[origin.row][origin.column] = targetTile
        updated[target.row][target.column] = originTile

        return updated
    }
}
