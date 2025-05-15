//
//  SymbolPicker.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/15/25.
//

import SwiftUI
import SymbolPicker

struct SymbolPickerButton: View {
    @Binding var categoryIconName: String
    @Binding var isPresented: Bool
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Text("아이콘 선택")
                    .sheet(isPresented: $isPresented) {
                        SymbolPicker(symbol: $categoryIconName)
                    }
                Spacer()
                Image(systemName: categoryIconName)
                    .scaledToFit()
                    .font(.system(size: 24))
            }
        }
        .tint(.primary)
    }
}
