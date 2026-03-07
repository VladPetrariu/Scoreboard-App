import Foundation
import Combine
import FirebaseFirestore

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: Leaderboard
    @Published var matches: [Match] = []
    @Published var olderMatches: [Match] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMoreMatches = true
    @Published var errorMessage: String?

    private var leaderboardListener: ListenerRegistration?
    private var matchesListener: ListenerRegistration?
    private var paginationCursor: DocumentSnapshot?
    private let leaderboardService = LeaderboardService.shared
    private let matchService = MatchService.shared
    private let initialPageSize = 15

    var allMatches: [Match] {
        var seen = Set<String>()
        var result: [Match] = []
        for match in matches + olderMatches {
            if seen.insert(match.id).inserted {
                result.append(match)
            }
        }
        return result
    }

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

        matchesListener = matchService.listenToMatches(leaderboardId: leaderboard.id, limit: initialPageSize) { [weak self] matches, lastDoc in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.matches = matches
                // Only set the cursor if the user hasn't started paginating yet
                if self.olderMatches.isEmpty {
                    self.paginationCursor = lastDoc
                }
                if matches.count < self.initialPageSize {
                    self.hasMoreMatches = false
                }
            }
        }
    }

    func loadMoreMatches() async {
        guard let cursor = paginationCursor, hasMoreMatches, !isLoadingMore else { return }
        isLoadingMore = true
        do {
            let (newMatches, lastDoc) = try await matchService.fetchMoreMatches(
                leaderboardId: leaderboard.id,
                after: cursor,
                limit: 10
            )
            olderMatches.append(contentsOf: newMatches)
            paginationCursor = lastDoc
            if newMatches.count < 10 {
                hasMoreMatches = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingMore = false
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
            // Batch-adjust stats for all players in a single read-modify-write
            let adjustments = match.players.map { player in
                (userId: player.userId, gamesDelta: -1, winsDelta: player.placement == 1 ? -1 : 0)
            }
            try await leaderboardService.adjustMembersStats(leaderboardId: leaderboard.id, adjustments: adjustments)
            // Delete the match document
            try await matchService.deleteMatch(leaderboardId: leaderboard.id, matchId: match.id)
            // Remove from olderMatches if present
            olderMatches.removeAll { $0.id == match.id }
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
