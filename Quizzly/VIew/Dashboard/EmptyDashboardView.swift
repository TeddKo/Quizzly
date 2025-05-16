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
                .foregroundColor(.secondary.opacity(0.5))

            Text("아직 대시보드가 없습니다")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color.primary)

            Text("퀴즈를 풀어주세요!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    EmptyDashboardView()
}
