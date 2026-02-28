import Foundation

enum RankTier: String, CaseIterable, Codable {
    case iron = "Iron"
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    case ascendant = "Ascendant"
    case immortal = "Immortal"

    var index: Int {
        switch self {
        case .iron: return 0
        case .bronze: return 1
        case .silver: return 2
        case .gold: return 3
        case .platinum: return 4
        case .diamond: return 5
        case .ascendant: return 6
        case .immortal: return 7
        }
    }

    var color: String {
        switch self {
        case .iron: return "RankIron"
        case .bronze: return "RankBronze"
        case .silver: return "RankSilver"
        case .gold: return "RankGold"
        case .platinum: return "RankPlatinum"
        case .diamond: return "RankDiamond"
        case .ascendant: return "RankAscendant"
        case .immortal: return "RankImmortal"
        }
    }

    var systemIcon: String {
        switch self {
        case .iron: return "shield"
        case .bronze: return "shield.lefthalf.filled"
        case .silver: return "shield.fill"
        case .gold: return "star"
        case .platinum: return "star.fill"
        case .diamond: return "diamond"
        case .ascendant: return "diamond.fill"
        case .immortal: return "crown.fill"
        }
    }
}

struct Rank: Equatable, Codable {
    let tier: RankTier
    let division: Int // 1, 2, or 3

    var displayName: String {
        "\(tier.rawValue) \(division)"
    }

    static func fromPoints(_ points: Int) -> Rank {
        if points < 0 {
            return Rank(tier: .iron, division: 1)
        }

        let tierIndex = points / 300
        let divisionOffset = (points % 300) / 100

        if tierIndex >= RankTier.allCases.count {
            return Rank(tier: .immortal, division: 3)
        }

        let tier = RankTier.allCases[tierIndex]
        let division = divisionOffset + 1

        return Rank(tier: tier, division: division)
    }

    static func pointsForRank(tier: RankTier, division: Int) -> Int {
        return tier.index * 300 + (division - 1) * 100
    }
}
