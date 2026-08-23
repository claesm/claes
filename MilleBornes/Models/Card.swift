import SwiftUI

enum CardCategory: Equatable, Hashable {
    case distance, hazard, remedy, safety
}

enum HazardKind: String, CaseIterable, Equatable, Hashable {
    case accident = "Accident"
    case outOfGas = "Out of Gas"
    case flatTire = "Flat Tire"
    case speedLimit = "Speed Limit"
    case stop = "Stop"

    var symbol: String {
        switch self {
        case .accident: return "car.circle.fill"
        case .outOfGas: return "fuelpump.slash.fill"
        case .flatTire: return "circle.slash"
        case .speedLimit: return "speedometer"
        case .stop: return "octagon.fill"
        }
    }
}

enum RemedyKind: String, CaseIterable, Equatable, Hashable {
    case repairs = "Repairs"
    case gasoline = "Gasoline"
    case spareTire = "Spare Tire"
    case endOfLimit = "End of Limit"
    case go = "Go"

    var symbol: String {
        switch self {
        case .repairs: return "wrench.and.screwdriver.fill"
        case .gasoline: return "fuelpump.fill"
        case .spareTire: return "circle.dashed"
        case .endOfLimit: return "speedometer"
        case .go: return "play.circle.fill"
        }
    }

    /// Hazard this remedy cures, nil for Go which cures the "not rolling" start state.
    var cures: HazardKind? {
        switch self {
        case .repairs: return .accident
        case .gasoline: return .outOfGas
        case .spareTire: return .flatTire
        case .endOfLimit: return .speedLimit
        case .go: return .stop
        }
    }
}

enum SafetyKind: String, CaseIterable, Equatable, Hashable {
    case drivingAce = "Driving Ace"
    case extraTank = "Extra Tank"
    case punctureProof = "Puncture-proof"
    case rightOfWay = "Right of Way"

    var symbol: String {
        switch self {
        case .drivingAce: return "person.crop.circle.badge.checkmark"
        case .extraTank: return "fuelpump.circle.fill"
        case .punctureProof: return "shield.checkerboard"
        case .rightOfWay: return "checkmark.seal.fill"
        }
    }

    var guards: HazardKind {
        switch self {
        case .drivingAce: return .accident
        case .extraTank: return .outOfGas
        case .punctureProof: return .flatTire
        case .rightOfWay: return .stop
        }
    }

    /// Right of Way also grants immunity to Speed Limit and instant "rolling" status.
    var alsoImmuneTo: HazardKind? {
        self == .rightOfWay ? .speedLimit : nil
    }
}

struct GameCard: Identifiable, Equatable {
    let id = UUID()
    let category: CardCategory
    let distanceValue: Int?
    let hazard: HazardKind?
    let remedy: RemedyKind?
    let safety: SafetyKind?

    static func distance(_ value: Int) -> GameCard {
        GameCard(category: .distance, distanceValue: value, hazard: nil, remedy: nil, safety: nil)
    }
    static func hazard(_ kind: HazardKind) -> GameCard {
        GameCard(category: .hazard, distanceValue: nil, hazard: kind, remedy: nil, safety: nil)
    }
    static func remedy(_ kind: RemedyKind) -> GameCard {
        GameCard(category: .remedy, distanceValue: nil, hazard: nil, remedy: kind, safety: nil)
    }
    static func safety(_ kind: SafetyKind) -> GameCard {
        GameCard(category: .safety, distanceValue: nil, hazard: nil, remedy: nil, safety: kind)
    }

    var title: String {
        switch category {
        case .distance: return "\(distanceValue ?? 0)"
        case .hazard: return hazard?.rawValue ?? ""
        case .remedy: return remedy?.rawValue ?? ""
        case .safety: return safety?.rawValue ?? ""
        }
    }

    var symbolName: String {
        switch category {
        case .distance: return "arrow.forward.circle.fill"
        case .hazard: return hazard?.symbol ?? "questionmark"
        case .remedy: return remedy?.symbol ?? "questionmark"
        case .safety: return safety?.symbol ?? "questionmark"
        }
    }

    /// Primary accent colors for the card face, used to build gradients.
    var palette: [Color] {
        switch category {
        case .distance: return [Color(red: 0.10, green: 0.45, blue: 0.95), Color(red: 0.03, green: 0.20, blue: 0.55)]
        case .hazard: return [Color(red: 0.92, green: 0.20, blue: 0.24), Color(red: 0.55, green: 0.05, blue: 0.08)]
        case .remedy: return [Color(red: 0.18, green: 0.72, blue: 0.40), Color(red: 0.03, green: 0.38, blue: 0.20)]
        case .safety: return [Color(red: 0.98, green: 0.72, blue: 0.10), Color(red: 0.70, green: 0.45, blue: 0.02)]
        }
    }
}

enum Deck {
    static func freshShuffledDeck() -> [GameCard] {
        var cards: [GameCard] = []

        let distanceCounts: [(Int, Int)] = [(25, 10), (50, 10), (75, 10), (100, 12), (200, 4)]
        for (value, count) in distanceCounts {
            for _ in 0..<count { cards.append(.distance(value)) }
        }

        let hazardCounts: [(HazardKind, Int)] = [
            (.accident, 3), (.outOfGas, 3), (.flatTire, 3), (.speedLimit, 4), (.stop, 5)
        ]
        for (kind, count) in hazardCounts {
            for _ in 0..<count { cards.append(.hazard(kind)) }
        }

        let remedyCounts: [(RemedyKind, Int)] = [
            (.repairs, 6), (.gasoline, 6), (.spareTire, 6), (.endOfLimit, 6), (.go, 14)
        ]
        for (kind, count) in remedyCounts {
            for _ in 0..<count { cards.append(.remedy(kind)) }
        }

        for kind in SafetyKind.allCases { cards.append(.safety(kind)) }

        cards.shuffle()
        return cards
    }
}
