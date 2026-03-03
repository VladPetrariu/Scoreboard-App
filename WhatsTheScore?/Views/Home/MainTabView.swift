import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedPage = 1
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false

    var body: some View {
        TabView(selection: $selectedPage) {
            // Page 0: Create / Join
            NavigationStack {
                createJoinPage
                    .navigationTitle("Get Started")
            }
            .tag(0)

            // Page 1: Leaderboards (default)
            NavigationStack {
                HomeView(
                    viewModel: homeViewModel,
                    showCreateSheet: $showCreateSheet,
                    showJoinSheet: $showJoinSheet
                )
                .navigationTitle("My Leaderboards")
            }
            .tag(1)

            // Page 2: Profile
            NavigationStack {
                ProfileView(leaderboards: homeViewModel.leaderboards)
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            pageIndicator
                .padding(.bottom, 8)
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

    // MARK: - Create / Join Page

    private var createJoinPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(AppColors.trophyGradient)
                    .shadow(color: AppColors.highlight.opacity(0.4), radius: 12, x: 0, y: 0)

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
                        ZStack {
                            Circle()
                                .fill(AppColors.actionGradient)
                                .frame(width: 48, height: 48)
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }

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
                    .cardStyle(showAccentLine: true)
                }
                .buttonStyle(.plain)

                // Join card
                Button {
                    showJoinSheet = true
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.warmGradient)
                                .frame(width: 48, height: 48)
                            Image(systemName: "person.badge.plus")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }

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
                    .cardStyle(showAccentLine: true)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .themedBackground()
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index == selectedPage ? AppColors.accent : AppColors.navy.opacity(0.2))
                    .frame(width: index == selectedPage ? 8 : 6, height: index == selectedPage ? 8 : 6)
                    .animation(.easeInOut(duration: 0.2), value: selectedPage)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}
