import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct WhatsTheScore_App: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()

        // Explicit offline persistence with 100MB cache
        let settings = Firestore.firestore().settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        Firestore.firestore().settings = settings
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    ProgressView("Loading...")
                } else if authViewModel.isSignedIn {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
            .tint(Color(.label))
        }
    }
}
