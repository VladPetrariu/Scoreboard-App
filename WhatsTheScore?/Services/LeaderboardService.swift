import Foundation
import FirebaseFirestore

class LeaderboardService {
    static let shared = LeaderboardService()
    private let db = Firestore.firestore()

    // MARK: - Create

    func createLeaderboard(name: String, creatorId: String, creatorName: String, gameTypes: [String], startingPoints: Int) async throws -> Leaderboard {
        let inviteCode = InviteCodeGenerator.generate()
        let docRef = db.collection("leaderboards").document()

        let member = LeaderboardMember(
            userId: creatorId,
            displayName: creatorName,
            points: startingPoints,
            gamesPlayed: 0,
            wins: 0,
            joinedAt: Date()
        )

        let leaderboard = Leaderboard(
            id: docRef.documentID,
            name: name,
            creatorId: creatorId,
            inviteCode: inviteCode,
            createdAt: Date(),
            gameTypes: gameTypes,
            startingPoints: startingPoints,
            members: [member],
            memberIds: [creatorId],
            savedPointSystems: []
        )

        try docRef.setData(from: leaderboard)

        // Add leaderboard ID to user's list
        try await db.collection("users").document(creatorId).updateData([
            "leaderboardIds": FieldValue.arrayUnion([docRef.documentID])
        ])

        return leaderboard
    }

    // MARK: - Join

    func joinLeaderboard(inviteCode: String, userId: String, userName: String) async throws -> Leaderboard {
        let snapshot = try await db.collection("leaderboards")
            .whereField("inviteCode", isEqualTo: inviteCode.uppercased())
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot.documents.first else {
            throw LeaderboardError.invalidInviteCode
        }

        var leaderboard = try doc.data(as: Leaderboard.self)

        if leaderboard.members.contains(where: { $0.userId == userId }) {
            throw LeaderboardError.alreadyMember
        }

        let newMember = LeaderboardMember(
            userId: userId,
            displayName: userName,
            points: leaderboard.startingPoints,
            gamesPlayed: 0,
            wins: 0,
            joinedAt: Date()
        )

        leaderboard.members.append(newMember)
        leaderboard.memberIds.append(userId)

        try doc.reference.setData(from: leaderboard)

        // Add leaderboard ID to user's list
        try await db.collection("users").document(userId).updateData([
            "leaderboardIds": FieldValue.arrayUnion([leaderboard.id])
        ])

        return leaderboard
    }

    // MARK: - Fetch

    func fetchLeaderboard(id: String) async throws -> Leaderboard {
        let doc = try await db.collection("leaderboards").document(id).getDocument()
        guard let leaderboard = try doc.data(as: Leaderboard?.self) else {
            throw LeaderboardError.notFound
        }
        return leaderboard
    }

    func fetchUserLeaderboards(userId: String) async throws -> [Leaderboard] {
        let userDoc = try await db.collection("users").document(userId).getDocument()
        guard let user = try userDoc.data(as: AppUser?.self) else {
            return []
        }

        guard !user.leaderboardIds.isEmpty else { return [] }

        // Firestore 'in' queries support max 30 items
        var leaderboards: [Leaderboard] = []
        for chunk in user.leaderboardIds.chunked(into: 30) {
            let snapshot = try await db.collection("leaderboards")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()

            let results = snapshot.documents.compactMap { try? $0.data(as: Leaderboard.self) }
            leaderboards.append(contentsOf: results)
        }

        return leaderboards.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Update Points

    func updateMemberPoints(leaderboardId: String, userId: String, pointsDelta: Int, isWin: Bool) async throws {
        let docRef = db.collection("leaderboards").document(leaderboardId)
        let doc = try await docRef.getDocument()
        guard var leaderboard = try doc.data(as: Leaderboard?.self) else {
            throw LeaderboardError.notFound
        }

        guard let memberIndex = leaderboard.members.firstIndex(where: { $0.userId == userId }) else {
            throw LeaderboardError.memberNotFound
        }

        leaderboard.members[memberIndex].points += pointsDelta
        leaderboard.members[memberIndex].gamesPlayed += 1
        if isWin {
            leaderboard.members[memberIndex].wins += 1
        }

        try docRef.setData(from: leaderboard)
    }

    // MARK: - Add Game Type

    func addGameType(leaderboardId: String, gameType: String) async throws {
        let docRef = db.collection("leaderboards").document(leaderboardId)
        try await docRef.updateData([
            "gameTypes": FieldValue.arrayUnion([gameType])
        ])
    }

    // MARK: - Remove Game Type

    func removeGameType(leaderboardId: String, gameType: String) async throws {
        let docRef = db.collection("leaderboards").document(leaderboardId)
        try await docRef.updateData([
            "gameTypes": FieldValue.arrayRemove([gameType])
        ])
    }

    // MARK: - Save Custom Point System

    func savePointSystem(leaderboardId: String, pointSystem: SavedPointSystem) async throws {
        let docRef = db.collection("leaderboards").document(leaderboardId)
        let data = try Firestore.Encoder().encode(pointSystem)
        try await docRef.updateData([
            "savedPointSystems": FieldValue.arrayUnion([data])
        ])
    }

    // MARK: - Reset Member Stats

    func resetMemberStats(userId: String, leaderboardIds: [String]) async throws {
        for leaderboardId in leaderboardIds {
            let docRef = db.collection("leaderboards").document(leaderboardId)
            let doc = try await docRef.getDocument()
            guard var leaderboard = try doc.data(as: Leaderboard?.self) else { continue }

            guard let memberIndex = leaderboard.members.firstIndex(where: { $0.userId == userId }) else { continue }

            leaderboard.members[memberIndex].gamesPlayed = 0
            leaderboard.members[memberIndex].wins = 0
            leaderboard.members[memberIndex].points = leaderboard.startingPoints

            try docRef.setData(from: leaderboard)
        }
    }

    // MARK: - Adjust Member Stats

    func adjustMemberStats(leaderboardId: String, userId: String, gamesDelta: Int, winsDelta: Int) async throws {
        let docRef = db.collection("leaderboards").document(leaderboardId)
        let doc = try await docRef.getDocument()
        guard var leaderboard = try doc.data(as: Leaderboard?.self) else {
            throw LeaderboardError.notFound
        }

        guard let memberIndex = leaderboard.members.firstIndex(where: { $0.userId == userId }) else {
            throw LeaderboardError.memberNotFound
        }

        leaderboard.members[memberIndex].gamesPlayed = max(0, leaderboard.members[memberIndex].gamesPlayed + gamesDelta)
        leaderboard.members[memberIndex].wins = max(0, leaderboard.members[memberIndex].wins + winsDelta)

        try docRef.setData(from: leaderboard)
    }

    // MARK: - Listener

    func listenToLeaderboard(id: String, onChange: @escaping (Leaderboard?) -> Void) -> ListenerRegistration {
        return db.collection("leaderboards").document(id).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            let leaderboard = try? snapshot.data(as: Leaderboard.self)
            onChange(leaderboard)
        }
    }

    // MARK: - Delete

    func deleteLeaderboard(leaderboardId: String, memberIds: [String]) async throws {
        // Remove leaderboard ID from all members' user docs
        for memberId in memberIds {
            try await db.collection("users").document(memberId).updateData([
                "leaderboardIds": FieldValue.arrayRemove([leaderboardId])
            ])
        }

        // Delete all matches in the sub-collection
        let matchesSnapshot = try await db.collection("leaderboards").document(leaderboardId)
            .collection("matches").getDocuments()
        for doc in matchesSnapshot.documents {
            try await doc.reference.delete()
        }

        // Delete the leaderboard document
        try await db.collection("leaderboards").document(leaderboardId).delete()
    }

    // MARK: - Leave

    func leaveLeaderboard(leaderboardId: String, userId: String) async throws {
        let docRef = db.collection("leaderboards").document(leaderboardId)
        let doc = try await docRef.getDocument()
        guard var leaderboard = try doc.data(as: Leaderboard?.self) else {
            throw LeaderboardError.notFound
        }

        leaderboard.members.removeAll { $0.userId == userId }
        leaderboard.memberIds.removeAll { $0 == userId }
        try docRef.setData(from: leaderboard)

        try await db.collection("users").document(userId).updateData([
            "leaderboardIds": FieldValue.arrayRemove([leaderboardId])
        ])
    }
}

enum LeaderboardError: LocalizedError {
    case invalidInviteCode
    case alreadyMember
    case notFound
    case memberNotFound

    var errorDescription: String? {
        switch self {
        case .invalidInviteCode: return "Invalid invite code. Please check and try again."
        case .alreadyMember: return "You're already a member of this leaderboard."
        case .notFound: return "Leaderboard not found."
        case .memberNotFound: return "Member not found in this leaderboard."
        }
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
