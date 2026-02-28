import Foundation

struct PlayerResult: Codable, Identifiable, Equatable {
    var id: String { odlUserId }
    var userId: String
    var displayName: String
    var placement: Int // 1 = first, 2 = second, etc.
    var pointsEarned: Int

    // Workaround: unique id in case same user appears (shouldn't happen, but safe)
    private var odlUserId: String { userId }
}

struct Match: Identifiable, Codable, Equatable {
    var id: String // Firestore document ID
    var gameType: String
    var playerCount: Int
    var pointSystemName: String
    var createdBy: String
    var createdAt: Date
    var status: MatchStatus
    var players: [PlayerResult]

    var sortedPlayers: [PlayerResult] {
        players.sorted { $0.placement < $1.placement }
    }

    var winner: PlayerResult? {
        players.first { $0.placement == 1 }
    }
}

enum MatchStatus: String, Codable {
    case pending
    case completed
}
