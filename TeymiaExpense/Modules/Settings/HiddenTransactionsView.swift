import SwiftUI
import SwiftData

struct HiddenTransactionsRowView: View {
    @Query(filter: #Predicate<Transaction> { $0.isHidden == true })
    private var hiddenTransactions: [Transaction]
    
    private var hiddenCount: Int {
        hiddenTransactions.count
    }
    
    var body: some View {
        ZStack {
            NavigationLink(destination: HiddenTransactionsView()) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Label(
                    title: { Text("Hidden Transactions") },
                    icon: {
                        Image("eye.crossed")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.primary)
                    }
                )
                
                Spacer()
                
                if hiddenCount > 0 {
                    Text("\(hiddenCount)")
                        .foregroundStyle(.secondary)
                }
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
    }
}

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
        Group {
            if hiddenTransactions.isEmpty {
                emptyStateView
            } else {
                transactionsList
            }
        }
        .navigationTitle("Hidden Transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !hiddenTransactions.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Unhide All") {
                        unhideAllTransactions()
                    }
                }
            }
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
                .presentationDragIndicator(.visible)
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
        ContentUnavailableView {
            Label {
                Text("No Hidden Transactions")
            } icon: {
                Image("eye.crossed")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.secondary)
            }
        } description: {
            Text("Transactions you hide will appear here")
        }
    }
    
    // MARK: - Transactions List
    
    @ViewBuilder
    private var transactionsList: some View {
        List {
            ForEach(sortedDates, id: \.self) { date in
                Section {
                    ForEach(groupedTransactions[date] ?? []) { transaction in
                        HiddenTransactionRow(
                            transaction: transaction,
                            onTap: { editingTransaction = transaction },
                            onUnhide: { unhideTransaction(transaction) },
                            onDelete: {
                                transactionToDelete = transaction
                                showingDeleteAlert = true
                            }
                        )
                    }
                } header: {
                    Text(formatDate(date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
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
    let onUnhide: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        TransactionRowView(transaction: transaction)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .swipeActions {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image("trash.swipe")
                }
                .tint(.red)
                
                Button {
                    onUnhide()
                } label: {
                    Image("eye.swipe")
                }
                .tint(.blue)
            }
    }
}
