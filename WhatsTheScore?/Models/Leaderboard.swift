import Foundation

struct LeaderboardMember: Codable, Identifiable, Equatable {
    var id: String { userId }
    var userId: String
    var displayName: String
    var points: Int
    var gamesPlayed: Int
    var wins: Int
    var joinedAt: Date

    var rank: Rank {
        Rank.fromPoints(points)
    }
}

struct Leaderboard: Identifiable, Codable, Equatable {
    var id: String // Firestore document ID
    var name: String
    var creatorId: String
    var inviteCode: String
    var createdAt: Date
    var gameTypes: [String]
    var startingPoints: Int // starting rank for new members
    var members: [LeaderboardMember]

    var sortedMembers: [LeaderboardMember] {
        members.sorted { $0.points > $1.points }
    }

    static let presetGameTypes = [
        "Pool", "Darts", "Chess", "FIFA", "Monopoly"
    ]
}
