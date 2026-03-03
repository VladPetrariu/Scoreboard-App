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

struct Leaderboard: Identifiable, Equatable {
    var id: String // Firestore document ID
    var name: String
    var creatorId: String
    var inviteCode: String
    var createdAt: Date
    var gameTypes: [String]
    var startingPoints: Int // starting rank for new members
    var members: [LeaderboardMember]
    var memberIds: [String]

    var sortedMembers: [LeaderboardMember] {
        members.sorted { $0.points > $1.points }
    }

    static let presetGameTypes = [
        "Pool", "Darts", "Chess", "FIFA", "Monopoly"
    ]
}

extension Leaderboard: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, creatorId, inviteCode, createdAt, gameTypes, startingPoints, members, memberIds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        creatorId = try container.decode(String.self, forKey: .creatorId)
        inviteCode = try container.decode(String.self, forKey: .inviteCode)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        gameTypes = try container.decode([String].self, forKey: .gameTypes)
        startingPoints = try container.decode(Int.self, forKey: .startingPoints)
        members = try container.decode([LeaderboardMember].self, forKey: .members)
        // Backwards compat: default to empty if missing, then derive from members
        let decoded = try container.decodeIfPresent([String].self, forKey: .memberIds) ?? []
        memberIds = decoded.isEmpty ? members.map { $0.userId } : decoded
    }
}
