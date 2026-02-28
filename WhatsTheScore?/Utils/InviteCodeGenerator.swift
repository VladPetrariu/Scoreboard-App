import Foundation

struct InviteCodeGenerator {
    static func generate(length: Int = 6) -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // No I/O/0/1 to avoid confusion
        return String((0..<length).map { _ in characters.randomElement()! })
    }
}
