import SwiftUI

// MARK: - App Color Palette (Blue)

struct AppColors {
    // Primary palette
    static let flame = Color(red: 0.15, green: 0.39, blue: 0.92)      // #2663EB — Royal Blue
    static let amber = Color(red: 0.23, green: 0.51, blue: 0.96)      // #3B82F5 — Bright Blue
    static let sunlight = Color(red: 0.38, green: 0.65, blue: 0.98)   // #60A5FA — Sky Blue

    // Semantic aliases
    static let primary = flame
    static let accent = amber
    static let highlight = sunlight

    // Adaptive backgrounds
    static let warmWhiteLight = Color(red: 0.94, green: 0.96, blue: 1.0)    // #F0F5FF
    static let deepCharcoalDark = Color(red: 0.059, green: 0.090, blue: 0.165) // #0f172a
    static let darkSurface = Color(red: 0.043, green: 0.067, blue: 0.125)      // #0b1120

    static var pageBackground: Color {
        deepCharcoalDark
    }

    static var cardBackground: Color {
        darkSurface
    }

    // Distinct tab bar surface
    static let tabBarSurface = Color(red: 0.10, green: 0.12, blue: 0.24)

    // Subtle glass border for frosted cards
    static let glassBorder = Color.white.opacity(0.10)

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
            return [Color(red: 0.31, green: 0.67, blue: 0.996), Color(red: 0.45, green: 0.75, blue: 1.0)]  // #4facfe
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
        case 1: return Color(red: 0.965, green: 0.828, blue: 0.396) // #f6d365 gold glow
        case 2: return Color(red: 0.741, green: 0.765, blue: 0.780) // #bdc3c7 silver glow
        case 3: return Color(red: 0.804, green: 0.498, blue: 0.196) // #cd7f32 bronze glow
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.03))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            )
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.glassBorder))
            .shadow(color: AppColors.flame.opacity(0.10), radius: 12, x: 0, y: 4)
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
