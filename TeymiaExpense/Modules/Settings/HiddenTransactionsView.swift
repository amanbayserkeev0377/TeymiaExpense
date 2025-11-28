import SwiftUI
import SwiftData

struct HiddenTransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserPreferences.self) private var userPreferences
    
    @Query(filter: #Predicate<Transaction> { $0.isHidden == true })
    private var hiddenTransactions: [Transaction]
    
    @State private var isEditMode = false
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    @State private var pendingDeleteAction: (() -> Void)?
    @State private var editingTransaction: Transaction?
    @State private var selectedTransactions: Set<Transaction> = []
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: hiddenTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    var body: some View {
        List(selection: $selectedTransactions) {
            if hiddenTransactions.isEmpty {
                ContentUnavailableView(
                    "No Hidden Transactions",
                    systemImage: "eye.slash",
                    description: Text("Hidden transactions will appear here")
                )
                .listRowBackground(Color.clear)
            } else {
                transactionsList
            }
        }
        .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.mainGroupBackground)
        .navigationTitle("hidden_transactions".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditDoneToolbarButton(isEditMode: $isEditMode) {
                selectedTransactions = []
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isEditMode {
                HStack(spacing: 12) {
                    Button {
                        if selectedTransactions.count < hiddenTransactions.count {
                            selectedTransactions = Set(hiddenTransactions)
                        } else {
                            selectedTransactions = []
                        }
                    } label: {
                        Text(selectedTransactions.count < hiddenTransactions.count ? "select_all".localized : "deselect_all".localized)
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        confirmUnhideSelectedTransactions()
                    } label: {
                        Text("unhide".localized + " (\(selectedTransactions.count))")
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedTransactions.isEmpty)
                    
                    Button(role: .destructive) {
                        confirmDeleteSelectedTransactions()
                    } label: {
                        Text("delete".localized + " (\(selectedTransactions.count))")
                            .padding(4)
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedTransactions.isEmpty)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 2, opaque: false)
                }
            }
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(editingTransaction: transaction)
        }
        .alert("delete_transaction_alert".localized, isPresented: $showingDeleteAlert) {
            Button("cancel".localized, role: .cancel) {
                pendingDeleteAction = nil
            }
            Button("delete".localized, role: .destructive) {
                pendingDeleteAction?()
                pendingDeleteAction = nil
            }
        } message: {
            Text(deleteAlertMessage)
        }
    }
    
    // MARK: - Transactions List
    
    @ViewBuilder
    private var transactionsList: some View {
        ForEach(sortedDates, id: \.self) { date in
            Section {
                ForEach(groupedTransactions[date] ?? [], id: \.id) { transaction in
                    TransactionRowView(transaction: transaction)
                        .tag(transaction)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isEditMode {
                                editingTransaction = transaction
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                confirmDeleteTransaction(transaction)
                            } label: {
                                Label("", image: "trash.swipe")
                            }
                            .tint(.red)
                            
                            Button {
                                unhideTransaction(transaction)
                            } label: {
                                Label("", image: "eye.swipe")
                            }
                            .tint(.gray)
                        }
                }
                .listRowBackground(Color.mainRowBackground)
            } header: {
                Text(formatDate(date))
            }
        }
    }
    
    // MARK: - Date Formatting
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "today".localized
        } else if calendar.isDateInYesterday(date) {
            return "yesterday".localized
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale.current
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
    
    private func unhideTransactions(_ transactions: [Transaction]) {
        withAnimation {
            transactions.forEach { $0.isHidden = false }
            try? modelContext.save()
            selectedTransactions = []
        }
    }
    
    private func deleteTransactions(_ transactions: [Transaction]) {
        withAnimation {
            transactions.forEach { modelContext.delete($0) }
            try? modelContext.save()
            selectedTransactions = []
        }
    }
    
    private func confirmUnhideSelectedTransactions() {
        guard !selectedTransactions.isEmpty else { return }
        unhideTransactions(Array(selectedTransactions))
    }
    
    private func confirmDeleteSelectedTransactions() {
        guard !selectedTransactions.isEmpty else { return }
        
        let transactionsToDelete = Array(selectedTransactions)
        
        if transactionsToDelete.count == 1 {
            deleteAlertMessage = "transaction_delete_message_single".localized
        } else {
            deleteAlertMessage = String(format: "transaction_delete_message_multiple".localized, transactionsToDelete.count)
        }
        
        pendingDeleteAction = {
            self.deleteTransactions(transactionsToDelete)
        }
        showingDeleteAlert = true
    }
    
    private func confirmDeleteTransaction(_ transaction: Transaction) {
        selectedTransactions = [transaction]
        confirmDeleteSelectedTransactions()
    }
}
