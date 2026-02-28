import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var leaderboards: [Leaderboard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let leaderboardService = LeaderboardService.shared

    func fetchLeaderboards(userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            leaderboards = try await leaderboardService.fetchUserLeaderboards(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createLeaderboard(name: String, creatorId: String, creatorName: String, gameTypes: [String], startingPoints: Int) async -> Leaderboard? {
        errorMessage = nil
        do {
            let leaderboard = try await leaderboardService.createLeaderboard(
                name: name,
                creatorId: creatorId,
                creatorName: creatorName,
                gameTypes: gameTypes,
                startingPoints: startingPoints
            )
            leaderboards.insert(leaderboard, at: 0)
            return leaderboard
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func joinLeaderboard(inviteCode: String, userId: String, userName: String) async -> Leaderboard? {
        errorMessage = nil
        do {
            let leaderboard = try await leaderboardService.joinLeaderboard(
                inviteCode: inviteCode,
                userId: userId,
                userName: userName
            )
            leaderboards.insert(leaderboard, at: 0)
            return leaderboard
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
