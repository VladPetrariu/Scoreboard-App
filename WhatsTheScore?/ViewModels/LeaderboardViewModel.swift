import Foundation
import Combine
import FirebaseFirestore

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: Leaderboard
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var leaderboardListener: ListenerRegistration?
    private var matchesListener: ListenerRegistration?
    private let leaderboardService = LeaderboardService.shared
    private let matchService = MatchService.shared

    init(leaderboard: Leaderboard) {
        self.leaderboard = leaderboard
        startListening()
    }

    deinit {
        leaderboardListener?.remove()
        matchesListener?.remove()
    }

    func startListening() {
        leaderboardListener = leaderboardService.listenToLeaderboard(id: leaderboard.id) { [weak self] updated in
            Task { @MainActor [weak self] in
                if let updated = updated {
                    self?.leaderboard = updated
                }
            }
        }

        matchesListener = matchService.listenToMatches(leaderboardId: leaderboard.id) { [weak self] matches in
            Task { @MainActor [weak self] in
                self?.matches = matches
            }
        }
    }

    func addGameType(_ gameType: String) async {
        do {
            try await leaderboardService.addGameType(leaderboardId: leaderboard.id, gameType: gameType)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLeaderboard() async -> Bool {
        do {
            leaderboardListener?.remove()
            matchesListener?.remove()
            let memberIds = leaderboard.members.map { $0.userId }
            try await leaderboardService.deleteLeaderboard(leaderboardId: leaderboard.id, memberIds: memberIds)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteMatch(_ match: Match) async -> Bool {
        do {
            // Adjust stats for each player: decrement gamesPlayed, decrement wins if they won
            for player in match.players {
                try await leaderboardService.adjustMemberStats(
                    leaderboardId: leaderboard.id,
                    userId: player.userId,
                    gamesDelta: -1,
                    winsDelta: player.placement == 1 ? -1 : 0
                )
            }
            // Delete the match document
            try await matchService.deleteMatch(leaderboardId: leaderboard.id, matchId: match.id)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func leaveLeaderboard(userId: String) async -> Bool {
        do {
            try await leaderboardService.leaveLeaderboard(leaderboardId: leaderboard.id, userId: userId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
