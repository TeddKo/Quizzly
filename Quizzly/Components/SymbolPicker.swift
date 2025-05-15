//
//  SymbolPicker.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/15/25.
//

import SwiftUI
import SFSymbolsPicker

struct SymbolPicker: View {
    @Binding var categoryIconName: String
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            Text("아이콘 선택")
                .sheet(isPresented: $isPresented) {
                    SymbolsPicker(selection: $categoryIconName, title: "Pick a symbol", autoDismiss: true)
                }
            Spacer()
            Image(systemName: categoryIconName)
                .scaledToFit()
                .font(.system(size: 24))
        }
    }
}
