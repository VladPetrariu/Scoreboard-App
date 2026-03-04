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
            // Custom tab bar
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

    // MARK: - Custom Tab Bar

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
                    VStack(spacing: 6) {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(isActive ? .bold : .medium)
                            .foregroundStyle(isActive ? .primary : .secondary)

                        // Underline indicator
                        if isActive {
                            Color(.label)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        } else {
                            Color.clear
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
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
                        .foregroundStyle(.secondary)
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
                LazyVStack(spacing: 10) {
                    // Top 3 highlight cards
                    let topMembers = Array(sorted.prefix(3))
                    ForEach(Array(topMembers.enumerated()), id: \.element.id) { index, member in
                        TopMemberCard(
                            member: member,
                            position: index + 1,
                            isCurrentUser: member.userId == authViewModel.user?.id
                        )
                    }

                    // Remaining members
                    if sorted.count > 3 {
                        let remaining = Array(sorted.dropFirst(3))
                        ForEach(Array(remaining.enumerated()), id: \.element.id) { index, member in
                            MemberRowView(
                                member: member,
                                position: index + 4,
                                isCurrentUser: member.userId == authViewModel.user?.id
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Match History

    private var matchHistoryView: some View {
        Group {
            if viewModel.matches.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
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

// MARK: - Top Member Card

private struct TopMemberCard: View {
    let member: LeaderboardMember
    let position: Int
    var isCurrentUser: Bool = false

    private var progressInfo: RankProgressInfo {
        RankProgressInfo.calculate(for: member.points)
    }

    private var positionEmoji: String {
        switch position {
        case 1: return "\u{1F947}"
        case 2: return "\u{1F948}"
        case 3: return "\u{1F949}"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Position emoji
                Text(positionEmoji)
                    .font(.system(size: 28))

                // Name + stats
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(member.displayName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        if isCurrentUser {
                            Text("(You)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                        }
                    }
                    Text("\(member.gamesPlayed) games \u{00B7} \(member.wins) wins")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    RankBadgeView(rank: member.rank, size: .small)
                    Text("\(member.points) pts")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .padding(14)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(RankTheme.gradient(for: member.rank.tier))
                        .frame(width: geo.size.width * progressInfo.progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isCurrentUser ? Color(.label) : Color(.separator),
                    lineWidth: isCurrentUser ? 1.5 : 1
                )
        )
        .cornerRadius(16)
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
                    .background(Color(.darkGray))
                    .cornerRadius(8)

                Spacer()

                Text(match.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(match.sortedPlayers) { player in
                HStack {
                    Text(placementEmoji(player.placement))
                    Text(player.displayName)
                        .font(.subheadline)
                    Spacer()
                    Text(player.pointsEarned >= 0 ? "+\(player.pointsEarned)" : "\(player.pointsEarned)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(player.pointsEarned >= 0 ? AppColors.positive : AppColors.negative)
                }
            }
        }
    }

    private func placementEmoji(_ placement: Int) -> String {
        switch placement {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(placement)th"
        }
    }
}
