import SwiftUI
import UIKit

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var animateChart = false
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userName") private var userName: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    // Graph points for animated chart
    let points: [CGFloat] = [50, 80, 30, 90, 40, 70, 60, 100, 45, 65]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main background
                Color(colorScheme == .dark ? UIColor.black : UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Top accent area with chart animation
                VStack(spacing: 0) {
                    // Top section with animated chart
                    ZStack {
                        // Stock chart background
                        animatedChartBackground
                            .frame(height: geometry.size.height * 0.4)
                            .opacity(0.9)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.8),
                                        Color.blue.opacity(0.4),
                                        Color.blue.opacity(0.0),
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // App branding
                        VStack(spacing: 5) {
                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color(colorScheme == .dark ? UIColor.systemGray6 : .white))
                                        .frame(width: 90, height: 90)
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                                .padding(.bottom, 4)
                            
                            Text("Stock Metrics")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    
                    Spacer()
                }
                
                // Main content
                VStack {
                    Spacer()
                    
                    // Login card
                    VStack(spacing: 0) {
                        // Card handle
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        
                        // Title
                        HStack {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                            
                            // Mode switch
                            Button(action: {
                                withAnimation(.spring()) {
                                    isSignUp.toggle()
                                }
                            }) {
                                Text(isSignUp ? "Sign In" : "Sign Up")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                        
                        // Form fields
                        VStack(spacing: 20) {
                            // Email Field
                            FloatingTextField(
                                title: "Email",
                                text: $email,
                                iconName: "envelope",
                                colorScheme: colorScheme
                            )
                            
                            // Password Field
                            FloatingSecureField(
                                title: "Password",
                                text: $password,
                                iconName: "lock",
                                colorScheme: colorScheme
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Forgot password
                        if !isSignUp {
                            Button(action: {}) {
                                Text("Forgot Password?")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 24)
                            .padding(.top, 10)
                        }
                        
                        // Action button
                        Button(action: authenticateUser) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 56)
                            .padding(.horizontal, 24)
                            .padding(.top, 30)
                        }
                        .disabled(isLoading)
                        
                        // Extra padding instead of alternative auth options
                        Spacer()
                            .frame(height: 20)
                        
                        // Footer
                        Text("© 2025 Stock Metrics")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                            .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    )
                    .offset(y: isSignUp ? -40 : 0) // Move up slightly to show more form in signup mode
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Authentication"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animateChart = true
                }
            }
        }
    }
    
    // Animated chart in the background
    var animatedChartBackground: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(points.count - 1)
                let maxPoint = points.max() ?? 100
                
                var lastPoint = CGPoint(x: 0, y: height - (points[0] / maxPoint * height))
                path.move(to: lastPoint)
                
                for index in 1..<points.count {
                    let x = step * CGFloat(index)
                    let y = height - (points[index] / maxPoint * height)
                    
                    // Apply animation offset
                    let animationOffset = animateChart ? CGFloat.random(in: -5...5) : 0
                    
                    let control1 = CGPoint(
                        x: lastPoint.x + step / 2,
                        y: lastPoint.y + animationOffset
                    )
                    let control2 = CGPoint(
                        x: x - step / 2,
                        y: y + animationOffset
                    )
                    
                    path.addCurve(to: CGPoint(x: x, y: y), control1: control1, control2: control2)
                    lastPoint = CGPoint(x: x, y: y)
                }
                
                // Create area below the chart
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let step = width / CGFloat(points.count - 1)
                    let maxPoint = points.max() ?? 100
                    
                    var lastPoint = CGPoint(x: 0, y: height - (points[0] / maxPoint * height))
                    path.move(to: lastPoint)
                    
                    for index in 1..<points.count {
                        let x = step * CGFloat(index)
                        let y = height - (points[index] / maxPoint * height)
                        
                        // Apply animation offset
                        let animationOffset = animateChart ? CGFloat.random(in: -5...5) : 0
                        
                        let control1 = CGPoint(
                            x: lastPoint.x + step / 2,
                            y: lastPoint.y + animationOffset
                        )
                        let control2 = CGPoint(
                            x: x - step / 2,
                            y: y + animationOffset
                        )
                        
                        path.addCurve(to: CGPoint(x: x, y: y), control1: control1, control2: control2)
                        lastPoint = CGPoint(x: x, y: y)
                    }
                }
                .stroke(Color.blue, lineWidth: 3)
            )
        }
    }
    
    func authenticateUser() {
        isLoading = true
        
        // For demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if email == "Yuvaraj" && password == "123" {
                userEmail = "goenka.y@northeastern.edu"
                userName = "Yuvaraj Goenka"
                isUserLoggedIn = true
                isAuthenticated = true
            } else {
                alertMessage = "Invalid email or password. Please try again."
                showingAlert = true
            }
            isLoading = false
        }
    }
}

// MARK: - Custom FloatingTextField
struct FloatingTextField: View {
    let title: String
    @Binding var text: String
    let iconName: String
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            if !text.isEmpty {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 42)
            }
            
            // Field
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField(title, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.white)
                    )
            )
        }
    }
}

// MARK: - Custom FloatingSecureField
struct FloatingSecureField: View {
    let title: String
    @Binding var text: String
    let iconName: String
    var colorScheme: ColorScheme
    @State private var isSecured: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            if !text.isEmpty {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, 42)
            }
            
            // Field
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                if isSecured {
                    SecureField(title, text: $text)
                        .autocapitalization(.none)
                } else {
                    TextField(title, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.white)
                    )
            )
        }
    }
}
