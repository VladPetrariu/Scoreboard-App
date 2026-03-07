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

    private var rowRankBadge: some View {
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

    private func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: points)) ?? "\(points)") + " pts"
    }
}
