//
//  RecentCard.swift
//  Quizzly
//
//  Created by DEV on 5/15/25.
//


import SwiftUI

struct RecentCard: View, Identifiable, Hashable {
    let id = UUID()
    let title: String
    let percent: Double
    let date: String
    let isCorrect: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isCorrect ? "checkmark.circle" : "xmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .fontWeight(.semibold)
                .foregroundColor(isCorrect ? .green : .red)
                .padding(8)
                .background(isCorrect ? .green.opacity(0.1) : .red.opacity(0.1))
                .cornerRadius(5)
                .padding(.leading, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()

                Text("\(Int(percent * 100))% 정답 · \(date)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Spacer()
        }
    }
}