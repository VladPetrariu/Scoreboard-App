import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: HomeViewModel
    @Binding var showCreateSheet: Bool
    @Binding var showJoinSheet: Bool

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.leaderboards.isEmpty {
                emptyState
            } else {
                leaderboardList
            }
        }
        .themedBackground()
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            // Trophy in gradient circle
            ZStack {
                Circle()
                    .fill(AppColors.heroGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.flame.opacity(0.4), radius: 12, x: 0, y: 4)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }

            Text("No Leaderboards Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Create a leaderboard to start competing\nwith your friends, or join one with an invite code.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button {
                    showCreateSheet = true
                } label: {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .buttonStyle(GradientButtonStyle(fullWidth: false))

                Button {
                    showJoinSheet = true
                } label: {
                    Label("Join", systemImage: "person.badge.plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.flame)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.flame, lineWidth: 1.5)
                        )
                }
            }
        }
        .padding()
    }

    private var leaderboardList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.leaderboards) { leaderboard in
                    NavigationLink(destination: LeaderboardDetailView(leaderboard: leaderboard)) {
                        leaderboardCard(leaderboard)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func leaderboardCard(_ leaderboard: Leaderboard) -> some View {
        let userId = authViewModel.user?.id
        let member = userId.flatMap { uid in leaderboard.members.first(where: { $0.userId == uid }) }
        let sortedMembers = leaderboard.sortedMembers
        let position = userId.flatMap { uid in sortedMembers.firstIndex(where: { $0.userId == uid }).map { $0 + 1 } }

        return HStack(spacing: 10) {
            // Position number
            if let position {
                Text("\(position)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.gray)
                    .frame(width: 28, alignment: .center)
            }

            // Info column
            VStack(alignment: .leading, spacing: 4) {
                // Rank badge + name row
                HStack(spacing: 8) {
                    if let member {
                        cardRankBadge(rank: member.rank)
                    }

                    Text(leaderboard.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                // Stats row
                HStack(spacing: 8) {
                    Text("\(leaderboard.members.count) members")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)

                    if !leaderboard.gameTypes.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 6))
                            Text(leaderboard.gameTypes.prefix(2).joined(separator: ", ").uppercased())
                                .font(.system(size: 7, weight: .bold))
                                .tracking(0.5)
                        }
                        .foregroundStyle(AppColors.flame)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(AppColors.flame.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(AppColors.flame.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                }
            }

            Spacer()

            // Points
            if let member {
                Text(formatPoints(member.points))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
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
            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 0, topTrailingRadius: 0)
                .fill(currentUserRankColor(in: leaderboard))
                .frame(width: 4)
        }
    }

    @ViewBuilder
    private func cardRankBadge(rank: Rank) -> some View {
        if let badge = Self.imageBadgeAsset(for: rank.tier) {
            HStack(spacing: 4) {
                Image(badge.asset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 29)

                Text("\(rank.division)")
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
            let color = RankTheme.color(for: rank.tier)
            HStack(spacing: 3) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)

                Text(rank.displayName.uppercased())
                    .font(.system(size: 7, weight: .bold))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }

    private func currentUserRankColor(in leaderboard: Leaderboard) -> Color {
        if let userId = authViewModel.user?.id,
           let member = leaderboard.members.first(where: { $0.userId == userId }) {
            return RankTheme.color(for: member.rank.tier)
        }
        return AppColors.flame
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
