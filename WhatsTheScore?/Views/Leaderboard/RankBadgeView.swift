import SwiftUI

enum RankBadgeSize {
    case small, medium, large, hero

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 28
        case .hero: return 36
        }
    }

    var fontSize: Font {
        switch self {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .body
        case .hero: return .title2
        }
    }

    var padding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 10
        case .large: return 14
        case .hero: return 18
        }
    }
}

struct RankBadgeView: View {
    let rank: Rank
    var size: RankBadgeSize = .medium

    var body: some View {
        if let config = Self.imageBadgeConfig(for: rank.tier) {
            imageBadge(config: config)
        } else {
            defaultBadge
        }
    }

    private struct ImageBadgeConfig {
        let assetName: String
        let gradientTop: Color
        let gradientBottom: Color
    }

    private static func imageBadgeConfig(for tier: RankTier) -> ImageBadgeConfig? {
        switch tier {
        case .iron:
            return ImageBadgeConfig(
                assetName: "iron_badge",
                gradientTop: Color(red: 0.75, green: 0.78, blue: 0.82),
                gradientBottom: Color(red: 0.45, green: 0.48, blue: 0.53)
            )
        case .bronze:
            return ImageBadgeConfig(
                assetName: "bronze_badge",
                gradientTop: Color(red: 0.85, green: 0.60, blue: 0.30),
                gradientBottom: Color(red: 0.55, green: 0.33, blue: 0.16)
            )
        case .silver:
            return ImageBadgeConfig(
                assetName: "silver_badge",
                gradientTop: Color(red: 0.82, green: 0.84, blue: 0.88),
                gradientBottom: Color(red: 0.55, green: 0.58, blue: 0.65)
            )
        case .gold:
            return ImageBadgeConfig(
                assetName: "gold_badge",
                gradientTop: Color(red: 0.95, green: 0.78, blue: 0.20),
                gradientBottom: Color(red: 0.75, green: 0.55, blue: 0.08)
            )
        case .platinum:
            return ImageBadgeConfig(
                assetName: "platinum_badge",
                gradientTop: Color(red: 0.40, green: 0.78, blue: 0.85),
                gradientBottom: Color(red: 0.20, green: 0.55, blue: 0.65)
            )
        case .diamond:
            return ImageBadgeConfig(
                assetName: "diamond_badge",
                gradientTop: Color(red: 0.45, green: 0.75, blue: 1.0),
                gradientBottom: Color(red: 0.25, green: 0.50, blue: 0.85)
            )
        case .immortal:
            return ImageBadgeConfig(
                assetName: "immortal_badge",
                gradientTop: Color(red: 0.90, green: 0.25, blue: 0.20),
                gradientBottom: Color(red: 0.60, green: 0.10, blue: 0.12)
            )
        default:
            return nil
        }
    }

    private func imageBadge(config: ImageBadgeConfig) -> some View {
        let badgeHeight: CGFloat = {
            switch size {
            case .small: return 24
            case .medium: return 32
            case .large: return 48
            case .hero: return 100
            }
        }()
        let divisionFont: Font = {
            switch size {
            case .small: return .system(size: 10, weight: .heavy, design: .rounded)
            case .medium: return .system(size: 12, weight: .heavy, design: .rounded)
            case .large: return .system(size: 18, weight: .heavy, design: .rounded)
            case .hero: return .system(size: 34, weight: .heavy, design: .rounded)
            }
        }()

        return HStack(spacing: size == .large ? 6 : 4) {
            Image(config.assetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: badgeHeight)

            Text("\(rank.division)")
                .font(divisionFont)
                .foregroundStyle(
                    LinearGradient(
                        colors: [config.gradientTop, config.gradientBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
        }
    }

    private var defaultBadge: some View {
        HStack(spacing: size == .large || size == .hero ? 6 : 4) {
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
            case .large, .hero:
                VStack(alignment: .leading, spacing: 1) {
                    Text(rank.tier.rawValue)
                        .font(size == .hero ? .title3 : .subheadline)
                        .fontWeight(.bold)
                    Text("Division \(rank.division)")
                        .font(size == .hero ? .caption : .caption2)
                        .fontWeight(.medium)
                        .opacity(0.85)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding / 2)
        .background(RankTheme.gradient(for: rank.tier))
        .cornerRadius(size == .large || size == .hero ? 10 : 6)
        .shadow(color: RankTheme.color(for: rank.tier).opacity(0.5), radius: 6, x: 0, y: 2)
    }
}
