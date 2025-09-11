import SwiftUI
import SwiftData

// MARK: - Add Account View с компактным Form
struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var currencies: [Currency]
    
    @State private var accountName: String = ""
    @State private var selectedAccountType: AccountType = .cash
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedColorIndex: Int = 0
    @State private var selectedIcon: String = "cash"
    
    @State private var showingCurrencySelection = false
    @State private var showingIconSelection = false
    
    var selectedColor: Color {
        AccountColors.color(at: selectedColorIndex)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AccountCardPreview(
                        name: accountName,
                        balance: initialBalance,
                        accountType: selectedAccountType,
                        color: selectedColor,
                        icon: selectedIcon,
                        currencyCode: selectedCurrency?.code ?? "USD"
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Account Name
                Section("Name") {
                    TextField("Enter account name", text: $accountName)
                        .autocorrectionDisabled()
                }
                .listRowBackground(Color.gray.opacity(0.1))
                
                // Color Selection
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<AccountColors.colors.count, id: \.self) { index in
                                colorButton(index: index)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Icon Selection
                Section("Icon") {
                    Button {
                        showingIconSelection = true
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
                .listRowBackground(Color.gray.opacity(0.1))
                
                // Account Type
                Section("Type") {
                    Menu {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Button {
                                selectedAccountType = type
                                selectedIcon = iconForAccountType(type)
                            } label: {
                                HStack {
                                    Image(iconForAccountType(type))
                                    Text(type.displayName)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(iconForAccountType(selectedAccountType))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(selectedColor)
                            
                            Text(selectedAccountType.displayName)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                    }
                }
                .listRowBackground(Color.gray.opacity(0.1))
                
                // Currency
                Section("Currency") {
                    Button {
                        showingCurrencySelection = true
                    } label: {
                        HStack {
                            if let currency = selectedCurrency {
                                Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                                
                                Text("\(currency.code) - \(currency.name)")
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            } else {
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, height: 24)
                                
                                Text("Select Currency")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.gray.opacity(0.1))
                
                // Initial Balance
                Section("Initial Balance") {
                    HStack {
                        Text(selectedCurrency?.symbol ?? "$")
                            .foregroundStyle(.secondary)
                            .font(.body)
                        
                        TextField("0.00", text: $initialBalance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            setupDefaults()
        }
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView(selectedCurrency: $selectedCurrency)
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
        .sheet(isPresented: $showingIconSelection) {
            IconSelectionView(selectedIcon: $selectedIcon)
                .presentationDetents([.medium])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .regularMaterial)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
    }
    
    // MARK: - Color Button
    private func colorButton(index: Int) -> some View {
        Button {
            selectedColorIndex = index
        } label: {
            ZStack {
                Circle()
                    .fill(AccountColors.color(at: index))
                    .frame(width: 50, height: 50)
                
                if selectedColorIndex == index {
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.isEmpty && selectedCurrency != nil
    }
    
    // MARK: - Helper Methods
    private func iconForAccountType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "cash"
        case .bankAccount: return "bank"
        case .creditCard: return "credit_card"
        case .savings: return "savings"
        }
    }
    
    private func setupDefaults() {
        selectedCurrency = currencies.first { $0.isDefault } ?? currencies.first
        selectedIcon = iconForAccountType(selectedAccountType)
    }
    
    private func saveAccount() {
        guard let currency = selectedCurrency else { return }
        
        let balance = Decimal(string: initialBalance) ?? 0
        
        let account = Account(
            name: accountName,
            type: selectedAccountType,
            balance: balance,
            currency: currency,
            isDefault: false,
            customColorHex: selectedColor.toHex(),
            customIcon: selectedIcon
        )
        
        modelContext.insert(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }
}

// MARK: - Icon Selection View
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
