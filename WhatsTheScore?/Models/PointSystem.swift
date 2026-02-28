import Foundation

struct PointSystem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let pointsByPlacement: [Int] // index 0 = 1st place, index 1 = 2nd place, etc.

    static func presets(forPlayerCount count: Int) -> [PointSystem] {
        switch count {
        case 2:
            return [
                PointSystem(name: "Standard (±25)", pointsByPlacement: [25, -25]),
                PointSystem(name: "High Stakes (±50)", pointsByPlacement: [50, -50]),
            ]
        case 3:
            return [
                PointSystem(name: "Standard", pointsByPlacement: [25, 0, -25]),
                PointSystem(name: "High Stakes", pointsByPlacement: [50, 0, -50]),
            ]
        case 4:
            return [
                PointSystem(name: "Standard", pointsByPlacement: [25, 10, -10, -25]),
                PointSystem(name: "High Stakes", pointsByPlacement: [50, 15, -15, -50]),
            ]
        default:
            return []
        }
    }
}
