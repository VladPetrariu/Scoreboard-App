import SwiftUI

struct LeaderboardDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: LeaderboardViewModel
    @State private var selectedTab = 0
    @State private var showCreateMatch = false
    @State private var showInviteCode = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(leaderboard: Leaderboard) {
        _viewModel = StateObject(wrappedValue: LeaderboardViewModel(leaderboard: leaderboard))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("View", selection: $selectedTab) {
                Text("Rankings").tag(0)
                Text("History").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                rankingsView
            } else {
                matchHistoryView
            }
        }
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
        .alert("Invite Code", isPresented: $showInviteCode) {
            Button("Copy") {
                UIPasteboard.general.string = viewModel.leaderboard.inviteCode
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Share this code with friends:\n\n\(viewModel.leaderboard.inviteCode)")
        }
    }

    private var rankingsView: some View {
        List {
            ForEach(Array(viewModel.leaderboard.sortedMembers.enumerated()), id: \.element.id) { index, member in
                MemberRowView(
                    member: member,
                    position: index + 1,
                    isCurrentUser: member.userId == authViewModel.user?.id
                )
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.leaderboard.members.isEmpty {
                ContentUnavailableView(
                    "No Members",
                    systemImage: "person.3",
                    description: Text("Share the invite code to add friends.")
                )
            }
        }
    }

    private var matchHistoryView: some View {
        List {
            ForEach(viewModel.matches) { match in
                MatchRowView(match: match)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.matches.isEmpty {
                ContentUnavailableView(
                    "No Games Yet",
                    systemImage: "gamecontroller",
                    description: Text("Play a game to see results here.")
                )
            }
        }
    }
}

struct MatchRowView: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.gameType)
                    .font(.headline)
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
                        .foregroundStyle(player.pointsEarned >= 0 ? .green : .red)
                }
            }
        }
        .padding(.vertical, 4)
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
