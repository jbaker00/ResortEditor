import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

@MainActor
class AuthService: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: User?
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    init() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isSignedIn = true
        }
    }

    func signIn() async {
        errorMessage = nil
        guard let presentingVC = presentingViewController() else {
            errorMessage = "Could not find presenting view controller."
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token."
                return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            let authResult = try await Auth.auth().signIn(with: credential)
            let email = authResult.user.email ?? ""
            let allowed = try await checkAdminAllowlist(email: email)
            if allowed {
                currentUser = authResult.user
                isSignedIn = true
            } else {
                try await Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                errorMessage = "Access denied. \(email) is not an authorized admin."
            }
        } catch {
            print("❌ Sign-in error: \(error)")
            print("❌ Description: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ Domain: \(nsError.domain), Code: \(nsError.code)")
                print("❌ UserInfo: \(nsError.userInfo)")
            }
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            currentUser = nil
            isSignedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func checkAdminAllowlist(email: String) async throws -> Bool {
        let doc = try await db.collection("admins").document(email).getDocument()
        return doc.exists
    }

    private func presentingViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }
}
