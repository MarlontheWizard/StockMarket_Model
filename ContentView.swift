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
