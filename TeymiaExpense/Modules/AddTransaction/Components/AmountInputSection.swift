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

private extension TransactionType {
    var darkColor: Color {
        switch self {
        case .expense: return Color(#colorLiteral(red: 0.8, green: 0.1, blue: 0.1, alpha: 1))
        case .income: return Color(#colorLiteral(red: 0.0, green: 0.6431372549, blue: 0.5490196078, alpha: 1))
        case .transfer: return Color(#colorLiteral(red: 0.1490196078, green: 0.4666666667, blue: 0.6784313725, alpha: 1))
        }
    }
    
    var lightColor: Color {
        switch self {
        case .expense: return Color(#colorLiteral(red: 1, green: 0.3, blue: 0.3, alpha: 1))
        case .income: return Color(#colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1))
        case .transfer: return Color(#colorLiteral(red: 0.3568627451, green: 0.6588235294, blue: 0.9294117647, alpha: 1))
        }
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [lightColor, darkColor],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
