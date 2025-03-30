import SwiftUI

@main
struct Stock_analyzerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true  // default to true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

