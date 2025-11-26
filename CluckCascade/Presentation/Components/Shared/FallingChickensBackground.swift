import SwiftUI

struct FallingChickensBackground: View {
    var density: Int = 5
    var sizeRange: ClosedRange<CGFloat> = 38...52
    var speedRange: ClosedRange<Double> = 18...32
    var opacity: Double = 0.45
    var horizontalSpread: ClosedRange<CGFloat> = 0.12...0.88
    var verticalPadding: CGFloat = 220

    @State private var animatedOpacity: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let totalChickens = max(density, 1)

            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    ForEach(0..<totalChickens, id: \.self) { index in
                        let factor = horizontalFactor(for: index, count: totalChickens)
                        let symbol = index.isMultiple(of: 2) ? "🐔" : "🐣"
                        let fallSpeed = fallSpeed(for: index, count: totalChickens)
                        let phase = Double(index) * 1.35
                        let travelDistance = Double(height + verticalPadding)
                        let progress = fmod(time * fallSpeed + phase, travelDistance)
                        let yPosition = CGFloat(progress) - verticalPadding / 2
                        let horizontalDrift = sin((time + Double(index)) * 0.65) * 18.0
                        let entrySize = size(for: index, count: totalChickens)

                        Text(symbol)
                            .font(.system(size: entrySize))
                            .opacity(animatedOpacity)
                            .position(
                                x: width * factor + CGFloat(horizontalDrift),
                                y: yPosition
                            )
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    animatedOpacity = opacity
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func horizontalFactor(for index: Int, count: Int) -> CGFloat {
        guard count > 1 else { return (horizontalSpread.lowerBound + horizontalSpread.upperBound) / 2 }
        let span = horizontalSpread.upperBound - horizontalSpread.lowerBound
        let step = span / CGFloat(count - 1)
        return horizontalSpread.lowerBound + step * CGFloat(index)
    }

    private func fallSpeed(for index: Int, count: Int) -> Double {
        if count <= 1 { return (speedRange.lowerBound + speedRange.upperBound) / 2 }
        let ratio = Double(index % count) / Double(count - 1)
        return speedRange.lowerBound + (speedRange.upperBound - speedRange.lowerBound) * ratio
    }

    private func size(for index: Int, count: Int) -> CGFloat {
        if count <= 1 { return (sizeRange.lowerBound + sizeRange.upperBound) / 2 }
        let ratio = CGFloat(index % count) / CGFloat(count - 1)
        return sizeRange.lowerBound + (sizeRange.upperBound - sizeRange.lowerBound) * ratio
    }
}

