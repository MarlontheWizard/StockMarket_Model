import SwiftUI

struct ChatView: View {
    @State private var message = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your AI stock assistant powered by Google's Gemini. How can I help you analyze or predict stock movements today?", isUser: false)
    ]
    @State private var isLoading = false
    private let geminiService = GeminiService()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.red.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }

                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }

                    Divider()

                    HStack {
                        TextField("Ask about stocks...", text: $message)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)

                        Button(action: {
                            sendMessage()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                                .padding(10)
                        }
                        .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Stock Assistant")
        }
    }

    func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(text: message, isUser: true)
        messages.append(userMessage)

        let userQuery = message
        message = ""
        isLoading = true

        Task {
            do {
                let geminiResponse = try await geminiService.generateResponse(prompt: userQuery)
                let aiMessage = ChatMessage(text: geminiResponse, isUser: false)
                messages.append(aiMessage)
            } catch {
                let errorMessage = ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false)
                messages.append(errorMessage)
            }

            isLoading = false
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(16)

                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }

            if !message.isUser { Spacer() }
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

