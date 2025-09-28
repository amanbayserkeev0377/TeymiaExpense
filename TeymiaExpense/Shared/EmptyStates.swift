import SwiftUI

struct TransactionEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("list.empty")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.secondary)
            
            Text("No Transactions")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct CategoryEmptyStateView: View {
    let isGroups: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(isGroups ? "box.question" : "drawer.empty")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.secondary)
            
            Text(isGroups ? "No Groups" : "No Categories")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
