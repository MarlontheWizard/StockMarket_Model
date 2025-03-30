import SwiftUI


struct MainTabView: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
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

