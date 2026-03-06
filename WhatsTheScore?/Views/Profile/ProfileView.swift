import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignOutConfirmation = false
    @State private var showResetStatsConfirmation = false
    @State private var isResettingStats = false
    var leaderboards: [Leaderboard] = []

    private var stats: PlayerStats {
        guard let user = authViewModel.user else {
            return PlayerStats(totalGames: 0, totalWins: 0, winRate: 0, highestRank: nil)
        }
        return PlayerStats.compute(user: user, leaderboards: leaderboards)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User info card
                VStack(spacing: 0) {
                    // Blue gradient header
                    AppColors.heroGradient
                        .frame(height: 60)
                        .overlay(alignment: .bottomLeading) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.sunlight)
                                    .frame(width: 56, height: 56)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(.white)
                            }
                            .background(Circle().fill(AppColors.cardBackground).frame(width: 60, height: 60))
                            .offset(x: 16, y: 28)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.user?.displayName ?? "Player")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(authViewModel.user?.email ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 36)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.glassBorder))
                .shadow(color: AppColors.flame.opacity(0.10), radius: 12, x: 0, y: 4)

                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    StatCard(
                        icon: "gamecontroller.fill",
                        value: "\(stats.totalGames)",
                        label: "Games Played"
                    )
                    StatCard(
                        icon: "trophy.fill",
                        value: "\(stats.totalWins)",
                        label: "Wins"
                    )
                    StatCard(
                        icon: "percent",
                        value: stats.totalGames > 0 ? String(format: "%.0f%%", stats.winRate) : "0%",
                        label: "Win Rate"
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
                            label: "Highest Rank"
                        )
                    }
                }

                // Reset Stats
                if !leaderboards.isEmpty {
                    Button {
                        showResetStatsConfirmation = true
                    } label: {
                        HStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppColors.cardAccentGradient)
                                .frame(width: 4)
                                .padding(.vertical, 10)

                            HStack {
                                if isResettingStats {
                                    ProgressView()
                                        .tint(.secondary)
                                } else {
                                    Image(systemName: "arrow.counterclockwise")
                                }
                                Text("Reset Stats")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(isResettingStats)
                    .padding(.trailing, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.glassBorder))
                    .shadow(color: AppColors.flame.opacity(0.10), radius: 12, x: 0, y: 4)
                }

                // Sign out
                Button(role: .destructive) {
                    showSignOutConfirmation = true
                } label: {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(colors: [.red.opacity(0.8), .red.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 4)
                            .padding(.vertical, 10)

                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.red)
                    }
                }
                .padding(.trailing, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.glassBorder))
                .shadow(color: AppColors.flame.opacity(0.10), radius: 12, x: 0, y: 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .themedBackground()
        .toolbar(.hidden, for: .navigationBar)
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
            Text("This will reset your profile stats (games played, wins, and win rate) to zero. Your leaderboard stats and ranks will not be affected.")
        }
    }

    private func resetStats() {
        guard let user = authViewModel.user else { return }
        let rawStats = PlayerStats.computeRaw(userId: user.id, leaderboards: leaderboards)
        isResettingStats = true
        Task {
            let db = Firestore.firestore()
            try? await db.collection("users").document(user.id).updateData([
                "statsResetGamesPlayed": rawStats.totalGames,
                "statsResetWins": rawStats.totalWins
            ])
            authViewModel.user?.statsResetGamesPlayed = rawStats.totalGames
            authViewModel.user?.statsResetWins = rawStats.totalWins
            isResettingStats = false
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.cardAccentGradient)
                .frame(width: 3)
                .padding(.vertical, 10)

            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(color)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.glassBorder))
        .shadow(color: AppColors.flame.opacity(0.10), radius: 10, x: 0, y: 3)
    }
}

// MARK: - Stats Computation

private struct PlayerStats {
    let totalGames: Int
    let totalWins: Int
    let winRate: Double
    let highestRank: Rank?

    static func computeRaw(userId: String, leaderboards: [Leaderboard]) -> PlayerStats {
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

    static func compute(user: AppUser, leaderboards: [Leaderboard]) -> PlayerStats {
        let raw = computeRaw(userId: user.id, leaderboards: leaderboards)
        let adjustedGames = max(0, raw.totalGames - user.statsResetGamesPlayed)
        let adjustedWins = max(0, raw.totalWins - user.statsResetWins)
        let winRate = adjustedGames > 0 ? (Double(adjustedWins) / Double(adjustedGames)) * 100 : 0
        return PlayerStats(totalGames: adjustedGames, totalWins: adjustedWins, winRate: winRate, highestRank: raw.highestRank)
    }
}
