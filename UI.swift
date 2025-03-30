// UI.swift
import SwiftUI

// MARK: - App Logo View
struct LogoView: View {
    var body: some View {
        VStack(spacing: 8) {
            // Logo shape
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 80, height: 80)
                
                // Stock chart line in logo
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 50))
                    path.addLine(to: CGPoint(x: 40, y: 35))
                    path.addLine(to: CGPoint(x: 50, y: 45))
                    path.addLine(to: CGPoint(x: 60, y: 25))
                    path.addLine(to: CGPoint(x: 70, y: 30))
                }
                .stroke(Color.white, lineWidth: 3)
                
                // Dollar sign
                Text("$")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: -2)
            }
            
            Text("StockAI")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Enhanced Theme
struct EnhancedTheme {
    // App Colors
    static let primary = Color.blue
    static let secondary = Color(red: 0.1, green: 0.6, blue: 0.9)
    static let accent = Color.orange
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    
    // Custom Text Styles
    static func titleStyle(_ text: Text) -> some View {
        text
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(primary)
    }
    
    static func subtitleStyle(_ text: Text) -> some View {
        text
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color.primary)
    }
}

// MARK: - Custom Card View
struct EnhancedCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(EnhancedTheme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Market Index Card (moved from duplicate declaration)
struct MarketIndexCard: View {
    let name: String
    let value: String
    let change: String
    let isPositive: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)

            Text(value)
                .font(.headline)
                .foregroundColor(.white)

            Text(change)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(isPositive ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(6)
        }
        .padding(10)
        .background(Color.black.opacity(0.2))
        .cornerRadius(14)
        .frame(width: 120) // 👈 Add this!
    }
}




// MARK: - Enhanced Home View (removed reference to MainTabView)
struct EnhancedHomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Top section with logo
                    HStack {
                        LogoView()
                            .frame(height: 60)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(EnhancedTheme.primary)
                        }
                        .padding(.trailing)
                    }
                    
                    // Market Overview Card with enhanced styling
                    VStack(alignment: .leading, spacing: 10) {
                        EnhancedTheme.subtitleStyle(Text("Market Snapshot"))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                EnhancedCardView {
                                    MarketIndexCard(name: "S&P 500", value: "5,245.62", change: "+0.52%", isPositive: true)
                                }
                                
                                EnhancedCardView {
                                    MarketIndexCard(name: "NASDAQ", value: "16,384.47", change: "+0.65%", isPositive: true)
                                }
                                
                                EnhancedCardView {
                                    MarketIndexCard(name: "DOW", value: "39,127.14", change: "-0.18%", isPositive: false)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .background(EnhancedTheme.background)
        }
    }
}
