import Foundation

// MARK: - Refined Gemini API Service for Concise Stock Analysis
class GeminiService {
    // Your Gemini API Key
    private let apiKey = "AIzaSyDOwruybZjGcWLqkhCP7QJ1RZh09AuCKz4" // Replace with your actual key
    
    // Updated endpoint URL with gemini-flash model
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    // Cache for storing recent responses
    private var responseCache: [String: (timestamp: Date, response: String)] = [:]
    private let cacheDuration: TimeInterval = 300 // 5 minutes cache
    
    func generateResponse(prompt: String) async throws -> String {
        // First, check if the question is even stock-related
        if !isStockRelatedQuestion(prompt) {
            return "I'm your AI stock assistant, so I can only answer questions about stocks, trading, investing, and financial markets. For other topics, please consult a general AI assistant."
        }
        
        // Check cache for identical questions
        let cacheKey = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let cachedItem = responseCache[cacheKey],
           Date().timeIntervalSince(cachedItem.timestamp) < cacheDuration {
            return cachedItem.response
        }
        
        let urlString = "\(baseURL)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Create a specialized prompt that enforces brevity
        let modifiedPrompt = """
        You are a stock market AI assistant focused on brief, direct answers.

        Rules to strictly follow:
        1. Keep your entire response under 100 words maximum
        2. Use only 3-5 bullet points
        3. Skip pleasantries and unnecessary context
        4. Don't apologize or add disclaimers
        5. If the question isn't about stocks, investing, or financial markets, just say you're only trained to answer stock-related questions
        6. Answer directly with what the user wants to know

        User question: \(prompt)
        """
        
        // Create the request body with parameters that encourage brevity
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": modifiedPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,  // Very low temperature for focused responses
                "topK": 40,
                "topP": 0.8,
                "maxOutputTokens": 200 // Hard limit on response length
            ]
        ]
        
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            return "Error preparing request."
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    return "API Error: \(message)"
                }
                return "Error connecting to analysis service."
            }
            
            // Parse the response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                
                // Store in cache
                responseCache[cacheKey] = (Date(), text)
                return text
            }
            
            return "Unable to analyze that stock question. Please try rephrasing."
            
        } catch {
            return "Network error. Please check your connection and try again."
        }
    }
    
    // Helper function to determine if a question is stock-related
    private func isStockRelatedQuestion(_ question: String) -> Bool {
        let question = question.lowercased()
        
        // Keywords related to stocks and finance
        let stockKeywords = [
            "stock", "share", "market", "invest", "trading", "nasdaq", "dow", "s&p", "nyse",
            "bull", "bear", "dividend", "portfolio", "etf", "fund", "ticker", "price",
            "equity", "asset", "finance", "earnings", "quarter", "fiscal", "volatility",
            "aapl", "msft", "amzn", "tsla", "goog", "meta", "nvda", "gain", "loss",
            "broker", "trade", "wall street", "securities", "bond", "yield", "interest rate",
            "fed", "recession", "inflation", "economy", "rally", "crash", "correction",
            "analysis", "forecast", "prediction", "chart", "technical", "fundamental"
        ]
        
        // Check if any of the keywords appear in the question
        return stockKeywords.contains { keyword in
            question.contains(keyword)
        }
    }
}
