import SwiftUI

struct GameView: View {
    @StateObject private var engine = GameEngine()
    let onExit: () -> Void

    @State private var selectedCard: GameCard?
    @State private var showLog = false

    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 700

            VStack(spacing: 12) {
                header

                if isWide {
                    HStack(alignment: .top, spacing: 16) {
                        PlayerBoardView(player: engine.ai, isActive: !engine.isHumanTurn)
                        PlayerBoardView(player: engine.human, isActive: engine.isHumanTurn)
                    }
                } else {
                    VStack(spacing: 12) {
                        PlayerBoardView(player: engine.ai, isActive: !engine.isHumanTurn)
                        PlayerBoardView(player: engine.human, isActive: engine.isHumanTurn)
                    }
                }

                if showLog { logPanel }

                Spacer(minLength: 0)

                handArea
            }
            .padding()
        }
        .overlay(alignment: .top) { coupFourreBanner }
        .overlay { winnerOverlay }
        .onChange(of: engine.currentTurn) { _ in
            selectedCard = nil
            triggerAIIfNeeded()
        }
        .onAppear { triggerAIIfNeeded() }
    }

    private var header: some View {
        HStack {
            Button(action: onExit) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Text("1000 Miles")
                .font(.system(.title3, design: .rounded)).bold()
                .foregroundStyle(.white)
            Spacer()
            Button {
                withAnimation { showLog.toggle() }
            } label: {
                Image(systemName: "list.bullet.rectangle")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private var logPanel: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(engine.log.enumerated()), id: \.offset) { i, entry in
                        Text(entry)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                            .id(i)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
            .frame(height: 110)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.05)))
            .onChange(of: engine.log.count) { _ in
                withAnimation { proxy.scrollTo(engine.log.count - 1, anchor: .bottom) }
            }
        }
    }

    private var handArea: some View {
        VStack(spacing: 10) {
            HStack {
                CardBackView(width: 50, height: 70)
                    .overlay(Text("\(engine.deck.count)").font(.caption.bold()).foregroundStyle(.white))
                Text("Draw Pile")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                if let card = selectedCard {
                    actionButtons(for: card)
                } else {
                    Text(engine.isHumanTurn ? "Choose a card to play or discard" : "Rival is thinking…")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(engine.human.hand) { card in
                        CardView(
                            card: card,
                            isPlayable: engine.isHumanTurn && engine.isPlayable(card, by: engine.human),
                            isSelected: selectedCard == card
                        )
                        .onTapGesture {
                            guard engine.isHumanTurn else { return }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCard = (selectedCard == card) ? nil : card
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.05)))
    }

    private func actionButtons(for card: GameCard) -> some View {
        HStack(spacing: 8) {
            Button {
                withAnimation { _ = engine.playCard(card, by: engine.human) }
                selectedCard = nil
            } label: {
                Label("Play", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(!engine.isPlayable(card, by: engine.human))

            Button {
                withAnimation { _ = engine.discardCard(card, by: engine.human) }
                selectedCard = nil
            } label: {
                Label("Discard", systemImage: "trash.fill")
                    .font(.subheadline.bold())
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }

    @ViewBuilder
    private var coupFourreBanner: some View {
        if let flash = engine.coupFourreFlash {
            Text("⚡️ \(flash.player) — Coup Fourré with \(flash.safety.rawValue)!")
                .font(.headline)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.top, 50)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation { engine.coupFourreFlash = nil }
                    }
                }
        }
    }

    @ViewBuilder
    private var winnerOverlay: some View {
        if let winner = engine.winner {
            ZStack {
                Color.black.opacity(0.7).ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "flag.checkered.2.crossed")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    Text("\(winner.name) wins!")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Score: \(winner.score)")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))

                    HStack(spacing: 14) {
                        Button("Rematch") {
                            withAnimation { engine.startNewGame() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)

                        Button("Main Menu") { onExit() }
                            .buttonStyle(.bordered)
                            .tint(.white)
                    }
                }
                .padding(32)
                .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial))
                .padding(40)
            }
            .transition(.opacity)
        }
    }

    private func triggerAIIfNeeded() {
        guard !engine.isHumanTurn, engine.winner == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut) {
                engine.aiPlayIfNeeded()
            }
        }
    }
}
