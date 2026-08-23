import Foundation
import SwiftUI

enum TurnPhase {
    case draw, play, roundOver
}

final class GameEngine: ObservableObject {
    static let target = 1000

    @Published var deck: [GameCard] = []
    @Published var discardPile: [GameCard] = []
    @Published var human = PlayerState(name: "You", isAI: false)
    @Published var ai = PlayerState(name: "Rival", isAI: true)
    @Published var currentTurn: UUID
    @Published var winner: PlayerState?
    @Published var log: [String] = []
    @Published var coupFourreFlash: (player: String, safety: SafetyKind)? = nil

    private var lastHazardOnHuman: HazardKind?
    private var lastHazardOnAI: HazardKind?

    init() {
        currentTurn = UUID()
        startNewGame()
    }

    // MARK: - Setup

    func startNewGame() {
        deck = Deck.freshShuffledDeck()
        discardPile.removeAll()
        human.reset()
        ai.reset()
        winner = nil
        log = ["New race started! First to \(Self.target) miles wins."]
        lastHazardOnHuman = nil
        lastHazardOnAI = nil

        for _ in 0..<6 {
            human.hand.append(draw())
            ai.hand.append(draw())
        }
        currentTurn = human.id
        drawForTurn(human)
    }

    private func draw() -> GameCard {
        if deck.isEmpty {
            // Reshuffle discard pile back into the deck if the draw pile runs dry.
            deck = discardPile.shuffled()
            discardPile.removeAll()
        }
        return deck.isEmpty ? GameCard.remedy(.go) : deck.removeLast()
    }

    private func drawForTurn(_ player: PlayerState) {
        guard player.hand.count < 7, !deck.isEmpty || !discardPile.isEmpty else { return }
        player.hand.append(draw())
    }

    // MARK: - Turn helpers

    var isHumanTurn: Bool { currentTurn == human.id }

    func player(for id: UUID) -> PlayerState { id == human.id ? human : ai }
    func opponent(of player: PlayerState) -> PlayerState { player === human ? ai : human }

    // MARK: - Legality

    func canPlayDistance(_ card: GameCard, player: PlayerState) -> Bool {
        guard let value = card.distanceValue else { return false }
        guard player.activeHazard == nil, player.isRolling || player.battlePile.contains(where: { $0.remedy == .go }) else { return false }
        if player.speedLimited && value > 50 { return false }
        if player.totalDistance + value > Self.target { return false }
        return true
    }

    func canPlayHazard(_ card: GameCard, from player: PlayerState) -> Bool {
        guard let hazard = card.hazard else { return false }
        let target = opponent(of: player)
        if target.activeHazard != nil { return false }
        if target.isImmune(hazard) { return false }
        if hazard == .speedLimit && target.speedLimited { return false }
        return true
    }

    func canPlayRemedy(_ card: GameCard, player: PlayerState) -> Bool {
        guard let remedy = card.remedy else { return false }
        if remedy == .endOfLimit { return player.speedLimited }
        if remedy == .go { return player.activeHazard == nil }
        return player.activeHazard == remedy.cures
    }

    func canPlaySafety(_ card: GameCard, player: PlayerState) -> Bool {
        guard let safety = card.safety else { return false }
        return !player.safeties.contains(safety)
    }

    func isPlayable(_ card: GameCard, by player: PlayerState) -> Bool {
        switch card.category {
        case .distance: return canPlayDistance(card, player: player)
        case .hazard: return canPlayHazard(card, from: player)
        case .remedy: return canPlayRemedy(card, player: player)
        case .safety: return canPlaySafety(card, player: player)
        }
    }

    // MARK: - Actions

    @discardableResult
    func playCard(_ card: GameCard, by player: PlayerState) -> Bool {
        guard winner == nil, isPlayable(card, by: player) else { return false }
        guard let index = player.hand.firstIndex(of: card) else { return false }

        var grantsExtraTurn = false

        switch card.category {
        case .distance:
            player.hand.remove(at: index)
            player.distancePile.append(card)
            log.append("\(player.name) drives \(card.title) miles. (Total: \(player.totalDistance))")
            if player.totalDistance >= Self.target {
                finishRound(winner: player)
                return true
            }

        case .hazard:
            let target = opponent(of: player)
            player.hand.remove(at: index)
            target.battlePile.append(card)
            if target === human { lastHazardOnHuman = card.hazard } else { lastHazardOnAI = card.hazard }
            log.append("\(player.name) plays \(card.title) against \(target.name)!")

        case .remedy:
            player.hand.remove(at: index)
            player.battlePile.append(card)
            if card.remedy == .endOfLimit {
                player.speedLimited = false
                log.append("\(player.name) removes the speed limit.")
            } else {
                log.append("\(player.name) plays \(card.title) and is rolling again.")
            }

        case .safety:
            guard let safety = card.safety else { return false }
            let wasCoupFourre = (player === human ? lastHazardOnHuman : lastHazardOnAI) == safety.guards
                && player.activeHazard == safety.guards
            player.hand.remove(at: index)
            player.safeties.append(safety)
            if player.activeHazard == safety.guards {
                player.battlePile.append(GameCard.remedy(.go))
            }
            if safety == .rightOfWay {
                player.speedLimited = false
            }
            log.append("\(player.name) plays the \(card.title) safety card.")
            if wasCoupFourre {
                player.score += 300
                player.lastCoupFourre = safety
                coupFourreFlash = (player.name, safety)
                log.append("⚡️ Coup Fourré! \(player.name) earns 300 bonus points and an extra turn.")
                grantsExtraTurn = true
            }
        }

        if !grantsExtraTurn {
            endTurn()
        } else {
            drawForTurn(player)
            if player.isAI && winner == nil {
                performAITurn()
            }
        }
        return true
    }

    @discardableResult
    func discardCard(_ card: GameCard, by player: PlayerState) -> Bool {
        guard winner == nil, let index = player.hand.firstIndex(of: card) else { return false }
        player.hand.remove(at: index)
        discardPile.append(card)
        log.append("\(player.name) discards \(card.title).")
        endTurn()
        return true
    }

    private func endTurn() {
        let finishing = player(for: currentTurn)
        drawForTurn(finishing)
        currentTurn = opponent(of: finishing).id
        drawForTurn(opponent(of: finishing))
    }

    private func finishRound(winner: PlayerState) {
        self.winner = winner
        winner.score += 1000 // covering the full 1000-mile distance
        if opponent(of: winner).totalDistance == 0 { winner.score += 200 } // shutout bonus
        winner.score += winner.safeties.count * 100
        log.append("🏁 \(winner.name) wins the race with \(winner.totalDistance) miles!")
    }

    // MARK: - Simple AI

    func aiPlayIfNeeded() {
        guard winner == nil, currentTurn == ai.id else { return }
        performAITurn()
    }

    private func performAITurn() {
        // 1. Coup fourré opportunity: play a safety that cures our own active hazard.
        if let hazard = ai.activeHazard,
           let safetyCard = ai.hand.first(where: { $0.safety?.guards == hazard }) {
            playCard(safetyCard, by: ai)
            return
        }

        // 2. Play a distance card, preferring the largest legal value.
        let playableDistances = ai.hand
            .filter { canPlayDistance($0, player: ai) }
            .sorted { ($0.distanceValue ?? 0) > ($1.distanceValue ?? 0) }
        if let best = playableDistances.first {
            playCard(best, by: ai)
            return
        }

        // 3. Fix our own hazard/speed limit.
        if let hazard = ai.activeHazard,
           let remedyCard = ai.hand.first(where: { $0.remedy?.cures == hazard }) {
            playCard(remedyCard, by: ai)
            return
        }
        if ai.speedLimited, let endLimit = ai.hand.first(where: { $0.remedy == .endOfLimit }) {
            playCard(endLimit, by: ai)
            return
        }
        if ai.activeHazard == nil && !ai.isRolling, let go = ai.hand.first(where: { $0.remedy == .go }) {
            playCard(go, by: ai)
            return
        }

        // 4. Play a safety proactively if we hold one and aren't threatened yet.
        if let safety = ai.hand.first(where: { canPlaySafety($0, player: ai) }) {
            playCard(safety, by: ai)
            return
        }

        // 5. Attack the human if they are rolling and vulnerable.
        let attackPriority: [HazardKind] = [.stop, .speedLimit, .flatTire, .outOfGas, .accident]
        for kind in attackPriority {
            if let hazardCard = ai.hand.first(where: { $0.hazard == kind }), canPlayHazard(hazardCard, from: ai) {
                playCard(hazardCard, by: ai)
                return
            }
        }

        // 6. Nothing useful: discard the least valuable card.
        if let worst = ai.hand.min(by: { discardScore($0) < discardScore($1) }) {
            discardCard(worst, by: ai)
        }
    }

    private func discardScore(_ card: GameCard) -> Int {
        switch card.category {
        case .distance: return card.distanceValue ?? 0
        case .remedy: return 40
        case .hazard: return 60
        case .safety: return 1000
        }
    }
}
