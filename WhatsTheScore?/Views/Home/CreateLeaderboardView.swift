import SwiftUI

struct CreateLeaderboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var customGameName = ""
    @State private var customGames: [String] = []
    @State private var startingTier: RankTier = .gold
    @State private var startingDivision: Int = 1
    @State private var createdLeaderboard: Leaderboard?
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            if let leaderboard = createdLeaderboard {
                successView(leaderboard: leaderboard)
            } else {
                formView
            }
        }
    }

    private var formView: some View {
        Form {
            Section {
                TextField("e.g. Game Night Squad", text: $name)
            } header: {
                Text("Leaderboard Name")
                    .sectionHeaderStyle()
            }

            Section {
                ForEach(Leaderboard.presetGameTypes, id: \.self) { game in
                    Text(game)
                }
            } header: {
                Text("Game Types")
                    .sectionHeaderStyle()
            }

            Section {
                Picker("Rank", selection: $startingTier) {
                    ForEach(RankTier.allCases, id: \.self) { tier in
                        Text(tier.rawValue).tag(tier)
                    }
                }
                Picker("Division", selection: $startingDivision) {
                    ForEach(1...3, id: \.self) { div in
                        Text("\(div)").tag(div)
                    }
                }
                HStack {
                    Text("Starting at")
                        .foregroundStyle(.secondary)
                    Spacer()
                    RankBadgeView(rank: Rank(tier: startingTier, division: startingDivision), size: .medium)
                }
            } header: {
                Text("Starting Rank")
                    .sectionHeaderStyle()
            } footer: {
                Text("All players who join this leaderboard will start at this rank.")
            }

            Section {
                ForEach(customGames, id: \.self) { game in
                    HStack {
                        Text(game)
                        Spacer()
                        Button {
                            customGames.removeAll { $0 == game }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack {
                    TextField("Add custom game...", text: $customGameName)
                    Button("Add") {
                        addCustomGame()
                    }
                    .disabled(customGameName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Custom Games")
                    .sectionHeaderStyle()
            }
        }
        .scrollContentBackground(.hidden)
        .themedBackground()
        .navigationTitle("Create Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createLeaderboard()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
            }
        }
    }

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
                .font(.title2)
                .fontWeight(.bold)

            Text("Share this invite code with your friends:")
                .foregroundStyle(.secondary)

            Text(leaderboard.inviteCode)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .padding()
                .background(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .cornerRadius(12)

            Button {
                UIPasteboard.general.string = leaderboard.inviteCode
            } label: {
                Label("Copy Code", systemImage: "doc.on.doc")
            }
            .buttonStyle(GradientButtonStyle(fullWidth: false))

            Spacer()

            Button("Done") { dismiss() }
                .buttonStyle(GradientButtonStyle())
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Success")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addCustomGame() {
        let trimmed = customGameName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        customGames.append(trimmed)
        customGameName = ""
    }

    private func createLeaderboard() {
        guard let user = authViewModel.user else { return }
        isCreating = true
        let allGames = Leaderboard.presetGameTypes + customGames
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
