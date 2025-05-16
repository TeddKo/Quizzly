//
//  Caution.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/15/25.
//

import SwiftUI

struct Caution: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 5) {
                
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.yellow)
                    .padding(8)
                
                Text("아이템이 없습니다.")
                    .font(.subheadline)
                    .bold()
                
            }
            .padding(15)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(8)
        }
    }
}

#Preview {
    Caution()
}
