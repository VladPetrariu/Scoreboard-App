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

        // Batch-update all players' points in a single read-modify-write
        let updates = players.map { player in
            (userId: player.userId, pointsDelta: player.pointsEarned, isWin: player.placement == 1)
        }
        try await leaderboardService.updateMembersPoints(leaderboardId: leaderboardId, playerUpdates: updates)

        return match
    }

    // MARK: - Delete Match

    func deleteMatch(leaderboardId: String, matchId: String) async throws {
        try await db.collection("leaderboards").document(leaderboardId)
            .collection("matches").document(matchId).delete()
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

    func fetchMoreMatches(leaderboardId: String, after lastDocument: DocumentSnapshot, limit: Int = 10) async throws -> ([Match], DocumentSnapshot?) {
        let snapshot = try await db.collection("leaderboards").document(leaderboardId)
            .collection("matches")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: limit)
            .getDocuments()

        let matches = snapshot.documents.compactMap { try? $0.data(as: Match.self) }
        return (matches, snapshot.documents.last)
    }

    // MARK: - Listener

    func listenToMatches(leaderboardId: String, limit: Int = 15, onChange: @escaping ([Match], DocumentSnapshot?) -> Void) -> ListenerRegistration {
        return db.collection("leaderboards").document(leaderboardId)
            .collection("matches")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                let matches = snapshot.documents.compactMap { try? $0.data(as: Match.self) }
                onChange(matches, snapshot.documents.last)
            }
    }
}
