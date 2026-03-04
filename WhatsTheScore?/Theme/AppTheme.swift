import SwiftUI

// MARK: - App Color Palette

struct AppColors {
    static let primary = Color(.label)                                      // Black (light) / White (dark)
    static let highlight = Color(.secondaryLabel)                           // Medium grey
    static let accent = Color(.secondaryLabel)                              // Medium grey

    // Dark color for emphasis (tab bar active, headings)
    static let navy = Color(.label)

    // Derived semantic colors
    static let pageBackground = Color(.systemGroupedBackground)
    static let subtleBorder = Color(.separator)
    static let sectionHeader = Color(.secondaryLabel)
    static let positive = Color(red: 0.20, green: 0.72, blue: 0.40)        // Keep green for wins
    static let negative = Color(red: 0.82, green: 0.0, blue: 0.0)          // Keep red for losses

    // Gradients — simplified to solid greys
    static let trophyGradient = LinearGradient(
        colors: [Color(.label), Color(.secondaryLabel)],
        startPoint: .top, endPoint: .bottom
    )

    static let heroGradient = LinearGradient(
        colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
        startPoint: .top, endPoint: .bottom
    )

    static let actionGradient = LinearGradient(
        colors: [Color(.darkGray), Color(.darkGray)],
        startPoint: .leading, endPoint: .trailing
    )

    static let warmGradient = LinearGradient(
        colors: [Color(.darkGray), Color(.gray)],
        startPoint: .leading, endPoint: .trailing
    )

    static let cardAccentGradient = LinearGradient(
        colors: [Color(.separator), Color(.separator)],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - Rank Theme

struct RankTheme {

    // MARK: Gradient Colors

    static func gradientColors(for tier: RankTier) -> [Color] {
        switch tier {
        case .iron:
            return [Color(red: 0.35, green: 0.37, blue: 0.40), Color(red: 0.55, green: 0.58, blue: 0.63)]
        case .bronze:
            return [Color(red: 0.72, green: 0.45, blue: 0.20), Color(red: 0.55, green: 0.33, blue: 0.16)]
        case .silver:
            return [Color(red: 0.75, green: 0.78, blue: 0.82), Color(red: 0.50, green: 0.56, blue: 0.65)]
        case .gold:
            return [Color(red: 0.95, green: 0.75, blue: 0.10), Color(red: 0.85, green: 0.65, blue: 0.05)]
        case .platinum:
            return [Color(red: 0.15, green: 0.68, blue: 0.72), Color(red: 0.20, green: 0.82, blue: 0.88)]
        case .diamond:
            return [Color(red: 0.20, green: 0.35, blue: 0.85), Color(red: 0.40, green: 0.60, blue: 0.95)]
        case .ascendant:
            return [Color(red: 0.10, green: 0.60, blue: 0.30), Color(red: 0.35, green: 0.80, blue: 0.25)]
        case .immortal:
            return [Color(red: 0.70, green: 0.10, blue: 0.15), Color(red: 0.90, green: 0.20, blue: 0.55)]
        }
    }

    static func gradient(for tier: RankTier) -> LinearGradient {
        LinearGradient(
            colors: gradientColors(for: tier),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static func color(for tier: RankTier) -> Color {
        gradientColors(for: tier)[0]
    }

    // MARK: Position Colors

    static func positionColor(_ position: Int) -> Color {
        switch position {
        case 1: return Color(red: 0.95, green: 0.75, blue: 0.10) // Gold
        case 2: return Color(red: 0.65, green: 0.68, blue: 0.72) // Silver
        case 3: return Color(red: 0.72, green: 0.45, blue: 0.20) // Bronze
        default: return .secondary
        }
    }

    static func positionGradient(_ position: Int) -> LinearGradient {
        switch position {
        case 1:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.80, blue: 0.20), Color(red: 0.85, green: 0.65, blue: 0.05)],
                startPoint: .top, endPoint: .bottom
            )
        case 2:
            return LinearGradient(
                colors: [Color(red: 0.75, green: 0.78, blue: 0.82), Color(red: 0.55, green: 0.58, blue: 0.65)],
                startPoint: .top, endPoint: .bottom
            )
        case 3:
            return LinearGradient(
                colors: [Color(red: 0.72, green: 0.50, blue: 0.25), Color(red: 0.55, green: 0.33, blue: 0.16)],
                startPoint: .top, endPoint: .bottom
            )
        default:
            return LinearGradient(colors: [.secondary], startPoint: .top, endPoint: .bottom)
        }
    }
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    var showAccentLine: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.subtleBorder, lineWidth: 1)
            )
            .cornerRadius(16)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16, showAccentLine: Bool = false) -> some View {
        modifier(CardStyle(padding: padding, showAccentLine: showAccentLine))
    }
}

// MARK: - Themed Background

struct ThemedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                AppColors.pageBackground
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackground())
    }
}

// MARK: - Section Header Style

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.sectionHeader)
            .textCase(.uppercase)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}

// MARK: - Gradient Button Style

struct GradientButtonStyle: ButtonStyle {
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 14)
            .padding(.horizontal, fullWidth ? 0 : 24)
            .background(Color(.darkGray))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Progress Bar Helpers

struct RankProgressInfo {
    let currentPoints: Int
    let currentThreshold: Int
    let nextThreshold: Int
    let progress: Double // 0.0 to 1.0

    static func calculate(for points: Int) -> RankProgressInfo {
        let rank = Rank.fromPoints(points)
        let currentThreshold = Rank.pointsForRank(tier: rank.tier, division: rank.division)

        // Determine next threshold
        let nextThreshold: Int
        if rank.tier == .immortal && rank.division == 3 {
            // Max rank — show full bar
            nextThreshold = currentThreshold + 100
        } else if rank.division == 3 {
            // Next tier, division 1
            let nextTierIndex = rank.tier.index + 1
            if nextTierIndex < RankTier.allCases.count {
                nextThreshold = Rank.pointsForRank(tier: RankTier.allCases[nextTierIndex], division: 1)
            } else {
                nextThreshold = currentThreshold + 100
            }
        } else {
            nextThreshold = Rank.pointsForRank(tier: rank.tier, division: rank.division + 1)
        }

        let range = nextThreshold - currentThreshold
        let progress: Double
        if rank.tier == .immortal && rank.division == 3 {
            progress = 1.0
        } else if range <= 0 {
            progress = 1.0
        } else {
            progress = min(1.0, max(0.0, Double(points - currentThreshold) / Double(range)))
        }

        return RankProgressInfo(
            currentPoints: points,
            currentThreshold: currentThreshold,
            nextThreshold: nextThreshold,
            progress: progress
        )
    }
}
