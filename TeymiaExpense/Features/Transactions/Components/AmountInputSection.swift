import SwiftUI

struct AmountInputSection: View {
    @Binding var amount: String
    @Binding var selectedTransactionType: TransactionType
    @FocusState.Binding var isAmountFieldFocused: Bool
    let currencySymbol: String
    
    var body: some View {
        Section {
            HStack {
                TextField("\(currencySymbol)", text: $amount)
                    .autocorrectionDisabled()
                    .focused($isAmountFieldFocused)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
            }
            .contentShape(Rectangle())
            
            CustomSegmentedControl(
                options: TransactionType.allCases,
                titles: TransactionType.allCases.map { $0.displayName },
                icons: TransactionType.allCases.map { $0.customIconName },
                gradients: TransactionType.allCases.map { $0.backgroundGradient },
                selection: $selectedTransactionType
            )
        }
        .listRowBackground(Color.mainRowBackground)
    }
}
