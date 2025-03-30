import SwiftUI

struct StockCard: View {
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool
    let history: [Double]

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
                    .lineLimit(1)
            }

            Text(price)
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 6) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                Text(change)
            }
            .foregroundColor(isPositive ? .green : .red)
            .font(.footnote)

            if history.count > 1 {
                GeometryReader { geo in
                    let maxY = history.max() ?? 1
                    let minY = history.min() ?? 0
                    let range = maxY - minY == 0 ? 1 : maxY - minY

                    Path { path in
                        for (index, value) in history.enumerated() {
                            let x = geo.size.width * CGFloat(index) / CGFloat(history.count - 1)
                            let y = geo.size.height * (1 - CGFloat((value - minY) / range))
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(isPositive ? Color.green : Color.red, lineWidth: 2)
                }
                .frame(height: 50)
            } else {
                Text("No data available")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

