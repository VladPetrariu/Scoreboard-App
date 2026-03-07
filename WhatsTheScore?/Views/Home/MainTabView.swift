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
        .onChange(of: selectedTab) { newTab in
            if newTab == 2, let userId = authViewModel.user?.id {
                Task {
                    await homeViewModel.fetchLeaderboards(userId: userId)
                }
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
                tab: 2,
                label: "Profile"
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            AppColors.tabBarSurface
                .shadow(color: AppColors.flame.opacity(0.06), radius: 12, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabBarButton(icon: String, activeIcon: String, tab: Int, label: String? = nil) -> some View {
        let isActive = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? activeIcon : icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isActive ? AppColors.flame : .secondary.opacity(0.4))

                if let label {
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isActive ? AppColors.flame : .secondary.opacity(0.4))
                } else {
                    // Pill indicator
                    Capsule()
                        .fill(isActive ? AppColors.flame : Color.clear)
                        .frame(width: 20, height: 4)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Create / Join Page

    private var createJoinPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

                // Gradient-filled trophy circle
                ZStack {
                    Circle()
                        .fill(AppColors.heroGradient)
                        .frame(width: 80, height: 80)
                        .shadow(color: AppColors.flame.opacity(0.4), radius: 12, x: 0, y: 4)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }

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
                    HStack(spacing: 0) {
                        // Accent strip
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.cardAccentGradient)
                            .frame(width: 4)
                            .padding(.vertical, 10)

                        HStack(spacing: 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppColors.flame)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create Leaderboard")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Start a new competition with friends")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.glassBorder))
                    .shadow(color: AppColors.flame.opacity(0.10), radius: 12, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                // Join card
                Button {
                    showJoinSheet = true
                } label: {
                    HStack(spacing: 0) {
                        // Accent strip
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.cardAccentGradient)
                            .frame(width: 4)
                            .padding(.vertical, 10)

                        HStack(spacing: 16) {
                            Image(systemName: "person.badge.plus")
                                .font(.title2)
                                .foregroundStyle(AppColors.amber)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Join Leaderboard")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Enter an invite code to join")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.glassBorder))
                    .shadow(color: AppColors.flame.opacity(0.10), radius: 12, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .themedBackground()
    }
}
