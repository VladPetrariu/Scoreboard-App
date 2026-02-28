import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var isSignedIn = false
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let authService = AuthService.shared
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    deinit {
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if let firebaseUser = firebaseUser {
                    await self.fetchOrCreateUser(firebaseUser: firebaseUser)
                    self.isSignedIn = true
                } else {
                    self.user = nil
                    self.isSignedIn = false
                }
                self.isLoading = false
            }
        }
    }

    func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            Task {
                do {
                    let firebaseUser = try await authService.signIn(with: authorization)
                    await fetchOrCreateUser(firebaseUser: firebaseUser)
                    isSignedIn = true
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        case .failure(let error):
            // User cancelled is not an error
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            user = nil
            isSignedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fetchOrCreateUser(firebaseUser: FirebaseAuth.User) async {
        let docRef = db.collection("users").document(firebaseUser.uid)

        do {
            let doc = try await docRef.getDocument()
            if doc.exists, let existingUser = try doc.data(as: AppUser?.self) {
                self.user = existingUser
            } else {
                let displayName = firebaseUser.displayName ?? "Player"
                let email = firebaseUser.email ?? ""
                let newUser = AppUser.new(id: firebaseUser.uid, displayName: displayName, email: email)
                try docRef.setData(from: newUser)
                self.user = newUser
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
