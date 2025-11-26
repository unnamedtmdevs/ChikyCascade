import SwiftUI

struct LoadingView: View {
    @Environment(\.animationsEnabled) private var animationsEnabled
    @State private var rotation: Double = 0
    @State private var progress: CGFloat = 0.05

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appColors.backgroundPrimary,
                    Color.appColors.surfaceSecondary.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                Circle()
                    .fill(Color.appColors.accentPrimary.opacity(0.20))
                    .frame(width: 520)
                    .blur(radius: 90)
                    .offset(x: -160, y: -220)
            )
            .overlay(
                Circle()
                    .fill(Color.appColors.accentSecondary.opacity(0.18))
                    .frame(width: 480)
                    .blur(radius: 80)
                    .offset(x: 200, y: 260)
            )

            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appColors.surfacePrimary.opacity(0.95),
                                    Color.appColors.surfaceSecondary.opacity(0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.appColors.accentPrimary.opacity(0.22), radius: 28, x: 0, y: 20)

                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .strokeBorder(Color.appColors.accentPrimary.opacity(0.35), lineWidth: 4)
                        .frame(width: 220, height: 220)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    Text("🐔")
                        .font(.system(size: 110))
                        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.appColors.accentSecondary.opacity(0.9))
                        Spacer()
                        Image(systemName: "feather")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.appColors.accentPrimary.opacity(0.9))
                            .rotationEffect(.degrees(25))
                    }
                    .frame(width: 220, height: 220, alignment: .topLeading)
                    .offset(x: -30, y: -10)

                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.appColors.surfaceTertiary.opacity(0.6))
                        Spacer()
                        Image(systemName: "wind")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.appColors.accentSecondary.opacity(0.8))
                            .rotationEffect(.degrees(-18))
                    }
                    .frame(width: 220, height: 220, alignment: .topTrailing)
                    .offset(x: 24, y: 16)
                }

                VStack(spacing: AppSpacing.sm) {
                    Text("ChikyCascade")
                        .font(AppTypography.display())
                        .foregroundColor(Color.appColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Feathers fluffing, cascades brewing…")
                        .font(AppTypography.body(weight: .medium))
                        .foregroundColor(Color.appColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                ZStack {
                    Circle()
                        .stroke(Color.appColors.surfaceTertiary.opacity(0.35), lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: min(progress, 1))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.appColors.accentPrimary,
                                    Color.appColors.accentSecondary,
                                    Color.appColors.accentPrimary
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(rotation))
                        .animation(animationsEnabled ? .easeInOut(duration: 1.2).repeatForever(autoreverses: false) : nil, value: rotation)
                        .animation(animationsEnabled ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true) : nil, value: progress)
                }
                .frame(width: 90, height: 90)
                .accessibilityLabel("Loading coop")

                Text("Preparing the coop for your next puzzle adventure")
                    .font(AppTypography.caption(weight: .semibold))
                    .foregroundColor(Color.appColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.xl)
            .maxContentWidth()
        }
        .onAppear {
            if animationsEnabled {
                rotation = 360
                progress = 1
            }
        }
    }
}



