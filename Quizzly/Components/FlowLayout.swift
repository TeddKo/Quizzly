//
//  FlowLayout.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/13/25.
//

import SwiftUI

public struct HFlowLayout: Layout {
    var alignment: VerticalAlignment
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat
    
    public init(alignment: VerticalAlignment = .center, horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .horizontal
        return properties
    }
    
    public func makeCache(subviews: Subviews) -> CacheData {
        return CacheData()
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {
        let idealViewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        cache.idealViewSizes = idealViewSizes
        
        let (totalHeight, totalWidth, _) = calculateLayout(
            proposalWidth: proposal.width,
            subviewSizes: idealViewSizes
        )
        
        let finalWidth = proposal.width ?? totalWidth
        return CGSize(width: finalWidth, height: totalHeight)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {
        let viewSizes = cache.idealViewSizes ?? subviews.map { $0.sizeThatFits(.unspecified) }
        
        let (_, _, rows) = calculateLayout(
            proposalWidth: bounds.width,
            subviewSizes: viewSizes
        )
        
        var currentY = bounds.minY
        
        for row in rows {
            let rowHeight = row.maxHeight
            var currentX = bounds.minX
            
            for (index, size) in row.items {
                let subview = subviews[index]
                let yPosition: CGFloat
                
                switch alignment {
                case .top:
                    yPosition = currentY
                case .center:
                    yPosition = currentY + (rowHeight - size.height) / 2
                case .bottom:
                    yPosition = currentY + rowHeight - size.height
                default:
                    yPosition = currentY
                }
                
                let placeProposal = ProposedViewSize(width: size.width, height: size.height)
                subview.place(at: CGPoint(x: currentX, y: yPosition), anchor: .topLeading, proposal: placeProposal)
                currentX += size.width + horizontalSpacing
            }
            currentY += rowHeight + verticalSpacing
        }
    }
    
    private func calculateLayout(
        proposalWidth: CGFloat?,
        subviewSizes: [CGSize]
    ) -> (totalHeight: CGFloat, totalWidth: CGFloat, rows: [RowInfo]) {
        var rows: [RowInfo] = []
        var currentRowItems: [(index: Int, size: CGSize)] = []
        var currentRowWidth: CGFloat = 0
        var currentRowMaxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0
        
        let availableWidth = proposalWidth ?? .infinity
        
        for (index, size) in subviewSizes.enumerated() {
            let itemEffectiveWidth = currentRowItems.isEmpty ? size.width : horizontalSpacing + size.width
            
            if !currentRowItems.isEmpty && currentRowWidth + itemEffectiveWidth > availableWidth {
                totalHeight += currentRowMaxHeight
                if !rows.isEmpty { totalHeight += verticalSpacing }
                rows.append(RowInfo(items: currentRowItems, maxHeight: currentRowMaxHeight))
                maxLineWidth = max(maxLineWidth, currentRowWidth)
                
                currentRowItems = []
                currentRowWidth = 0
                currentRowMaxHeight = 0
            }
            
            currentRowItems.append((index, size))
            if currentRowItems.count > 1 {
                currentRowWidth += horizontalSpacing
            }
            currentRowWidth += size.width
            currentRowMaxHeight = max(currentRowMaxHeight, size.height)
        }
        
        if !currentRowItems.isEmpty {
            totalHeight += currentRowMaxHeight
            if !rows.isEmpty { totalHeight += verticalSpacing }
            rows.append(RowInfo(items: currentRowItems, maxHeight: currentRowMaxHeight))
            maxLineWidth = max(maxLineWidth, currentRowWidth)
        }
        
        if subviewSizes.isEmpty { return (0, 0, []) }
        return (totalHeight, maxLineWidth, rows)
    }
    
    struct RowInfo {
        var items: [(index: Int, size: CGSize)]
        var maxHeight: CGFloat
    }
    
    public struct CacheData {
        var idealViewSizes: [CGSize]?
    }
}

public struct VFLowLayout: Layout {
    var alignment: HorizontalAlignment
    var verticalSpacing: CGFloat
    var horizontalSpacing: CGFloat
    
    public init(alignment: HorizontalAlignment = .center, verticalSpacing: CGFloat = 8, horizontalSpacing: CGFloat = 8) {
        self.alignment = alignment
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }
    
    public func makeCache(subviews: Subviews) -> CacheData {
        return CacheData()
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {
        let idealViewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        cache.idealViewSizes = idealViewSizes
        
        let (totalWidth, totalHeight, _) = calculateLayout(
            proposalHeight: proposal.height,
            subviewSizes: idealViewSizes
        )
        
        let finalHeight = proposal.height ?? totalHeight
        return CGSize(width: totalWidth, height: finalHeight)
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {
        let viewSizes = cache.idealViewSizes ?? subviews.map { $0.sizeThatFits(.unspecified) }
        
        let (_, _, columns) = calculateLayout(
            proposalHeight: bounds.height,
            subviewSizes: viewSizes
        )
        
        var currentX = bounds.minX
        
        for column in columns {
            let columnWidth = column.maxWidth
            var currentY = bounds.minY
            
            for (index, size) in column.items {
                let subview = subviews[index]
                let xPosition: CGFloat
                
                switch alignment {
                case .leading:
                    xPosition = currentX
                case .center:
                    xPosition = currentX + (columnWidth - size.width) / 2
                case .trailing:
                    xPosition = currentX + columnWidth - size.width
                default:
                    xPosition = currentX
                }
                
                let placeProposal = ProposedViewSize(width: size.width, height: size.height)
                subview.place(at: CGPoint(x: xPosition, y: currentY), anchor: .topLeading, proposal: placeProposal)
                currentY += size.height + verticalSpacing
            }
            currentX += columnWidth + horizontalSpacing
        }
    }
    
    private func calculateLayout(
        proposalHeight: CGFloat?,
        subviewSizes: [CGSize]
    ) -> (totalWidth: CGFloat, totalHeight: CGFloat, columns: [ColumnInfo]) {
        var columns: [ColumnInfo] = []
        var currentColumnItems: [(index: Int, size: CGSize)] = []
        var currentColumnHeight: CGFloat = 0
        var currentColumnMaxWidth: CGFloat = 0
        var totalWidth: CGFloat = 0
        var maxOverallHeight: CGFloat = 0
        
        let availableHeight = proposalHeight ?? .infinity
        
        for (index, size) in subviewSizes.enumerated() {
            let itemEffectiveHeight = currentColumnItems.isEmpty ? size.height : verticalSpacing + size.height
            
            if !currentColumnItems.isEmpty && currentColumnHeight + itemEffectiveHeight > availableHeight {
                totalWidth += currentColumnMaxWidth
                if !columns.isEmpty { totalWidth += horizontalSpacing }
                columns.append(ColumnInfo(items: currentColumnItems, maxWidth: currentColumnMaxWidth))
                maxOverallHeight = max(maxOverallHeight, currentColumnHeight)
                
                currentColumnItems = []
                currentColumnHeight = 0
                currentColumnMaxWidth = 0
            }
            
            currentColumnItems.append((index, size))
            if currentColumnItems.count > 1 {
                currentColumnHeight += verticalSpacing
            }
            currentColumnHeight += size.height
            currentColumnMaxWidth = max(currentColumnMaxWidth, size.width)
        }
        
        if !currentColumnItems.isEmpty {
            totalWidth += currentColumnMaxWidth
            if !columns.isEmpty { totalWidth += horizontalSpacing }
            columns.append(ColumnInfo(items: currentColumnItems, maxWidth: currentColumnMaxWidth))
            maxOverallHeight = max(maxOverallHeight, currentColumnHeight)
        }
        
        if subviewSizes.isEmpty { return (0, 0, []) }
        return (totalWidth, maxOverallHeight, columns)
    }
    
    struct ColumnInfo {
        var items: [(index: Int, size: CGSize)]
        var maxWidth: CGFloat
    }
    
    public struct CacheData {
        var idealViewSizes: [CGSize]?
    }
}


struct FlowItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    var text: String
}

struct Test: View {
    @State private var items: [FlowItem] = [
        "Apple", "Banana", "Orange", "Mango", "Pineapple", "Strawberry",
        "Blueberry", "Kiwi", "Lemon", "Grapes"
    ].map { FlowItem(text: $0) }
    
    @State private var editingItemId: UUID? = nil
    
    private let sampleNames = [
        "Watermelon", "Peach", "Nectarine", "Apricot", "Cherry", "Plum", "Avocado", "Cucumber",
        "Tomato", "Onion", "Carrot", "Broccoli", "Cauliflower", "Spinach", "Kale",
        "Bell Pepper", "Zucchini", "Squash", "Corn", "Beet", "Radish", "Pepper"
    ]
    
    private func addNewItem() {
        let newItemText = sampleNames.randomElement() ?? "New Item \(items.count + 1)"
        withAnimation {
            items.append(FlowItem(text: newItemText))
        }
    }
    
    private func deleteItem(id: UUID) {
        withAnimation {
            items.removeAll { $0.id == id }
            if editingItemId == id {
                editingItemId = nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    HFlowLayout(alignment: .center, horizontalSpacing: 10, verticalSpacing: 10) {
                        ForEach(items) { item in
                            itemView(item: item)
                        }
                        
                        Button(action: addNewItem) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                        .padding(10)
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity)
                
                Divider()
                
                ScrollView(.horizontal) {
                    VFLowLayout(alignment: .center, verticalSpacing: 10, horizontalSpacing: 10) {
                        ForEach(items) { item in
                            itemView(item: item)
                        }
                        
                        Button(action: addNewItem) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                        .padding(10)
                    }
                    .padding()
                }
                .frame(maxHeight: 250)
            }
            .padding()
            .navigationTitle("Flow Layout Demo")
            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
            .onTapGesture {
                if editingItemId != nil {
                    withAnimation {
                        editingItemId = nil
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func itemView(item: FlowItem) -> some View {
        let isEditingThisItem = (editingItemId == item.id)
        
        Text(item.text)
            .font(.headline)
            .padding()
            .background(isEditingThisItem ? Color.orange.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(radius: isEditingThisItem ? 5 : 0)
            .rotationEffect(isEditingThisItem ? Angle.degrees(2.0) : Angle.degrees(0))
            .animation(
                isEditingThisItem ? Animation.easeInOut(duration: 0.12).repeatForever(autoreverses: true) : .default,
                value: isEditingThisItem
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                withAnimation(.spring()) {
                    editingItemId = item.id
                }
            }
            .overlay(
                alignment: .topTrailing,
                content: {
                    if isEditingThisItem {
                        Button {
                            deleteItem(id: item.id)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                                .background(Circle().fill(Color.white).padding(2))
                        }
                        .offset(x: 10, y: -10)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            )
    }
}

#Preview {
    Test()
}
