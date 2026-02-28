import SwiftUI

struct JoinLeaderboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var inviteCode = ""
    @State private var isJoining = false
    @State private var joined = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Join a Leaderboard")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Enter the 6-character invite code\nshared by the leaderboard creator.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Invite Code", text: $inviteCode)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .frame(maxWidth: 250)
                    .onChange(of: inviteCode) { _, newValue in
                        inviteCode = String(newValue.prefix(6)).uppercased()
                    }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    joinLeaderboard()
                } label: {
                    if isJoining {
                        ProgressView()
                    } else {
                        Text("Join")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 250)
                .disabled(inviteCode.count != 6 || isJoining)

                Spacer()
            }
            .padding()
            .navigationTitle("Join Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func joinLeaderboard() {
        guard let user = authViewModel.user else { return }
        isJoining = true

        Task {
            if await viewModel.joinLeaderboard(
                inviteCode: inviteCode,
                userId: user.id,
                userName: user.displayName
            ) != nil {
                dismiss()
            }
            isJoining = false
        }
    }
}
