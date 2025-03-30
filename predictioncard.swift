
import SwiftUI

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
