import SwiftUI

enum RankBadgeSize {
    case small, medium, large

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 28
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
        HStack(spacing: size == .large ? 6 : 4) {
            Image(systemName: rank.tier.systemIcon)
                .font(.system(size: size.iconSize, weight: .semibold))

            switch size {
            case .small:
                Text(rank.tier.rawValue)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            case .medium:
                Text(rank.displayName)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            case .large:
                VStack(alignment: .leading, spacing: 1) {
                    Text(rank.tier.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("Division \(rank.division)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .opacity(0.85)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding / 2)
        .background(RankTheme.gradient(for: rank.tier))
        .cornerRadius(size == .large ? 12 : 8)
        .shadow(color: RankTheme.color(for: rank.tier).opacity(0.35), radius: 4, x: 0, y: 2)
    }
}
