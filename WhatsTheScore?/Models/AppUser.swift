import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    var id: String // Firebase UID
    var displayName: String
    var email: String
    var createdAt: Date
    var leaderboardIds: [String]

    static func new(id: String, displayName: String, email: String) -> AppUser {
        AppUser(
            id: id,
            displayName: displayName,
            email: email,
            createdAt: Date(),
            leaderboardIds: []
        )
    }
}
