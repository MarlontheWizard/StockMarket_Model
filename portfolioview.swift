import SwiftUI
import Combine

struct PortfolioView: View {
    @State private var showAddStockSheet = false
    @State private var showRemoveStockSheet = false
    @State private var cashAvailable: Double = 100000.00 // Starting with $100,000
    @State private var portfolioStocks: [PortfolioStock] = []
    @State private var forecastPeriod: ForecastPeriod = .thirtyDays
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Action buttons in header
                HStack {
                    Button(action: {
                        showRemoveStockSheet = true
                    }) {
                        HStack {
                            Image(systemName: "minus")
                            Text("Remove Stock")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                    }
                    .disabled(portfolioStocks.isEmpty)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddStockSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Stock")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                }

                // Forecast Period Picker below the buttons
                Picker("Forecast Period", selection: $forecastPeriod) {
                    ForEach(ForecastPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 8)
                .padding(.horizontal)

                List {
                    // Portfolio Prediction Card
                    Section {
                        PortfolioPredictionCard(portfolioStocks: portfolioStocks, forecastPeriod: forecastPeriod)
                    }
                    
                    Section(header: Text("Portfolio Summary")) {
                        HStack {
                            Text("Starting Value")
                            Spacer()
                            let projectedGrowth = calculateProjectedGrowth()
                            Text("$\(100000, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Today's Change")
                            Spacer()
                            let dailyChange = calculateDailyChange()
                            Text("\(dailyChange > 0 ? "+" : "")\(dailyChange, specifier: "$%.2f") (\(calculateDailyChangePercentage(), specifier: "%.2f")%)")
                                .foregroundColor(dailyChange >= 0 ? .green : .red)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Cash Available")
                            Spacer()
                            Text("$\(cashAvailable, specifier: "%.2f")")
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Projected Growth (\(forecastPeriod.rawValue))")
                            Spacer()
                            let projectedGrowth = calculateProjectedGrowth()
                            Text("+\(projectedGrowth, specifier: "$%.2f") (+\(calculateProjectedGrowthPercentage(), specifier: "%.2f")%)")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }

                    Section(header: Text("Your Holdings")) {
                        ForEach(portfolioStocks.indices, id: \.self) { index in
                            NavigationLink(destination: StockDetailView(stock: portfolioStocks[index])) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(portfolioStocks[index].symbol)
                                            .font(.headline)
                                        
                                        Text(portfolioStocks[index].name)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("$\(portfolioStocks[index].currentPrice, specifier: "%.2f")")
                                                .font(.subheadline)
                                            
                                            Text("\(portfolioStocks[index].dailyChange > 0 ? "+" : "")\(portfolioStocks[index].dailyChange, specifier: "%.2f")%")
                                                .font(.caption)
                                                .foregroundColor(portfolioStocks[index].dailyChange >= 0 ? .green : .red)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("\(portfolioStocks[index].shares) shares")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("$\(portfolioStocks[index].totalValue, specifier: "%.2f")")
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    // Prediction indicator dynamically updating based on forecastPeriod
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        
                                        Text("Predicted: \(portfolioStocks[index].predictedChange(for: forecastPeriod) > 0 ? "+" : "")\(portfolioStocks[index].predictedChange(for: forecastPeriod), specifier: "%.1f")% (\(forecastPeriod.rawValue))")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Portfolio")
            .sheet(isPresented: $showAddStockSheet) {
                AddStockView(portfolioStocks: $portfolioStocks, cashAvailable: $cashAvailable)
            }
            .sheet(isPresented: $showRemoveStockSheet) {
                RemoveStockView(portfolioStocks: $portfolioStocks, cashAvailable: $cashAvailable)
            }
        }
    }
    
    private func calculateTotalValue() -> Double {
        return portfolioStocks.reduce(0) { $0 + $1.totalValue } + cashAvailable
    }

    private func calculateDailyChange() -> Double {
        return portfolioStocks.reduce(0) { $0 + $1.dailyChange }
    }

    private func calculateDailyChangePercentage() -> Double {
        let totalValue = calculateTotalValue()
        return totalValue > 0 ? (calculateDailyChange() / totalValue) * 100 : 0
    }

    private func calculateProjectedGrowth() -> Double {
        return portfolioStocks.reduce(0) { $0 + $1.predictedChange(for: forecastPeriod) }
    }

    private func calculateProjectedGrowthPercentage() -> Double {
        let totalValue = calculateTotalValue()
        return totalValue > 0 ? (calculateProjectedGrowth() / totalValue) * 100 : 0
    }
}



extension PortfolioView {
    private func CalculateTotalValue() -> Double {
        return portfolioStocks.reduce(0) { $0 + $1.totalValue } + cashAvailable
    }

}


// MARK: - Forecast Period Enum
enum ForecastPeriod: String, CaseIterable {
    case thirtyDays = "30 Days"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
    case fiveYears = "5 Years"
}

// MARK: - Portfolio Prediction Card
struct PortfolioPredictionCard: View {
    let portfolioStocks: [PortfolioStock]
    let forecastPeriod: ForecastPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Portfolio Prediction")
                .font(.headline)
            
            if portfolioStocks.isEmpty {
                Text("Add stocks to see predictions")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                HStack {
                    Text("Projected Value (\(forecastPeriod.rawValue))")
                    Spacer()
                    Text("$\(calculateProjectedValue(), specifier: "%.2f")")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Potential Gain")
                    Spacer()
                    let projectedGrowth = calculateProjectedGrowth()
                    Text("+\(projectedGrowth, specifier: "$%.2f") (+\(projectedGrowth/calculateProjectedValue(), specifier: "%.2f")%)")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func calculateProjectedValue() -> Double {
            let currentValue = portfolioStocks.reduce(0) { $0 + $1.totalValue }
            return currentValue + calculateProjectedGrowth()
        }
        
        private func calculateProjectedGrowth() -> Double {
            return portfolioStocks.reduce(0) { $0 + ($1.totalValue * $1.predictedChange(for: forecastPeriod) / 100) }
        }
        
        private func calculateProjectedGrowthPercentage() -> Double {
            let totalValue = portfolioStocks.reduce(0) { $0 + $1.totalValue }
            return totalValue > 0 ? (calculateProjectedGrowth() / totalValue) * 100 : 0
        }
}

// MARK: - Portfolio Stock Model
extension PortfolioStock {
    func predictedChange(for period: ForecastPeriod) -> Double {
        switch period {
        case .thirtyDays:
            return predictedChange
        case .sixMonths:
            return predictedChange * 6 // 6 times the 30-day prediction
        case .oneYear:
            return predictedChange * 12 // 12 times the 30-day prediction
        case .fiveYears:
            return predictedChange * 60 // 60 times the 30-day prediction
        }
    }
    
    func projectedValue(for period: ForecastPeriod) -> Double {
        let growthMultiplier = 1 + predictedChange(for: period) / 100
        return totalValue * growthMultiplier
    }
}


// MARK: - Portfolio Stock Model
struct PortfolioStock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let currentPrice: Double
    var shares: Int
    let dailyChange: Double
    let predictedChange: Double
    
    func predictedChange1(for period: ForecastPeriod) -> Double {
            switch symbol {
            case "AAPL":
                switch period {
                case .thirtyDays:
                    return 3.5 // Example: +3.5% in 30 days
                case .sixMonths:
                    return 12.0 // Example: +12% in 6 months
                case .oneYear:
                    return 25.0 // Example: +25% in 1 year
                case .fiveYears:
                    return 120.0 // Example: +120% in 5 years
                }
            case "AMZN":
                switch period {
                case .thirtyDays:
                    return 2.8
                case .sixMonths:
                    return 10.0
                case .oneYear:
                    return 22.0
                case .fiveYears:
                    return 110.0
                }
            case "TSLA":
                switch period {
                case .thirtyDays:
                    return 5.0
                case .sixMonths:
                    return 18.0
                case .oneYear:
                    return 40.0
                case .fiveYears:
                    return 200.0
                }
            case "MSFT":
                switch period {
                case .thirtyDays:
                    return 3.0
                case .sixMonths:
                    return 11.0
                case .oneYear:
                    return 24.0
                case .fiveYears:
                    return 115.0
                }
            default:
                return predictedChange // Default value for other stocks
            }
        }
        
        var totalValue: Double {
            return currentPrice * Double(shares)
        }
        
        var projectedValue: Double {
            let growthMultiplier = 1 + predictedChange(for: ForecastPeriod.thirtyDays) / 100 // Default to 30 days for calculation
            return totalValue * growthMultiplier
        }
}

// MARK: - Portfolio Prediction Card
//private func calculateProjectedGrowth() -> Double {
//    return portfolioStocks.reduce(0) { $0 + ($1.totalValue * $1.predictedChange(for: forecastPeriod) / 100) }
//}
//
//private func calculateProjectedGrowthPercentage() -> Double {
//    let totalValue = CalculateTotalValue()
//    return totalValue > 0 ? (calculateProjectedGrowth() / totalValue) * 100 : 0
//}


// MARK: - Twelve Data API Models
struct TwelveDataSymbol: Identifiable, Codable {
    let symbol: String
    let name: String
    let currency: String
    let exchange: String
    let country: String
    let type: String
    
    var id: String { symbol }
}

struct TwelveDataResponse: Codable {
    let data: [TwelveDataSymbol]
    let status: String
}

struct StockPrice: Codable {
    let price: String
    
    var priceDouble: Double {
        return Double(price) ?? 0.0
    }
}

struct StockPriceResponse: Decodable {
    let price: String
    
    var priceDouble: Double {
        return Double(price) ?? 0.0
    }
}

// MARK: - API Service
class TwelveDataService: ObservableObject {
    private let apiKey = "cvkl7qpr01qtnb8tbrogcvkl7qpr01qtnb8tbrp0"
    @Published var symbols: [TwelveDataSymbol] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func fetchSymbols() {
        isLoading = true
        errorMessage = ""
        
        let urlString = "https://api.twelvedata.com/stocks?source=docs&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(TwelveDataResponse.self, from: data)
                    self.symbols = response.data
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchStockPrice(symbol: String, completion: @escaping (Result<Double, Error>) -> Void) {
        let urlString = "https://api.twelvedata.com/price?symbol=\(symbol)&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                }
                return
            }
            
            do {
                let priceResponse = try JSONDecoder().decode(StockPriceResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(priceResponse.priceDouble))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}

// Updated AddStockView to handle existing stocks
struct AddStockView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var portfolioStocks: [PortfolioStock]
    @Binding var cashAvailable: Double
    @StateObject private var apiService = TwelveDataService()
    
    @State private var selectedStock: TwelveDataSymbol?
    @State private var stockPrice: Double = 0.0
    @State private var shares: String = ""
    @State private var searchText: String = ""
    @State private var showInsufficientFundsAlert = false
    @State private var isLoadingPrice = false
    @State private var errorMessage = ""
    
    func fetchStockPrice(for symbol: String) {
        isLoadingPrice = true
        errorMessage = ""
        
        apiService.fetchSymbols()
        
        if let stock = apiService.symbols.first(where: { $0.symbol == symbol }) {
            selectedStock = stock
            
            apiService.fetchStockPrice(symbol: symbol) { result in
                switch result {
                case .success(let price):
                    self.stockPrice = price
                    self.isLoadingPrice = false
                case .failure(let error):
                    self.errorMessage = "Error getting price: \(error.localizedDescription)"
                    self.isLoadingPrice = false
                }
            }
        } else {
            apiService.fetchStockPrice(symbol: symbol) { result in
                switch result {
                case .success(let price):
                    self.selectedStock = TwelveDataSymbol(
                        symbol: symbol,
                        name: symbol,
                        currency: "USD",
                        exchange: "Unknown",
                        country: "Unknown",
                        type: "Stock"
                    )
                    self.stockPrice = price
                    self.isLoadingPrice = false
                case .failure(let error):
                    self.errorMessage = "Error: Could not find stock or get price. \(error.localizedDescription)"
                    self.isLoadingPrice = false
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter stock symbol", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button("Search") {
                    fetchStockPrice(for: searchText.uppercased())
                }
                .padding()
                .disabled(searchText.isEmpty)
                
                if isLoadingPrice {
                    ProgressView("Fetching stock price...")
                        .padding()
                } else if let selectedStock = selectedStock {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Selected Stock:")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                self.selectedStock = nil
                                self.stockPrice = 0.0
                            }) {
                                Text("Change")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedStock.symbol)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(selectedStock.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(stockPrice, specifier: "%.2f")")
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Shares")
                                .font(.headline)
                            
                            TextField("Enter shares", text: $shares)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .disabled(isLoadingPrice || stockPrice <= 0)
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let sharesInt = Int(shares), sharesInt > 0 {
                                let totalCost = Double(sharesInt) * stockPrice
                                
                                if totalCost <= cashAvailable {
                                    // Check if stock already exists in portfolio
                                    if let existingIndex = portfolioStocks.firstIndex(where: { $0.symbol == selectedStock.symbol }) {
                                        // Update existing stock by adding shares
                                        var updatedStock = portfolioStocks[existingIndex]
                                        updatedStock.shares += sharesInt
                                        portfolioStocks[existingIndex] = updatedStock
                                    } else {
                                        // Add new stock
                                        let newStock = PortfolioStock(
                                            symbol: selectedStock.symbol,
                                            name: selectedStock.name,
                                            currentPrice: stockPrice,
                                            shares: sharesInt,
                                            dailyChange: 0.0,
                                            predictedChange: 5.0
                                        )
                                        portfolioStocks.append(newStock)
                                    }
                                    
                                    // Deduct cost from available cash
                                    cashAvailable -= totalCost
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    showInsufficientFundsAlert = true
                                }
                            }
                        }) {
                            Text("Add to Portfolio")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((shares.isEmpty || Int(shares) ?? 0 <= 0 || stockPrice <= 0 || isLoadingPrice) ? Color.gray : Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(shares.isEmpty || Int(shares) ?? 0 <= 0 || stockPrice <= 0 || isLoadingPrice)
                        .alert(isPresented: $showInsufficientFundsAlert) {
                            Alert(
                                title: Text("Insufficient Funds"),
                                message: Text("You don't have enough cash to complete this purchase."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Stock")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    private func addHardcodedStock(symbol: String, name: String, price: Double, shares: Int) {
            let newStock = PortfolioStock(
                symbol: symbol,
                name: name,
                currentPrice: price,
                shares: shares,
                dailyChange: 0,
                predictedChange: 0 // Default change; overridden by hardcoded logic in PortfolioStock model.
            )
            portfolioStocks.append(newStock)
            cashAvailable -= price * Double(shares)
        }
}

// Updated RemoveStockView to properly handle stock removal
struct RemoveStockView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var portfolioStocks: [PortfolioStock]
    @Binding var cashAvailable: Double
    
    @State private var selectedStock: PortfolioStock?
    @State private var sharesToRemove: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Stock selection list
                if selectedStock == nil {
                    List {
                        ForEach(portfolioStocks) { stock in
                            Button(action: {
                                selectedStock = stock
                                sharesToRemove = "\(stock.shares)" // Default to all shares
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(stock.symbol)
                                            .font(.headline)
                                        
                                        Text(stock.name)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("$\(stock.currentPrice, specifier: "%.2f")")
                                            .font(.subheadline)
                                        
                                        Text("\(stock.shares) shares")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    // Share removal form
                    VStack(spacing: 20) {
                        HStack {
                            Text("Selected Stock:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                self.selectedStock = nil
                                self.sharesToRemove = ""
                            }) {
                                Text("Change")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedStock!.symbol)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(selectedStock!.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(selectedStock!.currentPrice, specifier: "%.2f")")
                                    .font(.headline)
                                
                                Text("\(selectedStock!.shares) shares available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shares to Sell")
                                .font(.headline)
                            
                            TextField("Enter shares", text: $sharesToRemove)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        if !sharesToRemove.isEmpty, let sharesToRemoveInt = Int(sharesToRemove), sharesToRemoveInt > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sale Summary")
                                    .font(.headline)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Share Price")
                                        Spacer()
                                        Text("$\(selectedStock!.currentPrice, specifier: "%.2f")")
                                    }
                                    
                                    HStack {
                                        Text("Number of Shares")
                                        Spacer()
                                        Text("\(sharesToRemove)")
                                    }
                                    
                                    Divider()
                                    
                                    let totalValue = (Double(sharesToRemove) ?? 0) * selectedStock!.currentPrice
                                    
                                    HStack {
                                        Text("Total Value")
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text("$\(totalValue, specifier: "%.2f")")
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Text("Current Cash")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("$\(cashAvailable, specifier: "%.2f")")
                                            .fontWeight(.medium)
                                    }
                                    
                                    HStack {
                                        Text("New Cash Balance")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("$\(cashAvailable + totalValue, specifier: "%.2f")")
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let sharesToRemoveInt = Int(sharesToRemove),
                               let stock = selectedStock,
                               sharesToRemoveInt > 0 && sharesToRemoveInt <= stock.shares {
                                
                                // Calculate cash to add
                                let cashToAdd = Double(sharesToRemoveInt) * stock.currentPrice
                                
                                // Increase available cash
                                cashAvailable += cashToAdd
                                
                                // Update or remove the stock from portfolio
                                if let index = portfolioStocks.firstIndex(where: { $0.id == stock.id }) {
                                    if sharesToRemoveInt < stock.shares {
                                        // Update shares count only
                                        var updatedStock = stock
                                        updatedStock.shares -= sharesToRemoveInt
                                        portfolioStocks[index] = updatedStock
                                    } else {
                                        // Remove the stock completely
                                        portfolioStocks.remove(at: index)
                                    }
                                }
                                
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Sell Shares")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (sharesToRemove.isEmpty ||
                                     Int(sharesToRemove) ?? 0 <= 0 ||
                                     Int(sharesToRemove) ?? 0 > (selectedStock?.shares ?? 0)) ?
                                    Color.gray : Color.red
                                )
                                .cornerRadius(12)
                        }
                        .disabled(
                            sharesToRemove.isEmpty ||
                            Int(sharesToRemove) ?? 0 <= 0 ||
                            Int(sharesToRemove) ?? 0 > (selectedStock?.shares ?? 0)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Sell Stocks")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Updated removeStock method for the PortfolioView
extension PortfolioView {
    func removeStock(symbol: String, sharesToRemove: Int? = nil) {
        // Find the stock in the portfolio
        if let index = portfolioStocks.firstIndex(where: { $0.symbol == symbol }) {
            let stock = portfolioStocks[index]
            
            // Determine how many shares to remove
            let actualSharesToRemove = sharesToRemove ?? stock.shares
            
            // Validate share count to remove
            guard actualSharesToRemove > 0 && actualSharesToRemove <= stock.shares else {
                return // Invalid share count
            }
            
            // Calculate cash to add back to available balance
            let cashToAdd = Double(actualSharesToRemove) * stock.currentPrice
            
            // Increase available cash
            cashAvailable += cashToAdd
            
            // Update or remove the stock from portfolio
            if actualSharesToRemove < stock.shares {
                // Update shares count only
                var updatedStock = stock
                updatedStock.shares -= actualSharesToRemove
                portfolioStocks[index] = updatedStock
            } else {
                // Remove the stock completely
                portfolioStocks.remove(at: index)
            }
        }
    }
}

// Also add a RemoveStockView struct to use with the sheet presentation
struct removeStockView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var portfolioStocks: [PortfolioStock]
    @Binding var cashAvailable: Double
    
    @State private var selectedStock: PortfolioStock?
    @State private var sharesToRemove: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Stock selection list
                if selectedStock == nil {
                    List {
                        ForEach(portfolioStocks) { stock in
                            Button(action: {
                                selectedStock = stock
                                sharesToRemove = "\(stock.shares)" // Default to all shares
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(stock.symbol)
                                            .font(.headline)
                                        
                                        Text(stock.name)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("$\(stock.currentPrice, specifier: "%.2f")")
                                            .font(.subheadline)
                                        
                                        Text("\(stock.shares) shares")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    // Share removal form
                    VStack(spacing: 20) {
                        HStack {
                            Text("Selected Stock:")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                self.selectedStock = nil
                                self.sharesToRemove = ""
                            }) {
                                Text("Change")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedStock!.symbol)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(selectedStock!.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(selectedStock!.currentPrice, specifier: "%.2f")")
                                    .font(.headline)
                                
                                Text("\(selectedStock!.shares) shares available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shares to Sell")
                                .font(.headline)
                            
                            TextField("Enter shares", text: $sharesToRemove)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        if !sharesToRemove.isEmpty, let sharesToRemoveInt = Int(sharesToRemove), sharesToRemoveInt > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sale Summary")
                                    .font(.headline)
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Share Price")
                                        Spacer()
                                        Text("$\(selectedStock!.currentPrice, specifier: "%.2f")")
                                    }
                                    
                                    HStack {
                                        Text("Number of Shares")
                                        Spacer()
                                        Text("\(sharesToRemove)")
                                    }
                                    
                                    Divider()
                                    
                                    let totalValue = (Double(sharesToRemove) ?? 0) * selectedStock!.currentPrice
                                    
                                    HStack {
                                        Text("Total Value")
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text("$\(totalValue, specifier: "%.2f")")
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Text("Current Cash")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("$\(cashAvailable, specifier: "%.2f")")
                                            .fontWeight(.medium)
                                    }
                                    
                                    HStack {
                                        Text("New Cash Balance")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("$\(cashAvailable + totalValue, specifier: "%.2f")")
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let sharesToRemoveInt = Int(sharesToRemove),
                               let stock = selectedStock,
                               sharesToRemoveInt > 0 && sharesToRemoveInt <= stock.shares {
                                
                                // Calculate cash to add
                                let cashToAdd = Double(sharesToRemoveInt) * stock.currentPrice
                                
                                // Increase available cash
                                cashAvailable += cashToAdd
                                
                                // Update or remove the stock from portfolio
                                if let index = portfolioStocks.firstIndex(where: { $0.id == stock.id }) {
                                    if sharesToRemoveInt < stock.shares {
                                        // Update shares count only
                                        var updatedStock = stock
                                        updatedStock.shares -= sharesToRemoveInt
                                        portfolioStocks[index] = updatedStock
                                    } else {
                                        // Remove the stock completely
                                        portfolioStocks.remove(at: index)
                                    }
                                }
                                
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Sell Shares")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (sharesToRemove.isEmpty ||
                                     Int(sharesToRemove) ?? 0 <= 0 ||
                                     Int(sharesToRemove) ?? 0 > (selectedStock?.shares ?? 0)) ?
                                    Color.gray : Color.red
                                )
                                .cornerRadius(12)
                        }
                        .disabled(
                            sharesToRemove.isEmpty ||
                            Int(sharesToRemove) ?? 0 <= 0 ||
                            Int(sharesToRemove) ?? 0 > (selectedStock?.shares ?? 0)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Sell Stocks")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Also update your PortfolioView body to use the sheet:
// Add this inside PortfolioView's body after the existing sheet for adding stocks
/*
.sheet(isPresented: $showRemoveStockSheet) {
    RemoveStockView(portfolioStocks: $portfolioStocks, cashAvailable: $cashAvailable)
}
*/
// MARK: - Stock Detail View
struct StockDetailView: View {
    let stock: PortfolioStock
    @State private var timeRange = "1M"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stock.name)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text(stock.symbol)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(stock.currentPrice, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(stock.dailyChange > 0 ? "+" : "")\(stock.dailyChange, specifier: "%.2f")%")
                            .font(.subheadline)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Chart section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Price History")
                        .font(.headline)
                    
                    // Time range selector
                    HStack {
                        ForEach(["1D", "1W", "1M", "3M", "6M", "1Y"], id: \.self) { range in
                            Button(action: {
                                timeRange = range
                            }) {
                                Text(range)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(timeRange == range ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(timeRange == range ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Chart placeholder
                    ZStack {
                        // Sample chart shape
                        Path { path in
                            let width: CGFloat = UIScreen.main.bounds.width - 40
                            let height: CGFloat = 200
                            
                            // Starting point
                            path.move(to: CGPoint(x: 0, y: height * 0.8))
                            
                            // Random points to create a chart-like appearance
                            path.addCurve(
                                to: CGPoint(x: width * 0.2, y: height * 0.6),
                                control1: CGPoint(x: width * 0.05, y: height * 0.75),
                                control2: CGPoint(x: width * 0.15, y: height * 0.65)
                            )
                            
                            path.addCurve(
                                to: CGPoint(x: width * 0.4, y: height * 0.7),
                                control1: CGPoint(x: width * 0.25, y: height * 0.55),
                                control2: CGPoint(x: width * 0.35, y: height * 0.65)
                            )
                            
                            path.addCurve(
                                to: CGPoint(x: width * 0.6, y: height * 0.4),
                                control1: CGPoint(x: width * 0.45, y: height * 0.75),
                                control2: CGPoint(x: width * 0.55, y: height * 0.5)
                            )
                            
                            path.addCurve(
                                to: CGPoint(x: width * 0.8, y: height * 0.3),
                                control1: CGPoint(x: width * 0.65, y: height * 0.3),
                                control2: CGPoint(x: width * 0.75, y: height * 0.35)
                            )
                            
                            path.addCurve(
                                to: CGPoint(x: width, y: height * 0.2),
                                control1: CGPoint(x: width * 0.85, y: height * 0.25),
                                control2: CGPoint(x: width * 0.95, y: height * 0.3)
                            )
                        }
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 3
                        )
                        
                        Text("Chart data will be implemented with real market data")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .padding(.vertical)
                }
                
                // AI Prediction section
                VStack(alignment: .leading, spacing: 10) {
                    Text("AI Prediction Analysis")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("30-Day Price Forecast")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(stock.predictedChange > 0 ? "+" : "")\(stock.predictedChange, specifier: "%.1f")%")
                                .font(.subheadline)
                                .padding(6)
                                .background(stock.predictedChange > 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .foregroundColor(stock.predictedChange > 0 ? .green : .red)
                                .cornerRadius(8)
                        }
                        
                        // Prediction confidence meter
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prediction Confidence")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .green]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.65 * 0.85, height: 8)
                                    .cornerRadius(4)
                            }
                            
                            Text("85%")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Based on historical data, market trends, and AI-powered technical analysis")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                        
                        Divider()
                        
                        // Prediction rationale
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Factors")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.green)
                                
                                Text("Strong quarterly earnings report expected")
                                    .font(.caption)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.green)
                                
                                Text("Positive industry trends and market sentiment")
                                    .font(.caption)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.green)
                                
                                Text("Recent product launches driving growth")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Holdings information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Holdings")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Shares Owned")
                        }
                    }
                }
            }
        }
    }
}
