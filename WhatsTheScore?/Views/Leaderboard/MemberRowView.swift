import SwiftUI

struct MemberRowView: View {
    let member: LeaderboardMember
    let position: Int
    var isCurrentUser: Bool = false

    private var progressInfo: RankProgressInfo {
        RankProgressInfo.calculate(for: member.points)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left rank-tier accent line
            RoundedRectangle(cornerRadius: 1)
                .fill(RankTheme.gradient(for: member.rank.tier))
                .frame(width: 3)
                .padding(.vertical, 6)

            HStack(spacing: 12) {
                // Position circle
                positionCircle

                // Rank badge
                RankBadgeView(rank: member.rank, size: .small)

                // Name and stats
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(member.displayName)
                            .font(.body)
                            .fontWeight(isCurrentUser ? .bold : .medium)
                            .lineLimit(1)
                        if isCurrentUser {
                            Text("(You)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                        }
                    }

                    Text("\(member.gamesPlayed) games \u{00B7} \(member.wins) wins")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Points
                Text("\(member.points) pts")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .overlay(alignment: .bottom) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(RankTheme.gradient(for: member.rank.tier))
                        .frame(width: geo.size.width * progressInfo.progress, height: 5)
                }
            }
            .frame(height: 5)
            .padding(.horizontal, 14)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrentUser ? AppColors.flame : AppColors.glassBorder, lineWidth: isCurrentUser ? 1.5 : 1)
        )
        .shadow(color: AppColors.flame.opacity(0.10), radius: 10, x: 0, y: 3)
    }

    private var positionCircle: some View {
        ZStack {
            if position <= 3 {
                Circle()
                    .fill(RankTheme.positionGradient(position))
                    .frame(width: 32, height: 32)
                    .shadow(color: RankTheme.positionGlowColor(position).opacity(0.5), radius: 6, x: 0, y: 0)
            } else {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 32, height: 32)
            }
            Text("\(position)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(position <= 3 ? .white : .primary)
        }
    }
}
