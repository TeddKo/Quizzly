//
//  EmptyDashboardView.swift
//  Quizzly
//
//  Created by 강민지 on 5/15/25.
//


//
//  EmptyDashboardView.swift
//  Quizzly
//
//  Created by 강민지 on 5/15/25.
//

import SwiftUI

struct EmptyDashboardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.5))

            Text("아직 대시보드가 없습니다")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Text("퀴즈를 풀어주세요!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    EmptyDashboardView()
}
