import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background gradient — full dark navy
            AppColors.heroGradient
                .ignoresSafeArea()

            // Scattered rank icons
            ScatteredRankIcons()
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 40) {
                Spacer()

                // App icon & title
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppColors.trophyGradient)
                        .shadow(color: AppColors.highlight.opacity(0.5), radius: 16, x: 0, y: 0)
                        .shadow(color: AppColors.accent.opacity(0.4), radius: 24, x: 0, y: 6)

                    Text("WhatsTheScore?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Compete with friends.\nClimb the ranks.")
                        .font(.title3)
                        .foregroundStyle(AppColors.highlight.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Sign in with Apple
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        let (_, appleRequest) = AuthService.shared.startSignInWithApple()
                        request.requestedScopes = appleRequest.requestedScopes
                        request.nonce = appleRequest.nonce
                    } onCompletion: { result in
                        authViewModel.handleSignInResult(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 55)
                    .frame(maxWidth: 300)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(AppColors.accent)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                Spacer()
                    .frame(height: 40)
            }
            .padding()
        }
    }
}

// MARK: - Scattered Rank Icons Background

private struct ScatteredRankIcons: View {
    private struct IconPlacement: Identifiable {
        let id = UUID()
        let icon: String
        let tier: RankTier
        let x: CGFloat  // 0-1 relative
        let y: CGFloat  // 0-1 relative
        let size: CGFloat
        let rotation: Double
        let opacity: Double
    }

    private let placements: [IconPlacement] = [
        IconPlacement(icon: "shield", tier: .iron, x: 0.12, y: 0.08, size: 28, rotation: -15, opacity: 0.25),
        IconPlacement(icon: "shield.lefthalf.filled", tier: .bronze, x: 0.85, y: 0.12, size: 24, rotation: 20, opacity: 0.30),
        IconPlacement(icon: "shield.fill", tier: .silver, x: 0.08, y: 0.28, size: 32, rotation: -25, opacity: 0.20),
        IconPlacement(icon: "star", tier: .gold, x: 0.90, y: 0.32, size: 26, rotation: 15, opacity: 0.30),
        IconPlacement(icon: "star.fill", tier: .platinum, x: 0.18, y: 0.48, size: 22, rotation: -10, opacity: 0.25),
        IconPlacement(icon: "diamond", tier: .diamond, x: 0.82, y: 0.52, size: 30, rotation: 30, opacity: 0.25),
        IconPlacement(icon: "diamond.fill", tier: .ascendant, x: 0.10, y: 0.70, size: 26, rotation: -20, opacity: 0.20),
        IconPlacement(icon: "crown.fill", tier: .immortal, x: 0.88, y: 0.72, size: 28, rotation: 12, opacity: 0.30),
        IconPlacement(icon: "star.fill", tier: .gold, x: 0.70, y: 0.88, size: 20, rotation: -8, opacity: 0.25),
        IconPlacement(icon: "shield.fill", tier: .silver, x: 0.30, y: 0.90, size: 24, rotation: 22, opacity: 0.20),
        IconPlacement(icon: "diamond", tier: .diamond, x: 0.50, y: 0.06, size: 22, rotation: -12, opacity: 0.22),
        IconPlacement(icon: "crown.fill", tier: .immortal, x: 0.45, y: 0.92, size: 20, rotation: 18, opacity: 0.25),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(placements) { item in
                Image(systemName: item.icon)
                    .font(.system(size: item.size))
                    .foregroundStyle(RankTheme.color(for: item.tier).opacity(item.opacity))
                    .rotationEffect(.degrees(item.rotation))
                    .position(
                        x: geo.size.width * item.x,
                        y: geo.size.height * item.y
                    )
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
