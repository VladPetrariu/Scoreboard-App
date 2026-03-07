import SwiftUI

struct CreateMatchView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: CreateMatchViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var step = 1

    private let stepTitles = ["Game", "Players", "Points", "Order"]

    init(leaderboard: Leaderboard) {
        _viewModel = StateObject(wrappedValue: CreateMatchViewModel(leaderboard: leaderboard))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                switch step {
                case 1: gameSelectionStep
                case 2: playerSelectionStep
                case 3: pointSystemStep
                case 4: placementStep
                default: EmptyView()
                }
            }
            .background(AppColors.pageBackground.ignoresSafeArea())
            .navigationTitle("New Game")
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

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(Array(1...4), id: \.self) { s in
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(s <= step ? AnyShapeStyle(AppColors.flame) : AnyShapeStyle(Color.white.opacity(0.10)))
                            .frame(width: 28, height: 28)

                        if s < step {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(s)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(s == step ? .white : Color.gray)
                        }
                    }

                    Text(stepTitles[s - 1])
                        .font(.caption2)
                        .fontWeight(s == step ? .semibold : .regular)
                        .foregroundStyle(s <= step ? .white : Color.gray)
                }

                if s < 4 {
                    Rectangle()
                        .fill(s < step ? AnyShapeStyle(AppColors.flame) : AnyShapeStyle(Color.white.opacity(0.10)))
                        .frame(height: 2)
                        .padding(.bottom, 18)
                }
            }
        }
    }

    // MARK: - Step 1: Game Selection

    private var gameSelectionStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.flame)

                    Text("Select a Game")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Choose the game you're playing.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
                .padding(.top, 16)

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.gameList.enumerated()), id: \.element) { index, game in
                        Button {
                            viewModel.selectedGameType = game
                            withAnimation { step = 2 }
                        } label: {
                            HStack {
                                Text(game)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)

                                Spacer()

                                if viewModel.selectedGameType == game {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(AppColors.flame)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.gray)
                            }
                            .padding(16)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteGame(at: IndexSet(integer: index))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }

                        if index < viewModel.gameList.count - 1 {
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("CUSTOM GAME")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal)

                    HStack(spacing: 10) {
                        TextField("Add custom game...", text: $viewModel.customGameName)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)

                        Button {
                            viewModel.addCustomGame()
                        } label: {
                            Text("Add")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.flame)
                        }
                        .disabled(viewModel.customGameName.trimmingCharacters(in: .whitespaces).isEmpty)
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
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Step 2: Player Selection

    private var playerSelectionStep: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.flame)

                        Text("Select Players")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text("\(viewModel.selectedPlayers.count) of 2–4 players selected")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.top, 16)

                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.leaderboard.members.enumerated()), id: \.element.userId) { index, member in
                            let isSelected = viewModel.selectedPlayers.contains(where: { $0.userId == member.userId })

                            Button {
                                togglePlayer(member)
                            } label: {
                                HStack {
                                    Text(member.displayName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    if isSelected {
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

                            if index < viewModel.leaderboard.members.count - 1 {
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
                .padding(.bottom, 8)
            }

            styledNavigationButtons(
                backAction: { withAnimation { step = 1 } },
                nextAction: {
                    viewModel.initializePlacements()
                    withAnimation { step = 3 }
                },
                nextDisabled: viewModel.selectedPlayers.count < 2 || viewModel.selectedPlayers.count > 4
            )
        }
    }

    // MARK: - Step 3: Point System

    private var pointSystemStep: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.flame)

                        Text("Point System")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Choose how points are awarded.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.top, 16)

                    VStack(spacing: 0) {
                        ForEach(viewModel.availablePointSystems) { preset in
                            let isSelected = !viewModel.useCustomPoints && viewModel.selectedPointSystem == preset

                            Button {
                                viewModel.useCustomPoints = false
                                viewModel.selectedPointSystem = preset
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.name)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text(preset.pointsByPlacement.map { "\($0 >= 0 ? "+" : "")\($0)" }.joined(separator: ", "))
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.gray)
                                    }
                                    Spacer()
                                    if isSelected {
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
                                .background(isSelected ? Color.white.opacity(0.05) : Color.clear)
                            }

                            Divider()
                                .background(Color.white.opacity(0.06))
                        }

                        Button {
                            viewModel.useCustomPoints = true
                            viewModel.selectedPointSystem = nil
                            viewModel.customPoints = Array(repeating: 0, count: viewModel.selectedPlayers.count)
                            viewModel.didSavePointSystem = false
                            viewModel.customPointSystemName = ""
                        } label: {
                            HStack {
                                Text("Custom")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                if viewModel.useCustomPoints {
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
                            .background(viewModel.useCustomPoints ? Color.white.opacity(0.05) : Color.clear)
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

                    if viewModel.useCustomPoints {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CUSTOM POINTS")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.5)
                                .foregroundStyle(Color.gray)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ForEach(0..<viewModel.selectedPlayers.count, id: \.self) { index in
                                    HStack {
                                        Text(placementLabel(index + 1))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(placementColor(index + 1))
                                            .frame(width: 36)

                                        TextField("Points", value: $viewModel.customPoints[index], format: .number)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white)
                                            .keyboardType(.numbersAndPunctuation)
                                            .padding(10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.white.opacity(0.05))
                                            )
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)

                                    if index < viewModel.selectedPlayers.count - 1 {
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

                        VStack(alignment: .leading, spacing: 10) {
                            Text("SAVE TO LEADERBOARD")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.5)
                                .foregroundStyle(Color.gray)
                                .padding(.horizontal)

                            VStack(spacing: 8) {
                                HStack(spacing: 10) {
                                    TextField("Point system name...", text: $viewModel.customPointSystemName)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)

                                    Button {
                                        viewModel.saveCustomPointSystem()
                                    } label: {
                                        Text(viewModel.didSavePointSystem ? "Saved" : "Save")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.flame)
                                    }
                                    .disabled(!viewModel.canSaveCustomPointSystem)
                                }

                                if viewModel.didSavePointSystem {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppColors.positive)
                                        Text("This point system will appear as an option for future games.")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.gray)
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
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 8)
            }

            styledNavigationButtons(
                backAction: { withAnimation { step = 2 } },
                nextAction: { withAnimation { step = 4 } },
                nextDisabled: !viewModel.hasPointSystem
            )
        }
    }

    // MARK: - Step 4: Placement Order & Submit

    private var placementStep: some View {
        VStack {
            VStack(spacing: 8) {
                Image(systemName: "list.number")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.flame)

                Text("Set Placements")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Text("Drag to reorder. Top = 1st place.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
            .padding(.top, 16)
            .padding(.bottom, 4)

            List {
                Section {
                    ForEach(viewModel.placements) { member in
                        HStack {
                            if let index = viewModel.placements.firstIndex(where: { $0.userId == member.userId }) {
                                Text(placementLabel(index + 1))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(placementColor(index + 1))
                                    .frame(width: 36)
                            }
                            Text(member.displayName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .listRowBackground(Color.white.opacity(0.03))
                        .listRowSeparatorTint(Color.white.opacity(0.06))
                    }
                    .onMove { from, to in
                        viewModel.placements.move(fromOffsets: from, toOffset: to)
                    }
                } header: {
                    Text("PLACEMENTS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color.gray)
                }

                if !viewModel.pointsPreview.isEmpty {
                    Section {
                        ForEach(viewModel.pointsPreview, id: \.member.userId) { item in
                            HStack {
                                Text(item.member.displayName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(item.points >= 0 ? "+\(item.points)" : "\(item.points)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(item.points >= 0 ? AppColors.positive : AppColors.negative)
                            }
                            .listRowBackground(Color.white.opacity(0.03))
                            .listRowSeparatorTint(Color.white.opacity(0.06))
                        }
                    } header: {
                        Text("POINTS PREVIEW")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))

            HStack(spacing: 12) {
                Button {
                    withAnimation { step = 3 }
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
                    submitResult()
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Submit Result")
                    }
                }
                .buttonStyle(GradientButtonStyle())
                .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Reusable Nav Buttons

    private func styledNavigationButtons(backAction: @escaping () -> Void, nextAction: @escaping () -> Void, nextDisabled: Bool) -> some View {
        HStack(spacing: 12) {
            Button {
                backAction()
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
                nextAction()
            } label: {
                Text("Next")
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(nextDisabled)
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }

    // MARK: - Helpers

    private func togglePlayer(_ member: LeaderboardMember) {
        if let index = viewModel.selectedPlayers.firstIndex(where: { $0.userId == member.userId }) {
            viewModel.selectedPlayers.remove(at: index)
        } else if viewModel.selectedPlayers.count < 4 {
            viewModel.selectedPlayers.append(member)
        }
    }

    private func submitResult() {
        guard let userId = authViewModel.user?.id else { return }
        Task {
            if await viewModel.submitResult(createdBy: userId) != nil {
                dismiss()
            }
        }
    }

    private func placementLabel(_ position: Int) -> String {
        switch position {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(position)th"
        }
    }

    private func placementColor(_ position: Int) -> Color {
        RankTheme.positionColor(position)
    }
}
