import SwiftUI

struct CardView: View {
    let card: GameCard
    var isPlayable: Bool = true
    var isCompact: Bool = false
    var isSelected: Bool = false

    private var width: CGFloat { isCompact ? 58 : 92 }
    private var height: CGFloat { isCompact ? 82 : 130 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isCompact ? 10 : 14, style: .continuous)
                .fill(
                    LinearGradient(colors: card.palette, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompact ? 10 : 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1.2)
                )
                .shadow(color: .black.opacity(0.45), radius: isSelected ? 14 : 6, y: isSelected ? 8 : 3)

            VStack(spacing: isCompact ? 4 : 8) {
                Image(systemName: card.symbolName)
                    .font(.system(size: isCompact ? 16 : 28, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                Text(card.title)
                    .font(.system(size: isCompact ? 10 : 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 4)
            }
        }
        .frame(width: width, height: height)
        .saturation(isPlayable ? 1.0 : 0.35)
        .opacity(isPlayable ? 1.0 : 0.55)
        .overlay(
            RoundedRectangle(cornerRadius: isCompact ? 10 : 14, style: .continuous)
                .strokeBorder(Color.white, lineWidth: isSelected ? 3 : 0)
        )
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// Face-down card back used for the draw pile.
struct CardBackView: View {
    var width: CGFloat = 92
    var height: CGFloat = 130

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(colors: [Color(red: 0.12, green: 0.14, blue: 0.22), Color(red: 0.03, green: 0.04, blue: 0.09)],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1.2)
            )
            .overlay(
                Image(systemName: "steeringwheel")
                    .font(.system(size: width * 0.36, weight: .bold))
                    .foregroundStyle(.white.opacity(0.25))
            )
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.4), radius: 5, y: 2)
    }
}
