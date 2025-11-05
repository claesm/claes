import SwiftUI

struct ContentView: View {
    @State private var daysUntilChristmas: Int = 0
    @State private var currentDate = Date()

    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.3), Color.green.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                // Christmas tree icon
                Text("🎄")
                    .font(.system(size: 40))

                // Title
                Text("Christmas Eve")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Days countdown
                if daysUntilChristmas == 0 {
                    Text("Today!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                } else if daysUntilChristmas < 0 {
                    Text("🎅")
                        .font(.system(size: 50))
                    Text("Merry Christmas!")
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                } else {
                    Text("\(daysUntilChristmas)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(daysUntilChristmas == 1 ? "day" : "days")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .onAppear {
            updateCountdown()
        }
        .onReceive(timer) { _ in
            currentDate = Date()
            updateCountdown()
        }
    }

    private func updateCountdown() {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: currentDate)

        // Get current year's Christmas Eve
        var christmasComponents = DateComponents()
        christmasComponents.year = calendar.component(.year, from: currentDate)
        christmasComponents.month = 12
        christmasComponents.day = 24

        guard var christmasEve = calendar.date(from: christmasComponents) else {
            return
        }

        // If Christmas Eve has passed this year, calculate for next year
        if christmasEve < now {
            christmasComponents.year! += 1
            christmasEve = calendar.date(from: christmasComponents) ?? christmasEve
        }

        // Calculate days until Christmas Eve
        let components = calendar.dateComponents([.day], from: now, to: christmasEve)
        daysUntilChristmas = components.day ?? 0
    }
}

#Preview {
    ContentView()
}
