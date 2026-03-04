import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedTab = 1
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        createJoinPage
                            .navigationTitle("Get Started")
                    }
                case 2:
                    NavigationStack {
                        ProfileView(leaderboards: homeViewModel.leaderboards)
                    }
                default:
                    NavigationStack {
                        HomeView(
                            viewModel: homeViewModel,
                            showCreateSheet: $showCreateSheet,
                            showJoinSheet: $showJoinSheet
                        )
                        .navigationTitle("My Leaderboards")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar
            customTabBar
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateLeaderboardView(viewModel: homeViewModel)
        }
        .sheet(isPresented: $showJoinSheet) {
            JoinLeaderboardView(viewModel: homeViewModel)
        }
        .task {
            if let userId = authViewModel.user?.id {
                await homeViewModel.fetchLeaderboards(userId: userId)
            }
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarButton(
                icon: "plus.square",
                activeIcon: "plus.square.fill",
                tab: 0
            )
            tabBarButton(
                icon: "trophy",
                activeIcon: "trophy.fill",
                tab: 1
            )
            tabBarButton(
                icon: "person",
                activeIcon: "person.fill",
                tab: 2
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabBarButton(icon: String, activeIcon: String, tab: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: selectedTab == tab ? activeIcon : icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(selectedTab == tab ? Color(.label) : .secondary.opacity(0.5))
                .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Create / Join Page

    private var createJoinPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.primary)

                Text("Create or Join")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Start a new leaderboard or join\nan existing one with an invite code.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 8)

                // Create card
                Button {
                    showCreateSheet = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create Leaderboard")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Start a new competition with friends")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)

                // Join card
                Button {
                    showJoinSheet = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundStyle(.primary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Join Leaderboard")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Enter an invite code to join")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .themedBackground()
    }
}
