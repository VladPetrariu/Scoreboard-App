import SwiftUI

struct MemberRowView: View {
    let member: LeaderboardMember
    let position: Int
    var isCurrentUser: Bool = false

    private var rankColor: Color {
        RankTheme.color(for: member.rank.tier)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Position number
            Text("\(position)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.gray)
                .frame(width: 28, alignment: .center)

            // Info column
            VStack(alignment: .leading, spacing: 4) {
                // Rank badge + Name row
                HStack(spacing: 8) {
                    rowRankBadge

                    Text(isCurrentUser ? "\(member.displayName) (You)" : member.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                // Stats
                Text("\(member.gamesPlayed) games \u{00B7} \(member.wins) wins")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            // Points
            Text(formatPoints(member.points))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            // Left rank-color accent border
            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 0, topTrailingRadius: 0)
                .fill(rankColor)
                .frame(width: 4)
        }
    }

    @ViewBuilder
    private var rowRankBadge: some View {
        if let badge = Self.imageBadgeAsset(for: member.rank.tier) {
            HStack(spacing: 4) {
                Image(badge.asset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 29)

                Text("\(member.rank.division)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [badge.gradientTop, badge.gradientBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
            }
        } else {
            HStack(spacing: 3) {
                Circle()
                    .fill(rankColor)
                    .frame(width: 6, height: 6)

                Text(member.rank.displayName.uppercased())
                    .font(.system(size: 7, weight: .bold))
            }
            .foregroundStyle(rankColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(rankColor.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(rankColor.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }

    private static func imageBadgeAsset(for tier: RankTier) -> (asset: String, gradientTop: Color, gradientBottom: Color)? {
        switch tier {
        case .iron:
            return ("iron_badge", Color(red: 0.75, green: 0.78, blue: 0.82), Color(red: 0.45, green: 0.48, blue: 0.53))
        case .bronze:
            return ("bronze_badge", Color(red: 0.85, green: 0.60, blue: 0.30), Color(red: 0.55, green: 0.33, blue: 0.16))
        case .silver:
            return ("silver_badge", Color(red: 0.82, green: 0.84, blue: 0.88), Color(red: 0.55, green: 0.58, blue: 0.65))
        case .gold:
            return ("gold_badge", Color(red: 0.95, green: 0.78, blue: 0.20), Color(red: 0.75, green: 0.55, blue: 0.08))
        case .platinum:
            return ("platinum_badge", Color(red: 0.40, green: 0.78, blue: 0.85), Color(red: 0.20, green: 0.55, blue: 0.65))
        case .diamond:
            return ("diamond_badge", Color(red: 0.45, green: 0.75, blue: 1.0), Color(red: 0.25, green: 0.50, blue: 0.85))
        case .immortal:
            return ("immortal_badge", Color(red: 0.90, green: 0.25, blue: 0.20), Color(red: 0.60, green: 0.10, blue: 0.12))
        default:
            return nil
        }
    }

    private func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: points)) ?? "\(points)") + " pts"
    }
}
