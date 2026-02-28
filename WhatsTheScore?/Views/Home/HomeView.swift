import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading leaderboards...")
                } else if viewModel.leaderboards.isEmpty {
                    emptyState
                } else {
                    leaderboardList
                }
            }
            .navigationTitle("My Leaderboards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showCreateSheet = true
                        } label: {
                            Label("Create Leaderboard", systemImage: "plus.circle")
                        }
                        Button {
                            showJoinSheet = true
                        } label: {
                            Label("Join Leaderboard", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateLeaderboardView(viewModel: viewModel)
            }
            .sheet(isPresented: $showJoinSheet) {
                JoinLeaderboardView(viewModel: viewModel)
            }
            .task {
                if let userId = authViewModel.user?.id {
                    await viewModel.fetchLeaderboards(userId: userId)
                }
            }
            .refreshable {
                if let userId = authViewModel.user?.id {
                    await viewModel.fetchLeaderboards(userId: userId)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Leaderboards Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create a leaderboard to start competing\nwith your friends, or join one with an invite code.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button {
                    showCreateSheet = true
                } label: {
                    Label("Create", systemImage: "plus.circle.fill")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showJoinSheet = true
                } label: {
                    Label("Join", systemImage: "person.badge.plus")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    private var leaderboardList: some View {
        List(viewModel.leaderboards) { leaderboard in
            NavigationLink(destination: LeaderboardDetailView(leaderboard: leaderboard)) {
                leaderboardRow(leaderboard)
            }
        }
    }

    private func leaderboardRow(_ leaderboard: Leaderboard) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(leaderboard.name)
                    .font(.headline)
                Text("\(leaderboard.members.count) members")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let userId = authViewModel.user?.id,
               let member = leaderboard.members.first(where: { $0.userId == userId }) {
                RankBadgeView(rank: member.rank, size: .small)
            }
        }
        .padding(.vertical, 4)
    }
}
