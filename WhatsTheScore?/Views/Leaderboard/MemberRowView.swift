import SwiftUI

struct MemberRowView: View {
    let member: LeaderboardMember
    let position: Int
    var isCurrentUser: Bool = false

    private var progressInfo: RankProgressInfo {
        RankProgressInfo.calculate(for: member.points)
    }

    var body: some View {
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
                            .foregroundStyle(AppColors.primary)
                            .fontWeight(.semibold)
                    }
                }

                Text("\(member.gamesPlayed) games \u{00B7} \(member.wins) wins")
                    .font(.caption)
                    .foregroundStyle(AppColors.accent)
            }

            Spacer()

            // Points
            Text("\(member.points) pts")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.navy.opacity(0.08))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(RankTheme.gradient(for: member.rank.tier))
                        .frame(width: geo.size.width * progressInfo.progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 14)
        }
        .background(
            ZStack {
                Color(.systemBackground)
                AppColors.navy.opacity(0.03)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrentUser ? AppColors.primary.opacity(0.4) : AppColors.subtleBorder, lineWidth: isCurrentUser ? 1.5 : 1)
        )
        .overlay(alignment: .leading) {
            // Left accent strip
            RoundedRectangle(cornerRadius: 2)
                .fill(RankTheme.gradient(for: member.rank.tier))
                .frame(width: 4)
                .padding(.vertical, 6)
        }
        .cornerRadius(16)
        .shadow(color: AppColors.navy.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private var positionCircle: some View {
        ZStack {
            if position <= 3 {
                Circle()
                    .fill(RankTheme.positionGradient(position))
                    .frame(width: 32, height: 32)
            } else {
                Circle()
                    .fill(AppColors.navy.opacity(0.10))
                    .frame(width: 32, height: 32)
            }
            Text("\(position)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(position <= 3 ? .white : AppColors.navy)
        }
    }
}
