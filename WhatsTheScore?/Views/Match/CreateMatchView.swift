import SwiftUI

struct CreateMatchView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: CreateMatchViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var step = 1

    init(leaderboard: Leaderboard) {
        _viewModel = StateObject(wrappedValue: CreateMatchViewModel(leaderboard: leaderboard))
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Step indicator
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { s in
                        Capsule()
                            .fill(s <= step ? Color.blue : Color(.systemGray4))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                switch step {
                case 1: gameSelectionStep
                case 2: playerSelectionStep
                case 3: resultStep
                default: EmptyView()
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Step 1: Game Selection

    private var gameSelectionStep: some View {
        List {
            Section("Select a Game") {
                ForEach(viewModel.leaderboard.gameTypes, id: \.self) { game in
                    Button {
                        viewModel.selectedGameType = game
                        withAnimation { step = 2 }
                    } label: {
                        HStack {
                            Text(game)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.selectedGameType == game {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if viewModel.leaderboard.gameTypes.isEmpty {
                Section {
                    Text("No game types configured for this leaderboard.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Step 2: Player Selection

    private var playerSelectionStep: some View {
        VStack {
            List {
                Section("Select 2-4 Players") {
                    ForEach(viewModel.leaderboard.members) { member in
                        Button {
                            togglePlayer(member)
                        } label: {
                            HStack {
                                Text(member.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if viewModel.selectedPlayers.contains(where: { $0.userId == member.userId }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section {
                    Text("\(viewModel.selectedPlayers.count) of 2-4 players selected")
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button("Back") {
                    withAnimation { step = 1 }
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Next") {
                    viewModel.initializePlacements()
                    withAnimation { step = 3 }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.selectedPlayers.count < 2 || viewModel.selectedPlayers.count > 4)
            }
            .padding()
        }
    }

    // MARK: - Step 3: Record Result

    private var resultStep: some View {
        VStack {
            List {
                Section("Drag to Set Placements (top = 1st)") {
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
                }

                Section("Point System") {
                    ForEach(viewModel.availablePointSystems) { preset in
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
                                if !viewModel.useCustomPoints && viewModel.selectedPointSystem == preset {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }

                    Button {
                        viewModel.useCustomPoints = true
                        viewModel.selectedPointSystem = nil
                        viewModel.customPoints = Array(repeating: 0, count: viewModel.selectedPlayers.count)
                    } label: {
                        HStack {
                            Text("Custom")
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.useCustomPoints {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }

                    if viewModel.useCustomPoints {
                        ForEach(0..<viewModel.selectedPlayers.count, id: \.self) { index in
                            HStack {
                                Text(placementLabel(index + 1))
                                    .frame(width: 36)
                                TextField("Points", value: $viewModel.customPoints[index], format: .number)
                                    .keyboardType(.numbersAndPunctuation)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                }

                // Preview
                if !viewModel.pointsPreview.isEmpty {
                    Section("Points Preview") {
                        ForEach(viewModel.pointsPreview, id: \.member.userId) { item in
                            HStack {
                                Text(item.member.displayName)
                                Spacer()
                                Text(item.points >= 0 ? "+\(item.points)" : "\(item.points)")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(item.points >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))

            HStack {
                Button("Back") {
                    withAnimation { step = 2 }
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    submitResult()
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Result")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
            }
            .padding()
        }
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
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }
}
