import SwiftUI

// MARK: - App Color Palette (Orange & Gold Vibrant)

struct AppColors {
    // Primary palette
    static let flame = Color(red: 1.0, green: 0.42, blue: 0.21)       // #FF6B35 — Deep Orange
    static let amber = Color(red: 1.0, green: 0.65, blue: 0.15)       // #FFA726 — Golden Amber
    static let sunlight = Color(red: 1.0, green: 0.84, blue: 0.31)    // #FFD54F — Warm Gold

    // Semantic aliases
    static let primary = flame
    static let accent = amber
    static let highlight = sunlight

    // Adaptive backgrounds
    static let warmWhiteLight = Color(red: 1.0, green: 0.97, blue: 0.94)    // #FFF8F0
    static let deepCharcoalDark = Color(red: 0.10, green: 0.10, blue: 0.18) // #1A1A2E
    static let darkSurface = Color(red: 0.145, green: 0.145, blue: 0.25)    // #252540

    static var pageBackground: Color {
        Color(.systemGroupedBackground)
    }

    static var cardBackground: Color {
        Color(.systemBackground)
    }

    // Keep semantic colors
    static let positive = Color(red: 0.20, green: 0.72, blue: 0.40)
    static let negative = Color(red: 0.82, green: 0.0, blue: 0.0)

    static let subtleBorder = Color(.separator)
    static let sectionHeader = Color(.secondaryLabel)

    // Gradients
    static let heroGradient = LinearGradient(
        colors: [flame, amber],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let actionGradient = LinearGradient(
        colors: [flame, amber],
        startPoint: .leading, endPoint: .trailing
    )

    static let warmGradient = LinearGradient(
        colors: [amber, sunlight],
        startPoint: .leading, endPoint: .trailing
    )

    static let trophyGradient = LinearGradient(
        colors: [flame, amber],
        startPoint: .top, endPoint: .bottom
    )

    static let cardAccentGradient = LinearGradient(
        colors: [sunlight, flame],
        startPoint: .top, endPoint: .bottom
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

    static func positionGlowColor(_ position: Int) -> Color {
        switch position {
        case 1: return Color(red: 0.95, green: 0.80, blue: 0.20)
        case 2: return Color(red: 0.75, green: 0.78, blue: 0.82)
        case 3: return Color(red: 0.72, green: 0.50, blue: 0.25)
        default: return .clear
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
            .background(AppColors.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.orange.opacity(0.12), radius: 12, x: 0, y: 4)
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
            .background(AppColors.actionGradient)
            .cornerRadius(14)
            .shadow(color: AppColors.flame.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Glow Modifier

struct GlowModifier: ViewModifier {
    let color: Color
    var radius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
    }
}

extension View {
    func glowEffect(color: Color, radius: CGFloat = 8) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
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
