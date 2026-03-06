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
                            RoundedRectangle(cornerRadius: 14)
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
        HStack(spacing: 0) {
            // Left accent strip
            RoundedRectangle(cornerRadius: 1.5)
                .fill(
                    currentUserRankGradient(in: leaderboard)
                )
                .frame(width: 3)
                .padding(.vertical, 8)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(leaderboard.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Label("\(leaderboard.members.count)", systemImage: "person.2")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if !leaderboard.gameTypes.isEmpty {
                            Text(leaderboard.gameTypes.prefix(2).joined(separator: ", "))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppColors.flame.opacity(0.8))
                                .cornerRadius(6)
                                .lineLimit(1)
                        }
                    }

                    if let userId = authViewModel.user?.id,
                       let member = leaderboard.members.first(where: { $0.userId == userId }) {
                        let sortedMembers = leaderboard.sortedMembers
                        if let pos = sortedMembers.firstIndex(where: { $0.userId == userId }) {
                            HStack(spacing: 4) {
                                // Position circle
                                ZStack {
                                    Circle()
                                        .fill(RankTheme.positionGradient(pos + 1))
                                        .frame(width: 18, height: 18)
                                    Text("\(pos + 1)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(pos < 3 ? .white : .primary)
                                }

                                Text("of \(sortedMembers.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(RankTheme.color(for: member.rank.tier))
                            }
                        }
                    }
                }

                Spacer()

                if let userId = authViewModel.user?.id,
                   let member = leaderboard.members.first(where: { $0.userId == userId }) {
                    RankBadgeView(rank: member.rank, size: .small)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.orange.opacity(0.12), radius: 12, x: 0, y: 4)
    }

    private func currentUserRankGradient(in leaderboard: Leaderboard) -> LinearGradient {
        if let userId = authViewModel.user?.id,
           let member = leaderboard.members.first(where: { $0.userId == userId }) {
            return RankTheme.gradient(for: member.rank.tier)
        }
        return AppColors.cardAccentGradient
    }
}
