import SwiftUI

enum RankBadgeSize {
    case small, medium, large

    var iconSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 24
        case .large: return 40
        }
    }

    var fontSize: Font {
        switch self {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .body
        }
    }

    var padding: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 12
        }
    }
}

struct RankBadgeView: View {
    let rank: Rank
    var size: RankBadgeSize = .medium

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rank.tier.systemIcon)
                .font(.system(size: size.iconSize))
            Text(rank.displayName)
                .font(size.fontSize)
                .fontWeight(.semibold)
        }
        .foregroundStyle(rankColor)
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding / 2)
        .background(rankColor.opacity(0.12))
        .cornerRadius(8)
    }

    private var rankColor: Color {
        switch rank.tier {
        case .iron: return .gray
        case .bronze: return .brown
        case .silver: return Color(.systemGray)
        case .gold: return .yellow
        case .platinum: return .cyan
        case .diamond: return .blue
        case .ascendant: return .green
        case .immortal: return .red
        }
    }
}
