import SwiftUI

struct HomeView: View {
    @State private var customStocks: [Stock] = []
    @State private var defaultStocks: [Stock] = []
    @State private var showingAddStockPrompt = false
    @State private var showingInvalidStockAlert = false
    @State private var newStockInput = ""
    @State private var stockToDelete: Stock? = nil

    let defaultSymbols = ["COF", "ITC.NS"]

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
                        HStack {
                            Text("Featured Stocks")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                showingAddStockPrompt = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(defaultStocks) { stock in
                                    MinimalStockCard(stock: stock)
                                }

                                ForEach(customStocks) { stock in
                                    MinimalStockCard(stock: stock)
                                        .contentShape(Rectangle())
                                        .onLongPressGesture {
                                            self.stockToDelete = stock
                                        }
                                }
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
            .onAppear {
                loadDefaultStocks()
            }
        }
        .alert("Add Stock", isPresented: $showingAddStockPrompt, actions: {
            TextField("Enter symbol (e.g. AAPL)", text: $newStockInput)
            Button("Add", action: {
                validateAndAddStock(input: newStockInput)
            })
            Button("Cancel", role: .cancel) { }
        }, message: {
            Text("Enter a valid stock ticker symbol.")
        })
        .alert("Invalid Stock", isPresented: $showingInvalidStockAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The stock symbol you entered is not recognized.")
        }
        .alert("Delete Stock", isPresented: Binding<Bool>(
            get: { stockToDelete != nil },
            set: { if !$0 { stockToDelete = nil } })
        ) {
            Button("Delete", role: .destructive) {
                if let stock = stockToDelete {
                    customStocks.removeAll { $0.id == stock.id }
                }
                stockToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                stockToDelete = nil
            }
        } message: {
            Text("Do you want to delete this stock?")
        }
    }

    func validateAndAddStock(input: String) {
        let trimmed = input.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        fetchStockInfo(for: trimmed) { result in
            DispatchQueue.main.async {
                if let stock = result {
                    customStocks.append(stock)
                } else {
                    showingInvalidStockAlert = true
                }
                newStockInput = ""
            }
        }
    }

    func loadDefaultStocks() {
        defaultStocks.removeAll()
        for symbol in defaultSymbols {
            fetchStockInfo(for: symbol) { result in
                DispatchQueue.main.async {
                    if let stock = result {
                        defaultStocks.append(stock)
                    }
                }
            }
        }
    }

    func fetchStockInfo(for symbol: String, completion: @escaping (Stock?) -> Void) {
        let apiKey = "ba8a9a72e3114293af6a80c4b75390d4"
        let urlString = "https://api.twelvedata.com/quote?symbol=\(symbol)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let name = json["name"] as? String,
                let priceStr = json["close"] as? String,
                let changeStr = json["percent_change"] as? String,
                let price = Double(priceStr),
                let change = Double(changeStr)
            else {
                completion(nil)
                return
            }

            let isPositive = change >= 0
            let priceFormatted = String(format: "$%.2f", price)
            let changeFormatted = String(format: "%.2f", change)

            let stock = Stock(symbol: symbol, name: name, price: priceFormatted, change: changeFormatted, isPositive: isPositive, history: [])
            completion(stock)
        }.resume()
    }
}

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool
    let history: [Double]
}

struct MinimalStockCard: View {
    let stock: Stock

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stock.name)
                .font(.caption)
                .foregroundColor(.gray)

            Text(stock.price)
                .font(.title3)
                .foregroundColor(.white)

            Text(stock.change)
                .font(.footnote)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(stock.isPositive ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(6)
        }
        .padding()
        .frame(width: 120)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

