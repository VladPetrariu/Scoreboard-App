import Foundation
import Combine

@MainActor
class CreateMatchViewModel: ObservableObject {
    @Published var selectedGameType: String = ""
    @Published var selectedPlayers: [LeaderboardMember] = []
    @Published var selectedPointSystem: PointSystem?
    @Published var customPoints: [Int] = []
    @Published var useCustomPoints = false
    @Published var placements: [LeaderboardMember] = [] // ordered by placement (1st, 2nd, etc.)
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    let leaderboard: Leaderboard
    private let matchService = MatchService.shared

    init(leaderboard: Leaderboard) {
        self.leaderboard = leaderboard
    }

    var availablePointSystems: [PointSystem] {
        PointSystem.presets(forPlayerCount: selectedPlayers.count)
    }

    var pointsPreview: [(member: LeaderboardMember, points: Int)] {
        let points: [Int]
        if useCustomPoints {
            points = customPoints
        } else {
            points = selectedPointSystem?.pointsByPlacement ?? []
        }

        guard points.count == placements.count else { return [] }

        return placements.enumerated().map { index, member in
            (member: member, points: points[index])
        }
    }

    var canSubmit: Bool {
        !selectedGameType.isEmpty
        && selectedPlayers.count >= 2
        && selectedPlayers.count <= 4
        && placements.count == selectedPlayers.count
        && (selectedPointSystem != nil || useCustomPoints)
        && (!useCustomPoints || customPoints.count == selectedPlayers.count)
    }

    func initializePlacements() {
        placements = selectedPlayers
        if useCustomPoints {
            customPoints = Array(repeating: 0, count: selectedPlayers.count)
        }
    }

    func submitResult(createdBy: String) async -> Match? {
        guard canSubmit else { return nil }

        isSubmitting = true
        errorMessage = nil

        let points: [Int]
        if useCustomPoints {
            points = customPoints
        } else {
            points = selectedPointSystem?.pointsByPlacement ?? []
        }

        let playerResults = placements.enumerated().map { index, member in
            PlayerResult(
                userId: member.userId,
                displayName: member.displayName,
                placement: index + 1,
                pointsEarned: points[index]
            )
        }

        let pointSystemName = useCustomPoints ? "Custom" : (selectedPointSystem?.name ?? "Custom")

        do {
            let match = try await matchService.recordMatch(
                leaderboardId: leaderboard.id,
                gameType: selectedGameType,
                pointSystemName: pointSystemName,
                createdBy: createdBy,
                players: playerResults
            )
            isSubmitting = false
            return match
        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
            return nil
        }
    }
}
