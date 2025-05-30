//
//  DashboardView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

// MARK: PeriodFilter
enum PeriodFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case thisWeek = "이번 주"
    case thisMonth = "이번 달"

    var id: String { rawValue }
}

//MARK: WrongNoteCategory
enum WrongNoteCategory: String, CaseIterable, Identifiable {
    case all = "전체 카테고리"
    case swift = "Swift"
    case dataStructure = "자료구조"
    case algorithm = "알고리즘"
    case network = "네트워크"
    case database = "데이터베이스"
    
    var id: String { self.rawValue }
}

// MARK: WrongNote
struct WrongNote: Identifiable {
    var id = UUID()
    var question: String
    var category: String
    var date: String
    var accuracy: Int
}

// MARK: mockNotes
let mockNotes: [WrongNote] = [
    WrongNote(question: "TCP와 UDP의 차이점으로 올바르지 않은 것은?", category: "네트워크", date: "오늘", accuracy: 75),
    WrongNote(question: "HTTP 상태 코드 401과 403의 차이점은?", category: "네트워크", date: "어제", accuracy: 62),
    WrongNote(question: "SwiftUI에서 상태(State) 변수 선언 방식은?", category: "Swift", date: "5월 10일", accuracy: 48),
    WrongNote(question: "Big-O에서 O(n log n)의 정렬 알고리즘?", category: "알고리즘", date: "5월 8일", accuracy: 55)
]

// MARK: DashboardView
struct DashboardView: View {
    @State private var selectedPeriod: PeriodFilter = .all
    @State private var selectedCategory: WrongNoteCategory = .all
    @State private var searchText: String = ""
    
    private var weakCategoryPercent = 0.6
    
    let dashboardData: [String] = []
    
    var body: some View {
        if dashboardData.isEmpty {
            EmptyDashboardView()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
        } else {
            ScrollView {
                StatisticsAndPerformanceSection(
                    selectedPeriod: $selectedPeriod,
                    weakCategoryPercent: weakCategoryPercent
                )
                
                WrongNotesDashboardSection(
                    selectedCategory: $selectedCategory,
                    searchText: $searchText,
                    notes: mockNotes
                )
            }
            .padding()
            .padding(.top, 50)
            .background(Color.adaptiveGrayOverlay)
            .ignoresSafeArea(edges: [.top])
        }
    }
}

// MARK: StatisticsAndPerformanceSection
struct StatisticsAndPerformanceSection: View {
    @Binding var selectedPeriod: PeriodFilter
    let weakCategoryPercent: Double

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 18) {
                DashboardHeader(selectedPeriod: $selectedPeriod)
                QuizStatisticsCards()
                CategoryPerformanceCards()
                WeakCategoryView(weakCategoryPercent: weakCategoryPercent)
            }
        }
        .padding()
        .background(Color.dynamicBackground)
        .cornerRadius(16)
        .shadow(color: Color.adaptiveGrayOverlay, radius: 5, x: 0, y: 2)
    }
}

// MARK: DashboardHeader
struct DashboardHeader: View {
    @Binding var selectedPeriod: PeriodFilter

    var body: some View {
        HStack {
            Text("대시보드")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Menu {
                Picker("기간 선택", selection: $selectedPeriod) {
                    ForEach(PeriodFilter.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
            } label: {
                HStack {
                    Text(selectedPeriod.rawValue)
                        .font(.caption)
                        .foregroundColor(Color.adaptiveBlue)

                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(Color.adaptiveBlue)
                }
            }
        }
    }
}

// MARK: QuizStatisticsCards
struct QuizStatisticsCards: View {
    var body: some View {
        HStack(spacing: 16) {
            StatCard(title: "퀴즈 시도 횟수", value: "32", background: Color.adaptiveBlue.opacity(0.1))
            StatCard(title: "평균 정답률", value: "78%", subtitle: "↑ 5%", background: Color.green.opacity(0.1))
        }
    }
}

struct CategoryPerformanceCards: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 성과")
                .font(.callout)
                .fontWeight(.bold)
            
            HStack(spacing: 12) {
                CategoryPerformanceCard(category: "Swift", percent: 0.9, color: Color.adaptiveBlue, icon: "chevron.left.slash.chevron.right")
                CategoryPerformanceCard(category: "자료구조", percent: 0.75, color: .purple, icon: "doc.on.clipboard")
                CategoryPerformanceCard(category: "네트워크", percent: 0.6, color: Color.adaptiveRed, icon: "arrow.left.arrow.right")
            }
        }
    }
}

// MARK: WeakCategoryView
struct WeakCategoryView: View {
    let weakCategoryPercent: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("취약 카테고리")
                    .font(.callout)
                    .fontWeight(.bold)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(.secondary.opacity(0.3), lineWidth: 10)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .rotation(.degrees(-90))
                        .trim(from: 0, to: weakCategoryPercent)
                        .stroke(Color.adaptiveRed, style: .init(lineWidth: 10, lineCap: .round))
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
                    .background(Color.adaptiveBlue)
                    .foregroundColor(Color.dynamicBackground)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: WrongNotesDashboardSection
struct WrongNotesDashboardSection: View {
    @Binding var selectedCategory: WrongNoteCategory
    @Binding var searchText: String
    let notes: [WrongNote]

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 12) {
                WrongNotesHeader(selectedCategory: $selectedCategory)
                WrongNotesSearchBar(searchText: $searchText)
                WrongNotesList(notes: notes)
            }
        }
        .padding()
        .background(Color.dynamicBackground)
        .cornerRadius(16)
        .shadow(color: Color.adaptiveGrayOverlay, radius: 5, x: 0, y: 2)
    }
}

// MARK: WrongNotesHeader
struct WrongNotesHeader: View {
    @Binding var selectedCategory: WrongNoteCategory

    var body: some View {
        HStack {
            Text("오답 노트")
                .font(.callout)
                .fontWeight(.bold)
            
            Spacer()
            
            Menu {
                Picker("카테고리 선택", selection: $selectedCategory) {
                    ForEach(WrongNoteCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory.rawValue)
                        .font(.caption)
                        .foregroundColor(Color.adaptiveBlue)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(Color.adaptiveBlue)
                }
            }
        }
    }
}

// MARK: WrongNotesSearchBar
struct WrongNotesSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("검색어를 입력하세요", text: $searchText)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: WrongNotesList
struct WrongNotesList: View {
    let notes: [WrongNote]

    var body: some View {
        ScrollView {
             VStack(spacing: 12) {
                 ForEach(notes) { note in
                     WrongNoteCard(
                         question: note.question,
                         category: note.category,
                         date: note.date,
                         accuracy: note.accuracy
                     )
                 }
             }
         }
    }
}

// MARK: StatCard
struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var background: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.primary)
            
            HStack(spacing: 10) {
                Text(value)
                    .font(.title2)
                    .bold()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.adaptiveGreen)
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

// MARK: CategoryPerformanceCard
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
                    .stroke(.secondary.opacity(0.3), lineWidth: 10)
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

// MARK: WeakCategoryCard
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
                .foregroundColor(Color.adaptiveRed)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary.opacity(0.6))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.adaptiveRed.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.adaptiveRed.opacity(0.1), lineWidth: 3)
        )
        .cornerRadius(12)
    }
}

// MARK: WrongNoteCard
struct WrongNoteCard: View {
    let question: String
    let category: String
    let date: String
    let accuracy: Int

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: "xmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveRed)
                .padding(8)
                .background(Color.adaptiveRed.opacity(0.1))
                .cornerRadius(5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(question)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                    Text("\(category) • \(date)")
                        .font(.caption2)
                        .foregroundColor(Color.primary.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.secondary.opacity(0.2), lineWidth: 3)
        )
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
}
