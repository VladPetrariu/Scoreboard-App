import SwiftUI

struct LeaderboardDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: LeaderboardViewModel
    @State private var selectedTab = 0
    @State private var showCreateMatch = false
    @State private var showInviteCode = false
    @State private var showDeleteConfirmation = false
    @State private var matchToDelete: Match?
    @State private var showDeleteMatchConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(leaderboard: Leaderboard) {
        _viewModel = StateObject(wrappedValue: LeaderboardViewModel(leaderboard: leaderboard))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom pill tab bar
            customTabBar
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if selectedTab == 0 {
                rankingsView
            } else {
                matchHistoryView
            }
        }
        .themedBackground()
        .navigationTitle(viewModel.leaderboard.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showInviteCode = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }

                    Button {
                        showCreateMatch = true
                    } label: {
                        Image(systemName: "gamecontroller.fill")
                    }

                    if viewModel.leaderboard.creatorId == authViewModel.user?.id {
                        Menu {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete Leaderboard", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateMatch) {
            CreateMatchView(leaderboard: viewModel.leaderboard)
        }
        .confirmationDialog("Delete Leaderboard", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteLeaderboard() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure? This will permanently delete the leaderboard and all match history for everyone.")
        }
        .confirmationDialog("Delete Game", isPresented: $showDeleteMatchConfirmation) {
            Button("Delete", role: .destructive) {
                if let match = matchToDelete {
                    Task {
                        _ = await viewModel.deleteMatch(match)
                        matchToDelete = nil
                    }
                }
            }
        } message: {
            Text("This will delete the game and update games played and wins. Points will not be changed.")
        }
        .alert("Invite Code", isPresented: $showInviteCode) {
            Button("Copy") {
                UIPasteboard.general.string = viewModel.leaderboard.inviteCode
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Share this code with friends:\n\n\(viewModel.leaderboard.inviteCode)")
        }
    }

    // MARK: - Custom Pill Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(["Rankings", "History"], id: \.self) { tab in
                let index = tab == "Rankings" ? 0 : 1
                let isActive = selectedTab == index

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    Text(tab)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isActive ? .white : Color.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isActive
                                ? AnyView(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.flame)
                                        .shadow(color: AppColors.flame.opacity(0.4), radius: 15, x: 0, y: 0)
                                )
                                : AnyView(
                                    RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Rankings

    private var rankingsView: some View {
        ScrollView {
            let sorted = viewModel.leaderboard.sortedMembers

            if sorted.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.flame.opacity(0.6))
                    Text("No Members")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Share the invite code to add friends.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                VStack(spacing: 16) {
                    // Podium for top 3
                    let topMembers = Array(sorted.prefix(3))
                    if !topMembers.isEmpty {
                        podiumView(members: topMembers)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }

                    // Remaining members
                    if sorted.count > 3 {
                        LazyVStack(spacing: 10) {
                            let remaining = Array(sorted.dropFirst(3))
                            ForEach(Array(remaining.enumerated()), id: \.element.id) { index, member in
                                MemberRowView(
                                    member: member,
                                    position: index + 4,
                                    isCurrentUser: member.userId == authViewModel.user?.id
                                )
                                .opacity(1)
                                .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: sorted.count)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Podium View

    private func podiumView(members: [LeaderboardMember]) -> some View {
        VStack(spacing: 0) {
            // Circles and info
            HStack(alignment: .bottom, spacing: 0) {
                // 2nd place (left)
                if members.count > 1 {
                    podiumInfo(member: members[1], position: 2)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }

                // 1st place (center)
                podiumInfo(member: members[0], position: 1)

                // 3rd place (right)
                if members.count > 2 {
                    podiumInfo(member: members[2], position: 3)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
            }

            // Podium bars
            HStack(alignment: .bottom, spacing: 6) {
                // 2nd place bar — glass card style
                if members.count > 1 {
                    UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .frame(height: 64)
                        .frame(maxWidth: .infinity)
                        .shadow(color: Color(red: 0.741, green: 0.765, blue: 0.780).opacity(0.15), radius: 15, x: 0, y: 0)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }

                // 1st place bar (tallest, golden gradient)
                UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.965, green: 0.828, blue: 0.396),
                                Color(red: 0.965, green: 0.828, blue: 0.396).opacity(0.4)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(height: 96)
                    .frame(maxWidth: .infinity)
                    .shadow(color: Color(red: 0.965, green: 0.828, blue: 0.396).opacity(0.2), radius: 20, x: 0, y: 0)

                // 3rd place bar — bronze gradient glass
                if members.count > 2 {
                    UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.804, green: 0.498, blue: 0.196).opacity(0.3),
                                    Color(red: 0.804, green: 0.498, blue: 0.196).opacity(0.1)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .overlay(
                            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .shadow(color: Color(red: 0.804, green: 0.498, blue: 0.196).opacity(0.15), radius: 15, x: 0, y: 0)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 12)
    }

    private func podiumInfo(member: LeaderboardMember, position: Int) -> some View {
        let isCurrentUser = member.userId == authViewModel.user?.id
        let circleSize: CGFloat = position == 1 ? 80 : 64

        return VStack(spacing: 5) {
            if position != 1 {
                Spacer().frame(height: 30)
            }

            // Circle with star/number
            ZStack {
                if position == 1 {
                    // Star on top of circle
                    VStack(spacing: -8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.965, green: 0.828, blue: 0.396))
                            .shadow(color: Color(red: 0.965, green: 0.828, blue: 0.396).opacity(0.5), radius: 6)
                            .zIndex(1)

                        Circle()
                            .fill(Color(red: 0.965, green: 0.828, blue: 0.396))
                            .frame(width: circleSize, height: circleSize)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.965, green: 0.828, blue: 0.396).opacity(0.5), lineWidth: 4)
                            )
                            .shadow(color: Color(red: 0.965, green: 0.828, blue: 0.396).opacity(0.5), radius: 20, x: 0, y: 0)
                            .overlay(
                                Text("1")
                                    .font(.system(size: 28, weight: .black))
                                    .foregroundStyle(Color(red: 0.059, green: 0.090, blue: 0.165))
                            )
                    }
                } else if position == 2 {
                    // 2nd place: gray bordered circle
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: circleSize, height: circleSize)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .overlay(
                            Text("2")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                        )
                } else {
                    // 3rd place: bronze bordered circle
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: circleSize, height: circleSize)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.804, green: 0.498, blue: 0.196).opacity(0.4), lineWidth: 2)
                        )
                        .overlay(
                            Text("3")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color(red: 0.804, green: 0.498, blue: 0.196))
                        )
                }
            }

            // Name
            Text(isCurrentUser ? "\(member.displayName) (You)" : member.displayName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 96)

            // Points — all use brand blue
            Text(formatPoints(member.points))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.flame)

            // Rank badge (podium style — rounded pill)
            podiumRankBadge(rank: member.rank)

            if position == 1 {
                Spacer().frame(height: 8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func podiumRankBadge(rank: Rank) -> some View {
        let color = RankTheme.color(for: rank.tier)
        return HStack(spacing: 3) {
            Image(systemName: rank.tier.systemIcon)
                .font(.system(size: 6))
            Text(rank.displayName.uppercased())
                .font(.system(size: 7, weight: .bold))
                .tracking(0.5)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(Capsule())
    }

    private func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: points)) ?? "\(points)") + " pts"
    }

    // MARK: - Match History

    private var matchHistoryView: some View {
        ScrollView {
            if viewModel.allMatches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.flame.opacity(0.6))
                    Text("No Games Yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Play a game to see results here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.allMatches) { match in
                        MatchRowView(match: match)
                            .contextMenu {
                                Button(role: .destructive) {
                                    matchToDelete = match
                                    showDeleteMatchConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }

                    if viewModel.hasMoreMatches {
                        ProgressView()
                            .tint(AppColors.flame)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreMatches()
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Match Row

struct MatchRowView: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: game type badge + date
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 6))
                    Text(match.gameType.uppercased())
                        .font(.system(size: 7, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(AppColors.flame)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppColors.flame.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(AppColors.flame.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 2))

                Spacer()

                Text(match.createdAt, style: .date)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.gray)
            }

            // Player results
            ForEach(match.sortedPlayers) { player in
                HStack(spacing: 10) {
                    Text("\(player.placement)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(placementColor(player.placement))
                        .frame(width: 20, alignment: .center)

                    Text(player.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()

                    Text(player.pointsEarned >= 0 ? "+\(player.pointsEarned)" : "\(player.pointsEarned)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(player.pointsEarned >= 0 ? AppColors.positive : AppColors.negative)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 8, bottomTrailingRadius: 0, topTrailingRadius: 0)
                .fill(AppColors.flame)
                .frame(width: 4)
        }
    }

    private func placementColor(_ placement: Int) -> Color {
        switch placement {
        case 1: return Color(red: 0.965, green: 0.828, blue: 0.396)
        case 2: return Color.gray
        case 3: return Color(red: 0.804, green: 0.498, blue: 0.196)
        default: return Color.gray
        }
    }
}
