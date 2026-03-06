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
                // Step indicator
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
            .themedBackground()
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
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
                // Circle
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(s <= step ? AnyShapeStyle(AppColors.flame) : AnyShapeStyle(Color(.systemGray5)))
                            .frame(width: 28, height: 28)

                        if s < step {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(s)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(s == step ? .white : .secondary)
                        }
                    }

                    Text(stepTitles[s - 1])
                        .font(.caption2)
                        .fontWeight(s == step ? .semibold : .regular)
                        .foregroundStyle(s <= step ? .primary : .secondary)
                }

                // Connecting line
                if s < 4 {
                    Rectangle()
                        .fill(s < step ? AnyShapeStyle(AppColors.flame) : AnyShapeStyle(Color(.systemGray5)))
                        .frame(height: 2)
                        .padding(.bottom, 18) // align with circle center
                }
            }
        }
    }

    // MARK: - Step 1: Game Selection

    private var gameSelectionStep: some View {
        VStack {
            List {
                ForEach(viewModel.gameList, id: \.self) { game in
                    Button {
                        viewModel.selectedGameType = game
                        withAnimation { step = 2 }
                    } label: {
                        HStack {
                            Text(game)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.selectedGameType == game {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.primary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteGame(at: offsets)
                }

                Section {
                    HStack {
                        TextField("Add custom game...", text: $viewModel.customGameName)
                        Button("Add") {
                            viewModel.addCustomGame()
                        }
                        .disabled(viewModel.customGameName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Custom Game")
                        .sectionHeaderStyle()
                }
            }
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Step 2: Player Selection

    private var playerSelectionStep: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.leaderboard.members) { member in
                        Button {
                            togglePlayer(member)
                        } label: {
                            let isSelected = viewModel.selectedPlayers.contains(where: { $0.userId == member.userId })
                            HStack {
                                Text(member.displayName)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.primary)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                        .font(.title3)
                                }
                            }
                            .padding(16)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? Color(.label) : Color(.separator), lineWidth: isSelected ? 1.5 : 1)
                            )
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }

                    Text("\(viewModel.selectedPlayers.count) of 2-4 players selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            navigationButtons(
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
            List {
                Section {
                    ForEach(viewModel.availablePointSystems) { preset in
                        let isSelected = !viewModel.useCustomPoints && viewModel.selectedPointSystem == preset
                        Button {
                            viewModel.useCustomPoints = false
                            viewModel.selectedPointSystem = preset
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(preset.name)
                                        .foregroundStyle(.primary)
                                    Text(preset.pointsByPlacement.map { "\($0 >= 0 ? "+" : "")\($0)" }.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.primary)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                        .font(.title3)
                                }
                            }
                        }
                        .listRowBackground(isSelected ? Color(.systemGray5) : nil)
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
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.useCustomPoints {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.primary)
                                    .font(.title3)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                            }
                        }
                    }
                    .listRowBackground(viewModel.useCustomPoints ? Color(.systemGray5) : nil)
                } header: {
                    Text("Point System")
                        .sectionHeaderStyle()
                }

                if viewModel.useCustomPoints {
                    Section {
                        ForEach(0..<viewModel.selectedPlayers.count, id: \.self) { index in
                            HStack {
                                Text(placementLabel(index + 1))
                                    .frame(width: 36)
                                TextField("Points", value: $viewModel.customPoints[index], format: .number)
                                    .keyboardType(.numbersAndPunctuation)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    } header: {
                        Text("Custom Points")
                            .sectionHeaderStyle()
                    }

                    Section {
                        HStack {
                            TextField("Point system name...", text: $viewModel.customPointSystemName)
                            Button {
                                viewModel.saveCustomPointSystem()
                            } label: {
                                Text(viewModel.didSavePointSystem ? "Saved" : "Save")
                            }
                            .disabled(!viewModel.canSaveCustomPointSystem)
                        }
                        if viewModel.didSavePointSystem {
                            Label("This point system will appear as an option for future games.", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                    } header: {
                        Text("Save to Leaderboard")
                            .sectionHeaderStyle()
                    }
                }
            }
            .scrollContentBackground(.hidden)

            navigationButtons(
                backAction: { withAnimation { step = 2 } },
                nextAction: { withAnimation { step = 4 } },
                nextDisabled: !viewModel.hasPointSystem
            )
        }
    }

    // MARK: - Step 4: Placement Order & Submit

    private var placementStep: some View {
        VStack {
            List {
                Section {
                    ForEach(viewModel.placements) { member in
                        HStack {
                            if let index = viewModel.placements.firstIndex(where: { $0.userId == member.userId }) {
                                Text(placementLabel(index + 1))
                                    .font(.headline)
                                    .foregroundStyle(placementColor(index + 1))
                                    .frame(width: 36)
                            }
                            Text(member.displayName)
                                .font(.body)
                            Spacer()
                        }
                    }
                    .onMove { from, to in
                        viewModel.placements.move(fromOffsets: from, toOffset: to)
                    }
                } header: {
                    Text("Drag to Set Placements (top = 1st)")
                        .sectionHeaderStyle()
                }

                // Preview
                if !viewModel.pointsPreview.isEmpty {
                    Section {
                        ForEach(viewModel.pointsPreview, id: \.member.userId) { item in
                            HStack {
                                Text(item.member.displayName)
                                Spacer()
                                Text(item.points >= 0 ? "+\(item.points)" : "\(item.points)")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(item.points >= 0 ? AppColors.positive : AppColors.negative)
                            }
                        }
                    } header: {
                        Text("Points Preview")
                            .sectionHeaderStyle()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))

            HStack {
                Button {
                    withAnimation { step = 3 }
                } label: {
                    Text("Back")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1.5)
                        )
                }

                Spacer()

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
                .buttonStyle(GradientButtonStyle(fullWidth: false))
                .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
            }
            .padding()
        }
    }

    // MARK: - Reusable Nav Buttons

    private func navigationButtons(backAction: @escaping () -> Void, nextAction: @escaping () -> Void, nextDisabled: Bool) -> some View {
        HStack {
            Button {
                backAction()
            } label: {
                Text("Back")
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1.5)
                    )
            }

            Spacer()

            Button {
                nextAction()
            } label: {
                Text("Next")
            }
            .buttonStyle(GradientButtonStyle(fullWidth: false))
            .disabled(nextDisabled)
        }
        .padding()
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
