import Foundation

final class PlayerState: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let isAI: Bool

    @Published var hand: [GameCard] = []
    @Published var distancePile: [GameCard] = []
    @Published var battlePile: [GameCard] = []      // top card = active hazard/remedy state
    @Published var safeties: [SafetyKind] = []
    @Published var speedLimited: Bool = false
    @Published var score: Int = 0
    @Published var lastCoupFourre: SafetyKind? = nil

    init(name: String, isAI: Bool) {
        self.name = name
        self.isAI = isAI
    }

    var totalDistance: Int {
        distancePile.reduce(0) { $0 + ($1.distanceValue ?? 0) }
    }

    /// The hazard currently blocking this player, if any.
    var activeHazard: HazardKind? {
        battlePile.last?.hazard
    }

    var isRolling: Bool {
        // Rolling means the top of battle pile is a "Go" remedy or a Right-of-Way safety was used to start, and no hazard is active.
        activeHazard == nil && (battlePile.last?.remedy == .go || battlePile.contains(where: { $0.remedy == .go }))
    }

    var isImmune: (HazardKind) -> Bool {
        { hazard in
            self.safeties.contains { $0.guards == hazard || $0.alsoImmuneTo == hazard }
        }
    }

    func reset() {
        hand.removeAll()
        distancePile.removeAll()
        battlePile.removeAll()
        safeties.removeAll()
        speedLimited = false
        lastCoupFourre = nil
    }
}
