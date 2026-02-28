import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    private var currentNonce: String?

    func startSignInWithApple() -> (nonce: String, request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        return (nonce, request)
    }

    func signIn(with authorization: ASAuthorization) async throws -> FirebaseAuth.User {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }

        guard let nonce = currentNonce else {
            throw AuthError.missingNonce
        }

        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.missingToken
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        let result = try await Auth.auth().signIn(with: credential)
        return result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    // MARK: - Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum AuthError: LocalizedError {
    case invalidCredential
    case missingNonce
    case missingToken

    var errorDescription: String? {
        switch self {
        case .invalidCredential: return "Invalid Apple credential."
        case .missingNonce: return "Missing authentication nonce."
        case .missingToken: return "Missing identity token."
        }
    }
}
