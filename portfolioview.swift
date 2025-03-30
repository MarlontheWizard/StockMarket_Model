// portfolioview.swift
import SwiftUI

struct PortfolioView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Add button manually in a header
                HStack {
                    Spacer()
                    Button(action: {
                        // Add new stock action
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.horizontal)
                }
                
                List {
                    Section(header: Text("Portfolio Summary")) {
                        HStack {
                            Text("Total Value")
                            Spacer()
                            Text("$10,245.67")
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Today's Change")
                            Spacer()
                            Text("+$142.59 (+1.41%)")
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text("Cash Available")
                            Spacer()
                            Text("$1,256.34")
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("Your Holdings")) {
                        ForEach(0..<3) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(["AAPL", "MSFT", "AMZN"][index])
                                        .font(.headline)
                                    
                                    Text(["Apple Inc.", "Microsoft Corp.", "Amazon.com Inc."][index])
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(["$185.92", "$420.45", "$183.50"][index])
                                            .font(.subheadline)
                                        
                                        Text(["+1.27%", "-0.29%", "+1.91%"][index])
                                            .font(.caption)
                                            .foregroundColor(index == 1 ? .red : .green)
                                    }
                                }
                                
                                HStack {
                                    Text([10, 5, 8][index].description + " shares")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text(["$1,859.20", "$2,102.25", "$1,468.00"][index])
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Portfolio")
        }
    }
}
