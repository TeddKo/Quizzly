import SwiftUI

struct CategoryCard: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text("문제 \(count)개")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .font(.title3)
                .foregroundColor(color)
                .padding(8)
                .cornerRadius(6)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.05), lineWidth: 2)
        )
        .cornerRadius(8)
    }
}