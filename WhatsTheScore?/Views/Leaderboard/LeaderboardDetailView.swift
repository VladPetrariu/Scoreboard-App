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
        HStack(spacing: 4) {
            ForEach(["Rankings", "History"], id: \.self) { tab in
                let index = tab == "Rankings" ? 0 : 1
                let isActive = selectedTab == index

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    Text(tab)
                        .font(.subheadline)
                        .fontWeight(isActive ? .bold : .medium)
                        .foregroundStyle(isActive ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            isActive
                                ? AnyView(
                                    Capsule().fill(AppColors.flame)
                                )
                                : AnyView(
                                    Capsule().fill(Color.clear)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
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
        HStack(alignment: .bottom, spacing: 8) {
            // 2nd place (left)
            if members.count > 1 {
                podiumColumn(
                    member: members[1],
                    position: 2,
                    barHeight: 70,
                    avatarSize: 52,
                    topPadding: 24
                )
            } else {
                Spacer().frame(maxWidth: .infinity)
            }

            // 1st place (center)
            podiumColumn(
                member: members[0],
                position: 1,
                barHeight: 90,
                avatarSize: 64,
                topPadding: 0
            )

            // 3rd place (right)
            if members.count > 2 {
                podiumColumn(
                    member: members[2],
                    position: 3,
                    barHeight: 55,
                    avatarSize: 48,
                    topPadding: 36
                )
            } else {
                Spacer().frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 12)
    }

    private func podiumColumn(member: LeaderboardMember, position: Int, barHeight: CGFloat, avatarSize: CGFloat, topPadding: CGFloat) -> some View {
        let isCurrentUser = member.userId == authViewModel.user?.id

        return VStack(spacing: 6) {
            Spacer().frame(height: topPadding)

            // Avatar circle with glow
            ZStack {
                Circle()
                    .fill(RankTheme.positionGradient(position))
                    .frame(width: avatarSize, height: avatarSize)
                    .shadow(color: RankTheme.positionGlowColor(position).opacity(0.6), radius: 10, x: 0, y: 0)

                // Position indicator or crown
                if position == 1 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: avatarSize * 0.35, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(position)")
                        .font(.system(size: avatarSize * 0.35, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            // Name
            Text(isCurrentUser ? "\(member.displayName) (You)" : member.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)

            // Points
            Text("\(member.points) pts")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.flame)

            // Rank badge
            RankBadgeView(rank: member.rank, size: .small)

            // Podium bar
            RoundedRectangle(cornerRadius: 10)
                .fill(RankTheme.positionGradient(position))
                .frame(height: barHeight)
                .shadow(color: RankTheme.positionGlowColor(position).opacity(0.3), radius: 6, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Match History

    private var matchHistoryView: some View {
        Group {
            if viewModel.matches.isEmpty {
                ScrollView {
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
                }
            } else {
                List {
                    ForEach(viewModel.matches) { match in
                        MatchRowView(match: match)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    matchToDelete = match
                                    showDeleteMatchConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

// MARK: - Match Row

struct MatchRowView: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.gameType)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.actionGradient)
                    .cornerRadius(8)

                Spacer()

                Text(match.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(match.sortedPlayers) { player in
                HStack {
                    Text(placementText(player.placement))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.flame)
                    Text(player.displayName)
                        .font(.subheadline)
                    Spacer()
                    Text(player.pointsEarned >= 0 ? "+\(player.pointsEarned)" : "\(player.pointsEarned)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(player.pointsEarned >= 0 ? AppColors.positive : AppColors.negative)
                }
            }
        }
    }

    private func placementText(_ placement: Int) -> String {
        switch placement {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(placement)th"
        }
    }
}
