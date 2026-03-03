import SwiftUI
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
    @Published var gameList: [String] = []
    @Published var customGameName: String = ""
    @Published var customPointSystemName: String = ""
    @Published var didSavePointSystem = false

    let leaderboard: Leaderboard
    private let matchService = MatchService.shared
    private let leaderboardService = LeaderboardService.shared

    init(leaderboard: Leaderboard) {
        self.leaderboard = leaderboard
        self.gameList = Self.buildGameList(from: leaderboard)
    }

    private static func buildGameList(from leaderboard: Leaderboard) -> [String] {
        let presets = Leaderboard.presetGameTypes
        // Preset games that exist in the leaderboard, in preset order
        var list = presets.filter { leaderboard.gameTypes.contains($0) }
        // Custom games (anything in leaderboard.gameTypes not in presets)
        let custom = leaderboard.gameTypes.filter { !presets.contains($0) }
        list.append(contentsOf: custom)
        // If leaderboard has no game types yet, show all presets
        if list.isEmpty {
            list = presets
        }
        return list
    }

    func addCustomGame() {
        let trimmed = customGameName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !gameList.contains(trimmed) else { return }
        gameList.append(trimmed)
        customGameName = ""
        Task {
            try? await leaderboardService.addGameType(leaderboardId: leaderboard.id, gameType: trimmed)
        }
    }

    func deleteGame(at offsets: IndexSet) {
        let gamesToRemove = offsets.map { gameList[$0] }
        gameList.remove(atOffsets: offsets)
        if gamesToRemove.contains(selectedGameType) {
            selectedGameType = ""
        }
        for game in gamesToRemove {
            Task {
                try? await leaderboardService.removeGameType(leaderboardId: leaderboard.id, gameType: game)
            }
        }
    }

    var availablePointSystems: [PointSystem] {
        let presets = PointSystem.presets(forPlayerCount: selectedPlayers.count)
        let saved = leaderboard.savedPointSystems
            .filter { $0.playerCount == selectedPlayers.count }
            .map { PointSystem(name: $0.name, pointsByPlacement: $0.pointsByPlacement) }
        return presets + saved
    }

    var canSaveCustomPointSystem: Bool {
        useCustomPoints
        && customPoints.count == selectedPlayers.count
        && !customPointSystemName.trimmingCharacters(in: .whitespaces).isEmpty
        && !didSavePointSystem
    }

    func saveCustomPointSystem() {
        let name = customPointSystemName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let saved = SavedPointSystem(
            name: name,
            playerCount: selectedPlayers.count,
            pointsByPlacement: customPoints
        )
        didSavePointSystem = true
        Task {
            try? await leaderboardService.savePointSystem(leaderboardId: leaderboard.id, pointSystem: saved)
        }
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

    var hasPointSystem: Bool {
        selectedPointSystem != nil || (useCustomPoints && customPoints.count == selectedPlayers.count)
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
