import SwiftUI

struct JoinLeaderboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var inviteCode = ""
    @State private var isJoining = false
    @State private var joined = false
    @FocusState private var isCodeFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icon with action gradient
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.actionGradient)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 12, x: 0, y: 4)

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
                    .focused($isCodeFocused)
                    .padding()
                    .background(
                        ZStack {
                            Color(.secondarySystemBackground)
                            AppColors.navy.opacity(0.03)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCodeFocused ? AppColors.accent : (inviteCode.isEmpty ? AppColors.subtleBorder : AppColors.subtleBorder),
                                lineWidth: isCodeFocused ? 2 : 1
                            )
                    )
                    .cornerRadius(12)
                    .frame(maxWidth: 250)
                    .onChange(of: inviteCode) { newValue in
                        inviteCode = String(newValue.prefix(6)).uppercased()
                    }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(AppColors.accent)
                        .multilineTextAlignment(.center)
                }

                Button {
                    joinLeaderboard()
                } label: {
                    if isJoining {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Join")
                    }
                }
                .buttonStyle(GradientButtonStyle())
                .frame(maxWidth: 250)
                .disabled(inviteCode.count != 6 || isJoining)

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [AppColors.navy.opacity(0.08), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
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
