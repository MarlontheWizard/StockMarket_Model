import Foundation

// MARK: - Enhanced Gemini API Service for Stock Analysis
class GeminiService {
    // Your Gemini API Key
    private let apiKey = "AIzaSyDOwruybZjGcWLqkhCP7QJ1RZh09AuCKz4"
    
    // Endpoint URL with latest Gemini model
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    // Cache for storing recent responses
    private var responseCache: [String: (timestamp: Date, response: String)] = [:]
    private let cacheDuration: TimeInterval = 300 // 5 minutes cache
    
    func generateResponse(prompt: String) async throws -> String {
        // Check if the question is stock-related
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
        
        // Enhanced system prompt with improved stock-specific instructions
        let combinedPrompt = """
        You are a professional stock analyst and financial AI assistant.

        Your job is to provide:
        • Highly relevant, concise, and actionable stock-related answers
        • 3 to 5 bullet points only
        • Avoid all filler content or general advice
        • No greetings, disclaimers, or explanations unless critical
        • Use key numbers (like stock price, revenue, P/E, EPS) when helpful
        • If the question is not stock-related, redirect the user to ask about stocks
        - Do not use astrics 
        - give a confidence percentage when asked what to buy or sell

        User Question: \(prompt)
        """


        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": combinedPrompt]
                    ]
                ]
            ],

            "generationConfig": [
                "temperature": 0.3,      // Slightly higher to allow for analyst insight
                "topK": 40,
                "topP": 0.8,
                "maxOutputTokens": 300,  // Allow slightly longer responses for more detailed analysis
                "stopSequences": [],
                "presencePenalty": 0.0,
                "frequencyPenalty": 0.0
            ],
            "safetySettings": [
                [
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ],
                [
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
                ]
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
                
                // Post-process response to ensure it's formatted correctly
                let processedResponse = processResponse(text)
                
                // Store in cache
                responseCache[cacheKey] = (Date(), processedResponse)
                return processedResponse
            }
            
            return "Unable to analyze that stock question. Please try a more specific stock-related query."
            
        } catch {
            return "Network error. Please check your connection and try again."
        }
    }
    
    // Helper function to determine if a question is stock-related using NLP techniques
    private func isStockRelatedQuestion(_ question: String) -> Bool {
        let question = question.lowercased()
        
        // Primary finance and stock market terms
        let primaryStockTerms = [
            "stock", "share", "market", "invest", "trading", "nasdaq", "dow", "s&p", "nyse"
        ]
        
        // Secondary finance terms - only count these if there are other indicators
        let secondaryStockTerms = [
            "bull", "bear", "dividend", "portfolio", "etf", "fund", "ticker", "price",
            "equity", "asset", "finance", "earnings", "quarter", "fiscal", "volatility",
            "gain", "loss", "broker", "trade", "securities", "bond", "yield", "interest rate",
            "fed", "recession", "inflation", "economy", "rally", "crash", "correction",
            "analysis", "forecast", "prediction", "chart", "technical", "fundamental"
        ]
        
        // Common stock symbols and company names
        let stockSymbols = [
            "aapl", "msft", "amzn", "tsla", "goog", "googl", "meta", "nvda", "jpm", "bac",
            "wmt", "dis", "nflx", "ko", "pep", "mrk", "pfe", "unh", "jnj", "v", "ma"
        ]
        
        // Common company names in lowercase
        let companyNames = [
            "apple", "microsoft", "amazon", "tesla", "google", "alphabet", "meta",
            "facebook", "nvidia", "jpmorgan", "bank of america", "walmart", "disney",
            "netflix", "coca cola", "coke", "pepsi", "pepsico", "merck", "pfizer",
            "unitedhealth", "johnson & johnson", "visa", "mastercard"
        ]
        
        // Check for stock symbols and company names first (strongest indicators)
        for symbol in stockSymbols {
            if question.contains(symbol) {
                return true
            }
        }
        
        for company in companyNames {
            if question.contains(company) {
                return true
            }
        }
        
        // Check for primary stock terms (also strong indicators)
        for term in primaryStockTerms {
            if question.contains(term) {
                return true
            }
        }
        
        // Check for combinations of secondary terms (weaker indicators need multiple matches)
        var secondaryTermCount = 0
        for term in secondaryStockTerms {
            if question.contains(term) {
                secondaryTermCount += 1
                if secondaryTermCount >= 2 {  // If at least 2 secondary terms are found
                    return true
                }
            }
        }
        
        // Check for specific phrases that indicate stock questions
        let stockPhrases = [
            "stock price", "market cap", "price target", "buy or sell", "worth investing",
            "good investment", "stock analysis", "chart pattern", "moving average",
            "earnings report", "quarterly results", "market sentiment", "stock recommendation"
        ]
        
        for phrase in stockPhrases {
            if question.contains(phrase) {
                return true
            }
        }
        
        return false
    }
    
    // Process response to ensure it follows our formatting guidelines
    private func processResponse(_ response: String) -> String {
        var processedResponse = response
        
        // Ensure response has bullet points
        if !processedResponse.contains("•") && !processedResponse.contains("-") {
            // Convert paragraphs to bullet points if needed
            let paragraphs = processedResponse.components(separatedBy: "\n\n").filter { !$0.isEmpty }
            if paragraphs.count > 1 {
                processedResponse = paragraphs.map { "• \($0)" }.joined(separator: "\n")
            }
        }
        
        // Remove excessive line breaks
        processedResponse = processedResponse.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        
        // Remove disclaimer statements if they exist
        let disclaimerPhrases = [
            "please note that", "this is not financial advice", "this information is not intended",
            "consult with a financial advisor", "past performance is not", "invest at your own risk"
        ]
        
        for phrase in disclaimerPhrases {
            if let range = processedResponse.range(of: phrase, options: .caseInsensitive) {
                let sentenceRange = processedResponse.rangeOfSentence(containing: range)
                if let sentenceRange = sentenceRange {
                    processedResponse.removeSubrange(sentenceRange)
                }
            }
        }
        
        return processedResponse
    }
}

// Extension to help find complete sentences
extension String {
    func rangeOfSentence(containing range: Range<String.Index>) -> Range<String.Index>? {
        let sentenceDelimiters = [".", "!", "?"]
        
        // Find the start of the sentence
        var sentenceStart = self.startIndex
        if range.lowerBound > self.startIndex {
            for index in self.indices.reversed() where index < range.lowerBound {
                if sentenceDelimiters.contains(String(self[index])) {
                    sentenceStart = self.index(after: index)
                    break
                }
                if index == self.startIndex {
                    break
                }
            }
        }
        
        // Find the end of the sentence
        var sentenceEnd = self.endIndex
        for index in self.indices where index >= range.upperBound {
            if sentenceDelimiters.contains(String(self[index])) {
                sentenceEnd = self.index(after: index)
                break
            }
        }
        
        return sentenceStart < sentenceEnd ? sentenceStart..<sentenceEnd : nil
    }
}
