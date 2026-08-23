import SwiftUI

struct PlayerBoardView: View {
    @ObservedObject var player: PlayerState
    var isActive: Bool
    var mirrored: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: player.isAI ? "cpu" : "person.fill")
                    Text(player.name)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)

                if isActive {
                    Text("Turn")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(Color.green.opacity(0.85)))
                        .foregroundStyle(.black)
                }

                Spacer()

                statusBadge
            }

            ProgressBar(progress: Double(player.totalDistance) / Double(GameEngine.target))

            HStack {
                Text("\(player.totalDistance) mi")
                    .font(.system(.subheadline, design: .rounded)).bold()
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(SafetyKind.allCases, id: \.self) { kind in
                        Image(systemName: kind.symbol)
                            .font(.caption)
                            .foregroundStyle(player.safeties.contains(kind) ? .yellow : .white.opacity(0.15))
                    }
                }
            }

            HStack(spacing: 10) {
                if let top = player.battlePile.last {
                    VStack(spacing: 2) {
                        CardView(card: top, isCompact: true)
                        Text("Battle").font(.caption2).foregroundStyle(.white.opacity(0.5))
                    }
                } else {
                    VStack(spacing: 2) {
                        emptySlot
                        Text("Battle").font(.caption2).foregroundStyle(.white.opacity(0.5))
                    }
                }

                VStack(spacing: 2) {
                    if player.speedLimited {
                        CardView(card: .hazard(.speedLimit), isCompact: true)
                    } else {
                        emptySlot
                    }
                    Text("Speed").font(.caption2).foregroundStyle(.white.opacity(0.5))
                }

                VStack(spacing: 2) {
                    Text("\(player.distancePile.count)")
                        .font(.headline)
                        .frame(width: 58, height: 82)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.06)))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Miles played").font(.caption2).foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(isActive ? Color.yellow.opacity(0.6) : Color.white.opacity(0.08), lineWidth: isActive ? 2 : 1)
                )
        )
    }

    private var emptySlot: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.2, dash: [4, 4]))
            .foregroundStyle(.white.opacity(0.2))
            .frame(width: 58, height: 82)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if let hazard = player.activeHazard {
            Label(hazard.rawValue, systemImage: hazard.symbol)
                .font(.caption2.bold())
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Color.red.opacity(0.85)))
                .foregroundStyle(.white)
        } else if player.isRolling {
            Label("Rolling", systemImage: "figure.walk.motion")
                .font(.caption2.bold())
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Color.green.opacity(0.5)))
                .foregroundStyle(.white)
        }
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(colors: [.green, .yellow, .orange], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(6, geo.size.width * min(1, progress)))
                    .animation(.easeOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: 8)
    }
}
