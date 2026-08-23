import SwiftUI

struct RootView: View {
    @State private var showGame = false

    var body: some View {
        ZStack {
            AppBackground()

            if showGame {
                GameView(onExit: { withAnimation(.easeInOut) { showGame = false } })
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                MenuView(onPlay: { withAnimation(.easeInOut) { showGame = true } })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showGame)
    }
}

/// Full-bleed animated asphalt-and-horizon backdrop shared by every screen.
struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.07, blue: 0.16), Color(red: 0.07, green: 0.14, blue: 0.28), Color(red: 0.02, green: 0.04, blue: 0.10)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    path.move(to: CGPoint(x: w * 0.5, y: 0))
                    path.addLine(to: CGPoint(x: w * 0.12, y: h))
                    path.addLine(to: CGPoint(x: w * 0.88, y: h))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.03))
                .blur(radius: 40)
            }
            .ignoresSafeArea()
        }
    }
}

private struct MenuView: View {
    let onPlay: () -> Void
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 6) {
                Text("1000")
                    .font(.system(size: 88, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 20)
                Text("MILES")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .tracking(14)
                    .foregroundStyle(.white)
            }
            .scaleEffect(pulse ? 1.0 : 0.94)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }

            Image(systemName: "car.side.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 8)

            Spacer()

            Button(action: onPlay) {
                HStack(spacing: 10) {
                    Image(systemName: "flag.checkered")
                    Text("Start Race")
                        .fontWeight(.bold)
                }
                .font(.title3)
                .foregroundStyle(.black)
                .padding(.vertical, 16)
                .frame(maxWidth: 320)
                .background(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.5), radius: 16, y: 6)
            }
            .buttonStyle(.plain)

            Text("First to 1000 miles wins. Play distance, remedy, hazard, and safety cards to out-race your rival.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.top, 4)

            Spacer()
        }
        .padding()
    }
}
