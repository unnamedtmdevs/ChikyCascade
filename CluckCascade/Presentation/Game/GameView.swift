import SwiftUI

struct GameView: View {
    @EnvironmentObject private var gameService: GameService
    @EnvironmentObject private var boostsService: BoostsService
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.animationsEnabled) private var animationsEnabled
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedPosition: TilePosition?
    @State private var showingPause: Bool = false

    private var session: GameSession? {
        gameService.session
    }


var body: some View {
    ZStack {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: AppSpacing.md) {
                    header

                    if let session {
                        modeBadge(for: session)
                    }

                    if let session {
                        let metrics = boardMetrics()
                        GameBoardView(
                            tiles: session.board,
                            selectedPosition: selectedPosition,
                            clearedPositions: animationsEnabled ? session.lastClearedPositions : [],
                            onTileTap: handleTileTap,
                            tileSize: metrics.tileSize
                        )
                        .frame(width: metrics.boardSize, height: metrics.boardSize)

                        powerMeter(for: session)
                        boostActionRow(for: session)
                        controls(for: session)
                    } else {
                        placeholderState
                    }

                    Spacer(minLength: AppSpacing.md)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }

        if let result = gameService.lastResult {
            resultOverlay(result)
        }
    }
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    .onAppear {
        if gameService.session == nil {
            gameService.startGame(mode: gameService.activeMode)
        }
    }
    .sheet(isPresented: $showingPause) {
        pauseSheet
    }
    .onDisappear {
        if let session = gameService.session, session.mode == .freePlay {
            gameService.abandonSession()
        }
    }
}

    private func boardMetrics() -> (tileSize: CGFloat, boardSize: CGFloat) {
        let availableWidth = max(UIScreen.main.bounds.width - AppSpacing.lg * 2, 0)
        let availableHeight = max(UIScreen.main.bounds.height - (AppSpacing.lg * 2 + 220), 0)
        let targetBoard = min(availableWidth, availableHeight)
        let spacing = AppSpacing.sm
        let padding = AppSpacing.sm * 2
        let rawTile = (targetBoard - padding - spacing * 5) / 6
        let tileSize = max(38, rawTile)
        let boardSize = tileSize * 6 + spacing * 5 + padding
        return (tileSize, boardSize)
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            metricCard(title: "Score", value: session.map { formatNumber($0.score) } ?? "--")
            metricCard(title: "Feathers", value: session.map { formatNumber($0.collectedFeathers) } ?? "--", icon: "leaf.fill")
            if let session = session {
                switch session.mode {
                case .timeAttack:
                    let seconds = gameService.timeRemaining ?? session.mode.timeLimit ?? 0
                    metricCard(title: "Time", value: formatTime(seconds), icon: "timer")
                case .freePlay:
                    metricCard(title: "Mode", value: "Free", icon: "infinity")
                case .moveChallenge:
                    metricCard(title: "Moves", value: formatNumber(session.remainingMoves), icon: "target")
                }
            } else {
                metricCard(title: "Mode", value: "--", icon: "questionmark")
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .maxContentWidth(360)
    }

    private func modeBadge(for session: GameSession) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label(session.mode.displayName, systemImage: session.mode.iconName)
                .labelStyle(.titleAndIcon)
                .font(AppTypography.body(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            Text(session.mode.description)
                .font(AppTypography.caption())
                .foregroundColor(Color.appColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            switch session.mode {
            case .timeAttack:
                let seconds = gameService.timeRemaining ?? session.mode.timeLimit ?? 0
                Text("Time left: \(formatTime(seconds))")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.accentPrimary)
            case .moveChallenge:
                Text("Moves left: \(formatNumber(session.remainingMoves))")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.accentPrimary)
            default:
                EmptyView()
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appColors.surfaceSecondary.opacity(0.75))
        )
        .maxContentWidth(360)
    }

    private func powerMeter(for session: GameSession) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("Coop Power")
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)

                Spacer()

                Text("\(Int(session.powerCharge * 100))%")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.textSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appColors.surfaceSecondary.opacity(0.6))
                    Capsule()
                        .fill(LinearGradient(colors: [Color.appColors.accentSecondary, Color.appColors.accentPrimary], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * CGFloat(session.powerCharge))
                        .animation(animationsEnabled ? .easeInOut(duration: 0.4) : nil, value: session.powerCharge)
                }
            }
            .frame(height: 16)
        }
        .padding(.horizontal, AppSpacing.md)
        .maxContentWidth(360)
    }

    private func boostActionRow(for session: GameSession) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Boosts")
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)
                Spacer()
                Text("Tap to activate")
                    .font(AppTypography.caption())
                    .foregroundColor(Color.appColors.textSecondary)
            }

            VStack(spacing: AppSpacing.xs) {
                ForEach(boostsService.boosts) { boost in
                    Button {
                        triggerBoost(boost.type)
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: boost.type.iconName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.appColors.accentPrimary)
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(boost.type.title)
                                    .font(AppTypography.body(weight: .semibold))
                                    .foregroundColor(Color.appColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(boost.type.description)
                                    .font(AppTypography.caption())
                                    .foregroundColor(Color.appColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Text("x\(boost.availableCount)")
                                .font(AppTypography.body(weight: .semibold))
                                .foregroundColor(Color.appColors.textPrimary)
                        }
                        .padding(.vertical, AppSpacing.sm)
                        .padding(.horizontal, AppSpacing.md)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .secondary))
                    .disabled(boost.availableCount == 0)
                    .opacity(boost.availableCount == 0 ? 0.5 : 1)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.85))
        )
        .maxContentWidth(360)
    }

    private func controls(for session: GameSession) -> some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                Button(action: { showingPause = true }) {
                    Label("Pause", systemImage: "pause")
                        .labelStyle(.titleAndIcon)
                        .font(AppTypography.body(weight: .medium))
                        .foregroundColor(Color.appColors.textPrimary)
                }
                .buttonStyle(WoodButtonStyle(variant: .secondary))
            }

            Button(action: { gameService.activateCoopPower() }) {
                Label("Unleash Power", systemImage: "bolt.fill")
                    .labelStyle(.titleAndIcon)
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)
            }
            .buttonStyle(WoodButtonStyle(variant: .primary))
            .disabled(session.powerCharge < 1)
            .opacity(session.powerCharge < 1 ? 0.6 : 1)
        }
        .padding(.horizontal, AppSpacing.md)
        .maxContentWidth(360)
    }

    private var placeholderState: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.appColors.accentPrimary))
            Text("Preparing puzzle...")
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
        }
        .padding()
    }

    private func formatNumber(_ value: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
    }

    private func formatTime(_ seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let remainder = clamped % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }

    private func metricCard(title: String, value: String, icon: String? = nil) -> some View {
        VStack(spacing: AppSpacing.xs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.appColors.accentPrimary)
            }
            Text(title)
                .font(AppTypography.caption(weight: .medium))
                .foregroundColor(Color.appColors.textSecondary)
            Text(value)
                .font(AppTypography.headline(weight: .bold))
                .foregroundColor(Color.appColors.textPrimary)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, AppSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.85))
        )
    }

    private func handleTileTap(_ position: TilePosition) {
        settingsStore.playTapFeedback()
        if let selected = selectedPosition {
            if isAdjacent(selected, position) {
                gameService.performSwap(origin: selected, target: position)
                selectedPosition = nil
            } else {
                selectedPosition = position
            }
        } else {
            selectedPosition = position
        }
    }

    private func isAdjacent(_ a: TilePosition, _ b: TilePosition) -> Bool {
        let rowDistance = abs(a.row - b.row)
        let columnDistance = abs(a.column - b.column)
        return rowDistance + columnDistance == 1
    }

    private func triggerBoost(_ type: BoostType) {
        guard boostsService.consumeBoost(of: type) else { return }
        settingsStore.playTapFeedback()

        let applied: Bool
        switch type {
        case .powerSurge:
            applied = gameService.applyPowerSurgeBoost()
        case .rowSweep:
            applied = gameService.applyRowSweepBoost()
        case .boardShuffle:
            applied = gameService.applyBoardShuffleBoost()
        case .coopHammer:
            applied = gameService.applyCoopHammerBoost()
        }

        if applied {
            let levelTitle = gameService.session?.level.title ?? "session"
            boostsService.recordUsage(of: type, context: "Activated during \(levelTitle)")
        } else {
            boostsService.refundBoost(of: type)
        }
    }

    private func resultOverlay(_ result: GameResult) -> some View {
        let mode = gameService.lastResultMode
        let isVictory = result.outcome == .victory
        let title = isVictory ? mode.resultTitleVictory : mode.resultTitleDefeat
        let iconName = isVictory ? "rosette" : "exclamationmark.triangle"
        let iconColor = isVictory ? Color.appColors.accentPrimary : Color.appColors.danger

        let playAgainAction = {
            gameService.startGame(mode: mode)
            gameService.dismissResult()
        }

        let closeAction = {
            gameService.dismissResult()
            presentationMode.wrappedValue.dismiss()
        }

        return ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Image(systemName: iconName)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(AppTypography.display())
                    .foregroundColor(Color.appColors.textPrimary)
                    .multilineTextAlignment(.center)

                VStack(spacing: AppSpacing.xs) {
                    Text("Score: \(formatNumber(result.score))")
                    Text("Feathers: \(formatNumber(result.feathers))")
                    Text("Cascades: \(formatNumber(result.cascades))")
                }
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)

                HStack(spacing: AppSpacing.md) {
                    Button(action: closeAction) {
                        Text("Close")
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .secondary))

                    Button(action: playAgainAction) {
                        Text("Play Again")
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .primary))
                }
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.appColors.surfacePrimary)
            )
            .padding()
        }
    }

    private var pauseSheet: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfaceSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 54, weight: .semibold))
                        .foregroundColor(Color.appColors.accentPrimary)

                    Text(session?.mode.pauseTitle ?? "Coop Paused")
                        .font(AppTypography.title())
                        .foregroundColor(Color.appColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(session?.mode.sessionTagline ?? "Take a breather before the next cascade.")
                        .font(AppTypography.body())
                        .foregroundColor(Color.appColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let session {
                    HStack(spacing: AppSpacing.md) {
                        pauseMetricCard(icon: "star.fill", title: "Score", value: formatNumber(session.score))
                        pauseMetricCard(icon: "leaf.fill", title: "Feathers", value: formatNumber(session.collectedFeathers))
                        pauseMetricCard(icon: "bolt.fill", title: "Combos", value: formatNumber(session.comboMultiplier))
                    }
                }

                VStack(spacing: AppSpacing.sm) {
                    Button {
                        showingPause = false
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .primary))

                    Button {
                        restartCurrentMode()
                        showingPause = false
                    } label: {
                        Label(session?.mode.restartTitle ?? "Restart", systemImage: "arrow.clockwise")
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .secondary))

                    Button {
                        gameService.forfeit()
                        showingPause = false
                    } label: {
                        Label(session?.mode.exitTitle ?? "End Session", systemImage: "flag.checkered")
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .secondary))

                    Button {
                        gameService.abandonSession()
                        showingPause = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("Exit to Home", systemImage: "house.fill")
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .destructive))
                }
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: 440)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.appColors.surfacePrimary.opacity(0.96))
                    .shadow(color: Color.appColors.borderEmphasis.opacity(0.25), radius: 22, x: 0, y: 16)
            )
            .padding(AppSpacing.xl)
        }
    }

    private func restartCurrentMode() {
        if let currentSession = session {
            gameService.startGame(mode: currentSession.mode)
        } else {
            let mode = gameService.lastResultMode
            gameService.startGame(mode: mode)
        }
    }

    private func pauseMetricCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.appColors.accentSecondary)

            Text(value)
                .font(AppTypography.body(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            Text(title)
                .font(AppTypography.caption())
                .foregroundColor(Color.appColors.textSecondary)
        }
        .padding(.vertical, AppSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appColors.surfaceSecondary.opacity(0.65))
        )
    }
}
