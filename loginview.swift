import SwiftUI
import AuthenticationServices
import UIKit

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userName") private var userName: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Blue Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App Logo
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    
                    Text("Stock Analyzer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer().frame(height: 40)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .disableAutocorrection(true)
                            .keyboardType(UIKeyboardType.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            authenticateUser()
                        }) {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            isSignUp.toggle()
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        
                        // Divider with "or" text
                        HStack {
                            VStack { Divider().background(Color.white.opacity(0.5)) }
                            Text("OR").foregroundColor(.white.opacity(0.8)).padding(.horizontal, 8)
                            VStack { Divider().background(Color.white.opacity(0.5)) }
                        }.padding(.vertical)
                        
                        // Apple Sign-In Button
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: configureAppleSignIn,
                            onCompletion: handleAppleSignInResult
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(8)
                        .padding(.bottom)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Authentication"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    func authenticateUser() {
        // For demo purposes, you can use these credentials:
        if email == "U" && password == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                userEmail = "goenka.y@northeastern.edu"
                userName = "Yuvaraj Goenka"
                isUserLoggedIn = true
                isAuthenticated = true
            }
        } else {
            alertMessage = "Invalid email or password. Please try again."
            showingAlert = true
        }
    }
    
    func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Extract user details
                let userId = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                
                // Process user information
                if let email = email {
                    userEmail = email
                } else {
                    // Apple might not provide email on subsequent logins
                    userEmail = "\(userId)@apple.signin"
                }
                
                if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                    userName = "\(givenName) \(familyName)"
                } else {
                    // Extract a name from email or use a default
                    let emailPrefix = userEmail.components(separatedBy: "@").first ?? "User"
                    userName = emailPrefix
                }
                
                // Set authentication state
                isUserLoggedIn = true
                isAuthenticated = true
            }
            
        case .failure(let error):
            alertMessage = "Sign in failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
