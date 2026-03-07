import SwiftUI

struct CreateLeaderboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 0
    @State private var name = ""
    @State private var selectedGames: Set<String> = []
    @State private var customGameName = ""
    @State private var customGames: [String] = []
    @State private var startingTier: RankTier = .gold
    @State private var startingDivision: Int = 1
    @State private var createdLeaderboard: Leaderboard?
    @State private var isCreating = false

    private let presets = Leaderboard.presetGameTypes
    private let totalSteps = 3

    var body: some View {
        NavigationStack {
            if let leaderboard = createdLeaderboard {
                successView(leaderboard: leaderboard)
            } else {
                VStack(spacing: 0) {
                    // Progress bar
                    progressBar
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 4)

                    ZStack {
                        switch currentStep {
                        case 0: nameStep
                        case 1: gamesStep
                        case 2: rankStep
                        default: EmptyView()
                        }
                    }
                }
                .background(AppColors.pageBackground.ignoresSafeArea())
                .navigationTitle(stepTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.pageBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? AppColors.flame : Color.white.opacity(0.1))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.25), value: currentStep)
            }
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return "Name"
        case 1: return "Games"
        case 2: return "Starting Rank"
        default: return ""
        }
    }

    // MARK: - Step 1: Name

    private var nameStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 80)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.flame)

                Text("Name Your Leaderboard")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Text("Choose a name for your group.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)

                TextField("e.g. Game Night Squad", text: $name)
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                withAnimation { currentStep = 1 }
            } label: {
                Text("Next")
            }
            .buttonStyle(GradientButtonStyle())
            .padding(.horizontal, 32)
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.bottom, 24)
            .background(AppColors.pageBackground)
        }
    }

    // MARK: - Step 2: Games

    private var gamesStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.flame)

                    Text("Select Games")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Pick the games you'll play.\nYou can always add more later.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                // Preset games
                VStack(spacing: 0) {
                    ForEach(presets, id: \.self) { game in
                        Button {
                            toggleGame(game)
                        } label: {
                            HStack {
                                Text(game)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)

                                Spacer()

                                if selectedGames.contains(game) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(AppColors.flame)
                                } else {
                                    Image(systemName: "circle")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.gray)
                                }
                            }
                            .padding(16)
                        }

                        if game != presets.last {
                            Divider()
                                .background(Color.white.opacity(0.06))
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)

                // Custom games section
                VStack(alignment: .leading, spacing: 10) {
                    Text("CUSTOM GAMES")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal)

                    // Existing custom games
                    if !customGames.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(customGames, id: \.self) { game in
                                HStack {
                                    Text(game)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Button {
                                        customGames.removeAll { $0 == game }
                                        selectedGames.remove(game)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .padding(16)

                                if game != customGames.last {
                                    Divider()
                                        .background(Color.white.opacity(0.06))
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }

                    // Add custom game input
                    HStack(spacing: 10) {
                        TextField("Add custom game...", text: $customGameName)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)

                        Button {
                            addCustomGame()
                        } label: {
                            Text("Add")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.flame)
                        }
                        .disabled(customGameName.trimmingCharacters(in: .whitespaces).isEmpty)
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
                    .padding(.horizontal)
                }

                // Navigation buttons
                HStack(spacing: 12) {
                    Button {
                        withAnimation { currentStep = 0 }
                    } label: {
                        Text("Back")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.flame)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.flame, lineWidth: 1.5)
                            )
                    }

                    Button {
                        withAnimation { currentStep = 2 }
                    } label: {
                        Text("Next")
                    }
                    .buttonStyle(GradientButtonStyle())
                    .opacity(selectedGames.isEmpty ? 0.4 : 1.0)
                    .disabled(selectedGames.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Step 3: Starting Rank

    private var rankStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 80)

                RankBadgeView(rank: Rank(tier: startingTier, division: startingDivision), size: .large)

                Text("Starting Rank")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Text("All players who join will start at this rank.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)

                // Rank pickers
                VStack(spacing: 0) {
                    HStack {
                        Text("Rank")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Rank", selection: $startingTier) {
                            ForEach(RankTier.allCases, id: \.self) { tier in
                                Text(tier.rawValue).tag(tier)
                            }
                        }
                        .tint(RankTheme.color(for: startingTier))
                    }
                    .padding(16)

                    Divider().background(Color.white.opacity(0.06))

                    HStack {
                        Text("Division")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Division", selection: $startingDivision) {
                            ForEach(1...3, id: \.self) { div in
                                Text("\(div)").tag(div)
                            }
                        }
                        .tint(RankTheme.color(for: startingTier))
                    }
                    .padding(16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    withAnimation { currentStep = 1 }
                } label: {
                    Text("Back")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.flame)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.flame, lineWidth: 1.5)
                        )
                }

                Button {
                    createLeaderboard()
                } label: {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create")
                    }
                }
                .buttonStyle(GradientButtonStyle())
                .disabled(isCreating)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            .background(AppColors.pageBackground)
        }
    }

    // MARK: - Success

    private func successView(leaderboard: Leaderboard) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.heroGradient)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Leaderboard Created!")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text("Share this invite code with your friends:")
                .font(.system(size: 14))
                .foregroundStyle(Color.gray)

            Text(leaderboard.inviteCode)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            Button {
                UIPasteboard.general.string = leaderboard.inviteCode
            } label: {
                Label("Copy Code", systemImage: "doc.on.doc")
            }
            .buttonStyle(GradientButtonStyle(fullWidth: false))

            Spacer()

            Button("Done") { dismiss() }
                .buttonStyle(GradientButtonStyle())
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle("Success")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.pageBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Helpers

    private func toggleGame(_ game: String) {
        if selectedGames.contains(game) {
            selectedGames.remove(game)
        } else {
            selectedGames.insert(game)
        }
    }

    private func addCustomGame() {
        let trimmed = customGameName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        customGames.append(trimmed)
        selectedGames.insert(trimmed)
        customGameName = ""
    }

    private func createLeaderboard() {
        guard let user = authViewModel.user else { return }
        isCreating = true
        let allGames = Array(selectedGames)
        let startingPoints = Rank.pointsForRank(tier: startingTier, division: startingDivision)

        Task {
            if let leaderboard = await viewModel.createLeaderboard(
                name: name.trimmingCharacters(in: .whitespaces),
                creatorId: user.id,
                creatorName: user.displayName,
                gameTypes: allGames,
                startingPoints: startingPoints
            ) {
                createdLeaderboard = leaderboard
            }
            isCreating = false
        }
    }
}
