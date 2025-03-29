import SwiftUI

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
                            PredictionCard(stockSymbol: "AAPL", stockName: "Apple Inc.", predictionText: "Bullish trend expected over next 30 days", confidence: 0.85)
                            PredictionCard(stockSymbol: "MSFT", stockName: "Microsoft Corp.", predictionText: "Moderate growth with potential volatility", confidence: 0.72)
                            PredictionCard(stockSymbol: "TSLA", stockName: "Tesla Inc.", predictionText: "Potential correction in short-term", confidence: 0.68)
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

struct PredictionCard: View {
    let stockSymbol: String
    let stockName: String
    let predictionText: String
    let confidence: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stockSymbol)
                    .font(.headline)
                
                Text("•")
                
                Text(stockName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(Int(confidence * 100))% Confidence")
                    .font(.caption)
                    .padding(6)
                    .background(confidenceColor.opacity(0.2))
                    .foregroundColor(confidenceColor)
                    .cornerRadius(4)
            }
            
            Text(predictionText)
                .font(.subheadline)
            
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var confidenceColor: Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
}
