import SwiftUI
import SwiftData

struct HiddenTransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    
    @Query(filter: #Predicate<Transaction> { $0.isHidden == true })
    private var hiddenTransactions: [Transaction]
    
    @Query private var currencies: [Currency]
    
    @State private var showingDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    @State private var editingTransaction: Transaction?
    
    // Group transactions by date
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: hiddenTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    var body: some View {
        List {
            if hiddenTransactions.isEmpty {
                emptyStateView
            } else {
                transactionsList
                    .padding(.horizontal, 15)
            }
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
        .alert("Delete Transaction?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                transactionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let transaction = transactionToDelete {
                    deleteTransaction(transaction)
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image("search.question")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(.secondary)
            
            Text("No Hidden Transactions")
                .font(.headline)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Transactions List
    
    @ViewBuilder
    private var transactionsList: some View {
        LazyVStack(spacing: 20) {
            ForEach(sortedDates, id: \.self) { date in
                GlassDayTransactionsView(
                    date: date,
                    transactions: groupedTransactions[date] ?? [],
                    userPreferences: userPreferences,
                    currencies: currencies,
                    onEditTransaction: { editingTransaction = $0 },
                    onHideTransaction: { unhideTransaction($0) },
                    onDeleteTransaction: {
                        transactionToDelete = $0
                        showingDeleteAlert = true
                    }
                )
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Date Formatting
        
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Actions
    
    private func unhideTransaction(_ transaction: Transaction) {
        withAnimation {
            transaction.isHidden = false
            try? modelContext.save()
        }
    }
    
    private func unhideAllTransactions() {
        withAnimation {
            for transaction in hiddenTransactions {
                transaction.isHidden = false
            }
            try? modelContext.save()
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation {
            modelContext.delete(transaction)
            try? modelContext.save()
        }
        transactionToDelete = nil
    }
}

// MARK: - Hidden Transaction Row

struct HiddenTransactionRow: View {
    let transaction: Transaction
    let onTap: () -> Void
    
    var body: some View {
        TransactionRowView(transaction: transaction)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
    }
}
