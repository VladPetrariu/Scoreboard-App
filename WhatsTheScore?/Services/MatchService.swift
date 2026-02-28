import Foundation
import FirebaseFirestore

class MatchService {
    static let shared = MatchService()
    private let db = Firestore.firestore()
    private let leaderboardService = LeaderboardService.shared

    // MARK: - Record Match

    func recordMatch(
        leaderboardId: String,
        gameType: String,
        pointSystemName: String,
        createdBy: String,
        players: [PlayerResult]
    ) async throws -> Match {
        let matchRef = db.collection("leaderboards").document(leaderboardId)
            .collection("matches").document()

        let match = Match(
            id: matchRef.documentID,
            gameType: gameType,
            playerCount: players.count,
            pointSystemName: pointSystemName,
            createdBy: createdBy,
            createdAt: Date(),
            status: .completed,
            players: players
        )

        try matchRef.setData(from: match)

        // Update each player's points in the leaderboard
        for player in players {
            try await leaderboardService.updateMemberPoints(
                leaderboardId: leaderboardId,
                userId: player.userId,
                pointsDelta: player.pointsEarned,
                isWin: player.placement == 1
            )
        }

        return match
    }

    // MARK: - Fetch History

    func fetchMatchHistory(leaderboardId: String, limit: Int = 50) async throws -> [Match] {
        let snapshot = try await db.collection("leaderboards").document(leaderboardId)
            .collection("matches")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Match.self) }
    }

    // MARK: - Listener

    func listenToMatches(leaderboardId: String, limit: Int = 50, onChange: @escaping ([Match]) -> Void) -> ListenerRegistration {
        return db.collection("leaderboards").document(leaderboardId)
            .collection("matches")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                let matches = snapshot.documents.compactMap { try? $0.data(as: Match.self) }
                onChange(matches)
            }
    }
}
