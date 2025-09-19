//import SwiftUI
//import SwiftData
//
//struct TransactionHistoryView: View {
//    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
//    
//    @State private var selectedDate = Date()
//    
//    var body: some View {
//        List {
//            Section {
//                DatePicker(
//                    "Select Date",
//                    selection: $selectedDate,
//                    displayedComponents: [.date]
//                )
//                .datePickerStyle(.graphical)
//                .labelsHidden()
//            }
//            
//            Section {
//                if transactionsForSelectedDate.isEmpty {
//                    VStack(spacing: 12) {
//                        Image(systemName: "calendar.badge.minus")
//                            .font(.system(size: 32))
//                            .foregroundStyle(.secondary)
//                        
//                        Text("No transactions on \(formatDate(selectedDate))")
//                            .font(.subheadline)
//                            .foregroundStyle(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 20)
//                    .listRowBackground(Color.clear)
//                } else {
//                    ForEach(transactionsForSelectedDate) { transaction in
//                        TransactionRowView(transaction: transaction)
//                    }
//                }
//            } header: {
//                if !transactionsForSelectedDate.isEmpty {
//                    Text("\(transactionsForSelectedDate.count) transactions")
//                        .textCase(.none)
//                }
//            }
//        }
//        .listStyle(.insetGrouped)
//        .navigationTitle("Transaction History")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    // MARK: - Computed Properties
//    private var transactionsForSelectedDate: [Transaction] {
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: selectedDate)
//        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
//        
//        return allTransactions.filter { transaction in
//            transaction.date >= startOfDay && transaction.date < endOfDay
//        }.sorted { $0.date > $1.date }
//    }
//    
//    // MARK: - Helper Methods
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//}
