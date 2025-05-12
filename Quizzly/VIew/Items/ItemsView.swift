//
//  ItemsView.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import SwiftUI
import SwiftData

struct ItemsView: View {
    
    @StateObject private var viewModel: ItemsViewModel
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var newItemName: String = ""
    
    @State private var itemToUpdate: Item?
    @State private var updatedItemName: String = ""
    @State private var showingUpdateAlert = false
    
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ItemsViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("새 항목 이름", text: $newItemName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { addItem() }
                    
                    Button("추가") { addItem() }
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name).font(.headline)
                                Text(item.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            Button {
                                itemToUpdate = item
                                updatedItemName = item.name
                                showingUpdateAlert = true
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("내 항목 목록")
            .alert("이름 수정", isPresented: $showingUpdateAlert, presenting: itemToUpdate) { item in
                TextField("새 이름", text: $updatedItemName)
                Button("수정") {
                    if let currentItem = itemToUpdate {
                        viewModel.updateItem(item: currentItem, newName: updatedItemName)
                    }
                }
                Button("취소", role: .cancel) {
                    itemToUpdate = nil
                    updatedItemName = ""
                }
            } message: { item in
                Text("'\(item.name)'의 새 이름을 입력하세요.")
            }
        }
    }
    
    private func addItem() {
        viewModel.addItem(name: newItemName)
        newItemName = "" // 입력 필드 초기화
    }
    
    private func deleteItems(offsets: IndexSet) {
        viewModel.deleteItems(at: offsets)
    }
}
