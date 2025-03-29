import SwiftUI

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
