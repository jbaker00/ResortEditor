import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "mountain.2.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("Resort Editor")
                .font(.largeTitle.bold())

            Text("Sign in with your Google account\nto manage resort data.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            GoogleSignInButton(action: {
                Task { await authService.signIn() }
            })
            .frame(maxWidth: 280)

            if let error = authService.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}
