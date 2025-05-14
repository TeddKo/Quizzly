//
//  DashboardView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

enum Filter: String, CaseIterable {
    case week, month, all
    
    var label: String {
        switch self {
        case .week: return "이번 주"
        case .month: return "이번 달"
        case .all: return "전체"
        }
    }
}

struct DashboardView: View {
    @State private var selectedFilter: Filter = .all
    
    // TODO: 취약 카테고리 받아서 실제 percent로 교체
    private var weakCategoryPercent = 0.6
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("대시보드")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // MARK: 기간 탭 필터
                            Picker("기간 선택", selection: $selectedFilter) {
                                ForEach(Filter.allCases, id: \.self) { filter in
                                    Text(filter.label)
                                }
                            }
                        }
                        
                        // MARK: 퀴즈 통계 카드
                        HStack(spacing: 16) {
                            StatCard(title: "퀴즈 시도 횟수", value: "32", background: Color.blue.opacity(0.1))
                            
                            StatCard(title: "평균 정답률", value: "78%", subtitle: "↑ 5%", background: Color.green.opacity(0.1))
                        }
                        
                        // MARK: 카테고리별 성과
                        VStack(alignment: .leading, spacing: 12) {
                            Text("카테고리별 성과")
                                .font(.callout)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                CategoryPerformanceCard(category: "Swift", percent: 0.9, color: .blue, icon: "chevron.left.slash.chevron.right")
                                
                                CategoryPerformanceCard(category: "자료구조", percent: 0.75, color: .purple, icon: "doc.on.clipboard")
                                
                                CategoryPerformanceCard(category: "네트워크", percent: 0.6, color: .red, icon: "arrow.left.arrow.right")
                            }
                        }
                        
                        // MARK: 취약 카테고리
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HStack {
                                Text("취약 카테고리")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .stroke(.gray.opacity(0.3), lineWidth: 10)
                                        .frame(width: 50, height: 50)
                                    
                                    Circle()
                                        .rotation(.degrees(-90))
                                        .trim(from: 0, to: weakCategoryPercent)
                                        .stroke(.red, style: .init(lineWidth: 10, lineCap: .round))
                                        .frame(width: 50, height: 50)
                                    
                                    Text("\(Int(weakCategoryPercent * 100))%")
                                        .font(.caption)
                                        .bold()
                                }
                                .clipShape(.circle)
                            }
                            
                            HStack(spacing: 12) {
                                WeakCategoryCard(title: "네트워크 (60%)", subtitle: "TCP/IP 프로토콜 관련 문제에 취약", percent: 0.6)
                            }
                            
                            Button{
                                
                            } label: {
                                Text("맞춤 학습 시작")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Group {
                    // MARK: 오답 노트
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("오답 노트")
                                .font(.callout)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Text("모두 보기")
                                    .font(.subheadline)
                            }
                        }
                        
                        VStack(spacing: 10) {
                            WrongNoteCard(question: "TCP와 UDP의 차이점으로 올바르지 않은 것은?", category: "네트워크", date: "오늘 추가됨")
                            
                            WrongNoteCard(question: "HTTP 상태 코드 401과 403의 차이점은?", category: "네트워크", date: "어제 추가됨")
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
            .background(.gray.opacity(0.1))
        }
    }
}


struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var background: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black)
            
            HStack(spacing: 10) {
                Text(value)
                    .font(.title2)
                    .bold()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(background.opacity(0.5), lineWidth: 3)
        )
        .cornerRadius(8)
    }
}

struct CategoryPerformanceCard: View {
    let category: String
    let percent: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.1))
                .cornerRadius(5)
            
            Text(category)
                .font(.footnote)
                .fontWeight(.semibold)
            
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: 55, height: 55)
                
                Circle()
                    .rotation(.degrees(-90))
                    .trim(from: 0, to: percent)
                    .stroke(color, style: .init(lineWidth: 10, lineCap: .round))
                    .frame(width: 55, height: 55)
                
                Text("\(Int(percent * 100))%")
                    .font(.caption)
                    .bold()
            }
            .clipShape(.circle)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(color.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.02), lineWidth: 3)
        )
        .cornerRadius(12)
    }
}

struct WeakCategoryCard: View {
    let title: String
    let subtitle: String
    let percent: Double
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .fontWeight(.medium)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black.opacity(0.6))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.red.opacity(0.1), lineWidth: 3)
        )
        .cornerRadius(12)
    }
}

struct WrongNoteCard: View {
    let question: String
    let category: String
    let date: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: "xmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .padding(8)
                .background(.red.opacity(0.1))
                .cornerRadius(5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(question)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("\(category) • \(date)")
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.2), lineWidth: 3)
        )
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
}
