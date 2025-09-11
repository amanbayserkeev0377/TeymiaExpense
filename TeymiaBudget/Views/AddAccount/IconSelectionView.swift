import SwiftUI

struct IconSelectionRow: View {
    let selectedIcon: String
    let selectedColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(selectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedColor)
                
                Text(selectedIcon.capitalized)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}

struct IconSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    
    private let availableIcons = [
        "cash", "bank", "credit_card", "savings",
        "wallet", "card", "coins", "banknote",
        "piggy_bank", "safe", "vault", "payment"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(availableIcons, id: \.self) { icon in
                        iconButton(icon: icon)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Select Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func iconButton(icon: String) -> some View {
        Button {
            selectedIcon = icon
            dismiss()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(selectedIcon == icon ? .blue : .gray.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(selectedIcon == icon ? .white : .primary)
                }
                
                Text(icon.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

