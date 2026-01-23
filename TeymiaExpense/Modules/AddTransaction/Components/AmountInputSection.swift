import SwiftUI

struct AmountInputSection: View {
    let type: TransactionType
    let currencySymbol: String
    let toCurrencySymbol: String
    
    let fromCurrencyCode: String
    let toCurrencyCode: String?
    
    @Binding var amount: String
    @Binding var targetAmount: String
    @Binding var note: String
    
    @FocusState.Binding var isAmountFocused: Bool
    @FocusState private var isTargetFocused: Bool

    var body: some View {
            VStack(spacing: 15) {
                HStack {
                    TextField(currencySymbol, text: $amount)
                        .autocorrectionDisabled()
                        .focused($isAmountFocused)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(type.color)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .onChange(of: amount) { oldValue, newValue in
                            amount = filterAmount(newValue, old: oldValue)
                            
                            if type == .transfer && isAmountFocused {
                                autoCalculateTarget(from: amount)
                            }
                        }
                }
                .contentShape(Rectangle())
                
                if type == .transfer {
                    Divider()
                    HStack {
                        Text(toCurrencySymbol)
                            .font(.title2).bold()
                            .foregroundStyle(.secondary)
                        
                        TextField("0", text: $targetAmount)
                            .focused($isTargetFocused)
                            .font(.title2).bold()
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .onChange(of: targetAmount) { oldValue, newValue in
                                targetAmount = filterAmount(newValue, old: oldValue)
                            }
                    }
                }

                HStack {
                    Image("note")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.primary)
                    
                    TextField("note".localized, text: $note)
                        .fontDesign(.rounded)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            note = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondary.opacity(0.5))
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .opacity(note.isEmpty ? 0 : 1)
                    .scaleEffect(note.isEmpty ? 0.001 : 1)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: note.isEmpty)
                    .disabled(note.isEmpty)
                }
                .contentShape(Rectangle())
            }
    }
    
    private func filterAmount(_ value: String, old: String) -> String {
        let separator = Locale.current.decimalSeparator ?? "."
        let altSeparator = (separator == "." ? "," : ".")
        var filtered = value.replacingOccurrences(of: altSeparator, with: separator)
        let allowedCharacters = "0123456789" + separator
        filtered = filtered.filter { allowedCharacters.contains($0) }
        return filtered.components(separatedBy: separator).count > 2 ? old : filtered
    }

    private func autoCalculateTarget(from value: String) {
        let clean = value.replacingOccurrences(of: ",", with: ".")
        if let dec = Decimal(string: clean) {
            let converted = CurrencyService.shared.convert(
                dec,
                from: fromCurrencyCode,
                to: toCurrencyCode ?? "USD"
            )
            
            let rounded = roundDecimal(converted, scale: 2)
            targetAmount = CurrencyFormatter.formatForEditing(rounded)
        }
    }

    private func roundDecimal(_ value: Decimal, scale: Int) -> Decimal {
        var localValue = value
        var rounded = Decimal()
        NSDecimalRound(&rounded, &localValue, scale, .bankers)
        return rounded
    }
}
