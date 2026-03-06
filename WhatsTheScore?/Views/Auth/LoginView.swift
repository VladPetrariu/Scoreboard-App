import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background
            AppColors.pageBackground
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 40) {
                Spacer()

                // App icon & title
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.heroGradient)
                            .frame(width: 120, height: 120)
                            .shadow(color: AppColors.flame.opacity(0.4), radius: 16, x: 0, y: 6)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.white)
                    }

                    Text("WhatsTheScore?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Compete with friends.\nClimb the ranks.")
                        .font(.title3)
                        .foregroundStyle(AppColors.flame)
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

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
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

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
