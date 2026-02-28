import SwiftUI
import FirebaseCore

@main
struct WhatsTheScore_App: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    ProgressView("Loading...")
                } else if authViewModel.isSignedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
        }
    }
}
