import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: HomeViewModel
    @Binding var showCreateSheet: Bool
    @Binding var showJoinSheet: Bool

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading leaderboards...")
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
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.trophyGradient)
                .shadow(color: AppColors.highlight.opacity(0.4), radius: 12, x: 0, y: 0)
                .shadow(color: AppColors.accent.opacity(0.3), radius: 20, x: 0, y: 4)

            Text("No Leaderboards Yet")
                .font(.title2)
                .fontWeight(.semibold)

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
                        .foregroundStyle(AppColors.navy)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.navy.opacity(0.3), lineWidth: 1.5)
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
        HStack(spacing: 12) {
            // Left accent strip with action gradient
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.actionGradient)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(leaderboard.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Label("\(leaderboard.members.count) members", systemImage: "person.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !leaderboard.gameTypes.isEmpty {
                        Text("\u{00B7}")
                            .foregroundStyle(.secondary)
                        Text(leaderboard.gameTypes.prefix(2).joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if let userId = authViewModel.user?.id,
                   let member = leaderboard.members.first(where: { $0.userId == userId }) {
                    let sortedMembers = leaderboard.sortedMembers
                    if let pos = sortedMembers.firstIndex(where: { $0.userId == userId }) {
                        Text("#\(pos + 1) of \(sortedMembers.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(RankTheme.color(for: member.rank.tier))
                    }
                }
            }

            Spacer()

            if let userId = authViewModel.user?.id,
               let member = leaderboard.members.first(where: { $0.userId == userId }) {
                RankBadgeView(rank: member.rank, size: .small)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .cardStyle(showAccentLine: true)
    }
}
