import SwiftUI
import UIKit
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
                    LoadingView()
                } else if authViewModel.isSignedIn {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
            .tint(AppColors.flame)
            .preferredColorScheme(.dark)
            .onAppear {
                // Pre-warm the keyboard so the first TextField tap is instant
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let tf = UITextField(frame: .zero)
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let window = windowScene.windows.first else { return }
                    window.addSubview(tf)
                    tf.becomeFirstResponder()
                    tf.resignFirstResponder()
                    tf.removeFromSuperview()
                }
            }
        }
    }
}
