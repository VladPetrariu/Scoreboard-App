import SwiftUI

struct MemberRowView: View {
    let member: LeaderboardMember
    let position: Int
    var isCurrentUser: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Position number
            Text("#\(position)")
                .font(.headline)
                .foregroundStyle(positionColor)
                .frame(width: 36)

            // Rank badge
            RankBadgeView(rank: member.rank, size: .small)

            // Name and stats
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(member.displayName)
                        .font(.body)
                        .fontWeight(isCurrentUser ? .bold : .regular)
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("\(member.gamesPlayed) games · \(member.wins) wins")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Points
            Text("\(member.points) pts")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
        .listRowBackground(isCurrentUser ? Color.blue.opacity(0.05) : nil)
    }

    private var positionColor: Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }
}
