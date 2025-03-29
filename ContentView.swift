import SwiftUI
import AuthenticationServices
import UIKit

// MARK: - Content View
struct ContentView: View {
    @State private var isAuthenticated = false
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userName") private var userName: String = ""
    
    var body: some View {
        if isAuthenticated || isUserLoggedIn {
            MainTabView(isAuthenticated: $isAuthenticated)
        } else {
            LoginView(isAuthenticated: $isAuthenticated)
        }
    }
}

// MARK: - Login View
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
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                    
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
                            // Using explicit enum type to avoid compiler errors
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
        // Your existing authentication logic
        if email == "U" && password == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                userEmail = "user@example.com"
                userName = "User"
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
                
                print("User ID: \(userId)")
                
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
                
                print("Signed in with Apple: \(userName), \(userEmail)")
                
                // Set authentication state
                isUserLoggedIn = true
                isAuthenticated = true
            }
            
        case .failure(let error):
            print("Apple Sign-In failed: \(error.localizedDescription)")
            alertMessage = "Sign in failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ChatView()
                .tabItem {
                    Label("AI Chat", systemImage: "message.fill")
                }
            
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "chart.bar.fill")
                }
            
            ProfileView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Gemini API Service
class GeminiService {
    // Your Gemini API Key
    private let apiKey = "AIzaSyDOwruybZjGcWLqkhCP7QJ1RZh09AuCKz4" // Replace with your actual key
    // Updated endpoint URL with gemini-flash model
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func generateResponse(prompt: String) async throws -> String {
        let urlString = "\(baseURL)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            throw URLError(.badURL)
        }
        
        // Create the request body
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "You are a stock market prediction AI assistant. \(prompt)"]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
        
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            print("Request body created successfully")
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
            return "Error preparing request: \(error.localizedDescription)"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("Sending request to Gemini API...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("API Response Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    // Try to parse error message
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = errorJson["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("API Error: \(message)")
                        return "API Error: \(message)"
                    }
                    return "Error: Received status code \(httpResponse.statusCode)"
                }
            }
            
            // Try to parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Received JSON response: \(json)")
                    
                    if let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let text = firstPart["text"] as? String {
                        return text
                    } else {
                        print("Could not extract text from response structure")
                        if let errorInfo = json["error"] as? [String: Any],
                           let message = errorInfo["message"] as? String {
                            return "API Error: \(message)"
                        }
                    }
                } else {
                    print("Response was not valid JSON")
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
            }
            
            // If we got here, conversion failed
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            return "I couldn't process the response correctly. Please check your API key and try again."
            
        } catch {
            print("Network error: \(error.localizedDescription)")
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Market Overview Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Market Snapshot")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                MarketIndexCard(name: "S&P 500", value: "5,245.62", change: "+0.52%", isPositive: true)
                                MarketIndexCard(name: "NASDAQ", value: "16,384.47", change: "+0.65%", isPositive: true)
                                MarketIndexCard(name: "DOW", value: "39,127.14", change: "-0.18%", isPositive: false)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                    
                    // Featured Stocks
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Featured Stocks")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                StockCard(symbol: "AAPL", name: "Apple Inc.", price: "$185.92", change: "+1.27%", isPositive: true)
                                StockCard(symbol: "MSFT", name: "Microsoft", price: "$420.45", change: "-0.29%", isPositive: false)
                                StockCard(symbol: "GOOGL", name: "Alphabet", price: "$166.95", change: "+0.52%", isPositive: true)
                                StockCard(symbol: "AMZN", name: "Amazon", price: "$183.50", change: "+1.91%", isPositive: true)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                    
                    // Recent Predictions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Predictions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<3) { _ in
                                PredictionCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Market Overview")
        }
    }
}

// MARK: - Market Index Card
struct MarketIndexCard: View {
    let name: String
    let value: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(change)
                .font(.caption)
                .foregroundColor(isPositive ? .green : .red)
        }
        .padding()
        .frame(width: 120)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Stock Card
struct StockCard: View {
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(price)
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(isPositive ? .green : .red)
                
                Text(change)
                    .foregroundColor(isPositive ? .green : .red)
            }
            .font(.footnote)
        }
        .padding()
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Prediction Card
struct PredictionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("AAPL")
                    .font(.headline)
                
                Text("•")
                
                Text("Apple Inc.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("85% Confidence")
                    .font(.caption)
                    .padding(6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(4)
            }
            
            Text("Bullish trend expected over next 30 days")
                .font(.subheadline)
            
            Text("March 28, 2025")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Chat View
struct ChatView: View {
    @State private var message = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your AI stock assistant powered by Google's Gemini. How can I help you analyze or predict stock movements today?", isUser: false)
    ]
    @State private var isLoading = false
    private let geminiService = GeminiService()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                        
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                HStack {
                    TextField("Ask about stocks...", text: $message)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .padding(10)
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()
            }
            .navigationTitle("AI Stock Assistant")
        }
    }
    
    func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(text: message, isUser: true)
        messages.append(userMessage)
        
        let userQuery = message
        message = ""
        isLoading = true
        
        // Use Gemini API to get a response
        Task {
            do {
                let responseText = try await geminiService.generateResponse(prompt: userQuery)
                DispatchQueue.main.async {
                    messages.append(ChatMessage(text: responseText, isUser: false))
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(text: "Sorry, I encountered an error. Please try again later.", isUser: false))
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Chat Bubble View
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !message.isUser { Spacer() }
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - Portfolio View
struct PortfolioView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Add button manually in a header
                HStack {
                    Spacer()
                    Button(action: {
                        // Add new stock action
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.horizontal)
                }
                
                List {
                    Section(header: Text("Portfolio Summary")) {
                        HStack {
                            Text("Total Value")
                            Spacer()
                            Text("$10,245.67")
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Today's Change")
                            Spacer()
                            Text("+$142.59 (+1.41%)")
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Cash Available")
                            Spacer()
                            Text("$1,256.34")
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("Your Holdings")) {
                        ForEach(0..<3) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(["AAPL", "MSFT", "AMZN"][index])
                                        .font(.headline)
                                    
                                    Text(["Apple Inc.", "Microsoft Corp.", "Amazon.com Inc."][index])
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(["$185.92", "$420.45", "$183.50"][index])
                                            .font(.subheadline)
                                        
                                        Text(["+1.27%", "-0.29%", "+1.91%"][index])
                                            .font(.caption)
                                            .foregroundColor(index == 1 ? .red : .green)
                                    }
                                }
                                
                                HStack {
                                    Text([10, 5, 8][index].description + " shares")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text(["$1,859.20", "$2,102.25", "$1,468.00"][index])
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Portfolio")
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userName") private var userName: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName.isEmpty ? "Not signed in" : userName)
                                .font(.headline)
                            Text(userEmail.isEmpty ? "Not signed in" : userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: Text("Subscription details")) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Subscription")
                        }
                    }
                    
                    NavigationLink(destination: Text("Notification settings")) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Notifications")
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: Text("Theme settings")) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Appearance")
                        }
                    }
                    
                    NavigationLink(destination: Text("Currency settings")) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Currency")
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Help center")) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("Help & Support")
                        }
                    }
                    
                    NavigationLink(destination: Text("App information")) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .frame(width: 25)
                                .foregroundColor(.blue)
                            Text("About App")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    func signOut() {
        // Clear user data
        userEmail = ""
        userName = ""
        isUserLoggedIn = false
        isAuthenticated = false
    }
}

// Note: Don't add @main here. Instead, update your existing App file:
/*
import SwiftUI

@main
struct Stock_analyzerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
