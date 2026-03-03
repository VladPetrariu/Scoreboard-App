import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignOutConfirmation = false
    @State private var showResetStatsConfirmation = false
    @State private var isResettingStats = false
    var leaderboards: [Leaderboard] = []

    private var stats: PlayerStats {
        guard let userId = authViewModel.user?.id else {
            return PlayerStats(totalGames: 0, totalWins: 0, winRate: 0, highestRank: nil)
        }
        return PlayerStats.compute(userId: userId, leaderboards: leaderboards)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User info card
                VStack(spacing: 0) {
                    // Navy gradient header
                    LinearGradient(
                        colors: [AppColors.navy, AppColors.navy.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 60)
                    .overlay(alignment: .bottomLeading) {
                        // Avatar overlapping the header
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(AppColors.warmGradient)
                            .background(Circle().fill(Color(.systemBackground)).frame(width: 52, height: 52))
                            .offset(x: 16, y: 28)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.user?.displayName ?? "Player")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(authViewModel.user?.email ?? "")
                            .font(.caption)
                            .foregroundStyle(AppColors.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 36)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.subtleBorder, lineWidth: 1)
                )
                .cornerRadius(16)
                .shadow(color: AppColors.navy.opacity(0.08), radius: 8, x: 0, y: 2)

                // Stats grid — always visible
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    StatCard(
                        icon: "gamecontroller.fill",
                        value: "\(stats.totalGames)",
                        label: "Games Played",
                        color: AppColors.navy
                    )
                    StatCard(
                        icon: "trophy.fill",
                        value: "\(stats.totalWins)",
                        label: "Wins",
                        color: AppColors.accent
                    )
                    StatCard(
                        icon: "percent",
                        value: stats.totalGames > 0 ? String(format: "%.0f%%", stats.winRate) : "0%",
                        label: "Win Rate",
                        color: AppColors.accent
                    )
                    if let highest = stats.highestRank {
                        StatCard(
                            icon: highest.tier.systemIcon,
                            value: highest.displayName,
                            label: "Highest Rank",
                            color: RankTheme.color(for: highest.tier)
                        )
                    } else {
                        StatCard(
                            icon: "questionmark.circle",
                            value: "-",
                            label: "Highest Rank",
                            color: .secondary
                        )
                    }
                }

                // Reset Stats
                if !leaderboards.isEmpty {
                    Button {
                        showResetStatsConfirmation = true
                    } label: {
                        HStack {
                            if isResettingStats {
                                ProgressView()
                                    .tint(AppColors.accent)
                            } else {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            Text("Reset Stats")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(AppColors.accent)
                    }
                    .disabled(isResettingStats)
                    .padding(16)
                    .background(AppColors.accent.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }

                // Sign out
                Button(role: .destructive) {
                    showSignOutConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(AppColors.primary)
                }
                .padding(16)
                .background(AppColors.primary.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .themedBackground()
        .navigationTitle("Profile")
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .confirmationDialog("Reset Stats", isPresented: $showResetStatsConfirmation) {
            Button("Reset", role: .destructive) {
                resetStats()
            }
        } message: {
            Text("This will reset your games played, wins, and points across all leaderboards. Your rank will return to the starting rank of each leaderboard.")
        }
    }

    private func resetStats() {
        guard let userId = authViewModel.user?.id else { return }
        let ids = leaderboards.map { $0.id }
        isResettingStats = true
        Task {
            try? await LeaderboardService.shared.resetMemberStats(userId: userId, leaderboardIds: ids)
            isResettingStats = false
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 2)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(AppColors.accent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            ZStack {
                Color(.systemBackground)
                color.opacity(0.04)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: AppColors.navy.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Stats Computation

private struct PlayerStats {
    let totalGames: Int
    let totalWins: Int
    let winRate: Double
    let highestRank: Rank?

    static func compute(userId: String, leaderboards: [Leaderboard]) -> PlayerStats {
        var totalGames = 0
        var totalWins = 0
        var highestRank: Rank? = nil

        for leaderboard in leaderboards {
            guard let member = leaderboard.members.first(where: { $0.userId == userId }) else { continue }
            totalGames += member.gamesPlayed
            totalWins += member.wins

            let rank = member.rank
            if let current = highestRank {
                if rank.tier.index > current.tier.index ||
                    (rank.tier.index == current.tier.index && rank.division > current.division) {
                    highestRank = rank
                }
            } else {
                highestRank = rank
            }
        }

        let winRate = totalGames > 0 ? (Double(totalWins) / Double(totalGames)) * 100 : 0
        return PlayerStats(totalGames: totalGames, totalWins: totalWins, winRate: winRate, highestRank: highestRank)
    }
}
