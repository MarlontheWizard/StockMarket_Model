import SwiftUI

struct HomeView: View {
    @State private var customStocks: [Stock] = []
    @State private var defaultStocks: [Stock] = []
    @State private var marketStocks: [Stock] = []
    @State private var predictions: [Prediction] = [
        Prediction(symbol: "AAPL", message: "Bullish trend expected over next 30 days", confidence: 0.85),
        Prediction(symbol: "MSFT", message: "Moderate growth with potential volatility", confidence: 0.72),
        Prediction(symbol: "TSLA", message: "Potential correction in short-term", confidence: 0.68)
    ]

    @State private var showingAddStockPrompt = false
    @State private var showingInvalidStockAlert = false
    @State private var newStockInput = ""
    @State private var stockToDelete: Stock? = nil
    @State private var showChat = false
    @State private var navigateToPortfolio = false

    let defaultSymbols = ["AAPL", "MSFT"]
    let marketSymbols = ["TSLA", "PFE", "NVDA"]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {

                        // TODAY'S MARKET
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Market")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(marketStocks) { stock in
                                        MarketIndexCard(
                                            name: stock.symbol,
                                            value: stock.price,
                                            change: stock.change + "%",
                                            isPositive: stock.isPositive
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Divider()

                        // FEATURED STOCKS
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

                            if defaultStocks.isEmpty && customStocks.isEmpty {
                                Text("No featured stocks to show.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }

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

                        // RECENT PREDICTIONS
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Predictions")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                ForEach(predictions.filter { $0.stock != nil }) { prediction in
                                    let stock = prediction.stock!
                                    PredictionCard(
                                        stockSymbol: stock.symbol,
                                        stockName: stock.name,
                                        predictionText: prediction.message,
                                        confidence: prediction.confidence
                                    )
                                }

                                ForEach(predictions.filter { $0.stock == nil }) { _ in
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }

                // Chat Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: ChatView()
                            .transition(.move(edge: .trailing))
                            .animation(.easeInOut(duration: 0.4), value: showChat)
                        ) {
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.purple)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Market Overview")
            .onAppear {
                loadDefaultStocks()
                loadMarketStocks()
                loadPredictionStocks()
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
                        print("✅ Loaded stock: \(stock.symbol) - \(stock.name)")
                        defaultStocks.append(stock)
                    } else {
                        print("❌ Failed to load stock: \(symbol)")
                    }
                }
            }
        }
    }

    func loadMarketStocks() {
        marketStocks.removeAll()
        for symbol in marketSymbols {
            fetchStockInfo(for: symbol) { result in
                DispatchQueue.main.async {
                    if let stock = result {
                        marketStocks.append(stock)
                    }
                }
            }
        }
    }

    func loadPredictionStocks() {
        for index in predictions.indices {
            let symbol = predictions[index].symbol
            fetchStockInfo(for: symbol) { result in
                DispatchQueue.main.async {
                    if let stock = result {
                        predictions[index].stock = stock
                    }
                }
            }
        }
    }

    func fetchStockInfo(for symbol: String, completion: @escaping (Stock?) -> Void) {
        let apiKey = "4347b40324b947c5a16bdc87d7c1ada8"
        let urlString = "https://api.twelvedata.com/quote?symbol=\(symbol)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for \(symbol)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data for \(symbol)")
                completion(nil)
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw API response for \(symbol):\n\(raw)")
            }

            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let name = json["name"] as? String,
                let priceStr = json["close"] as? String,
                let changeStr = json["percent_change"] as? String,
                let price = Double(priceStr),
                let change = Double(changeStr)
            else {
                print("⚠️ JSON parsing failed for \(symbol)")
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

// MARK: - Supporting Views and Models

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool
    let history: [Double]
}

struct Prediction: Identifiable {
    let id = UUID()
    let symbol: String
    let message: String
    let confidence: Double
    var stock: Stock? = nil
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
