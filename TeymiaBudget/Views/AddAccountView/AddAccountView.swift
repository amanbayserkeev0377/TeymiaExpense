import SwiftUI
import SwiftData

// MARK: - Add Account View с preview карточки
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
            ScrollView {
                VStack(spacing: 24) {
                    // Card Preview
                    cardPreviewSection
                    
                    // Form sections
                    VStack(spacing: 20) {
                        accountNameSection
                        colorSelectionSection
                        iconSelectionSection
                        accountTypeSection
                        currencySection
                        balanceSection
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 0)
            }
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
    
    // MARK: - Card Preview Section
    private var cardPreviewSection: some View {
        VStack {
            AccountCardPreview(
                name: accountName,
                balance: initialBalance,
                accountType: selectedAccountType,
                color: selectedColor,
                icon: selectedIcon,
                currencyCode: selectedCurrency?.code ?? "USD"
            )
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Account Name Section
    private var accountNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Name")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Enter account name", text: $accountName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
    }
    
    // MARK: - Color Selection Section
    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Color")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<AccountColors.colors.count, id: \.self) { index in
                        colorButton(index: index)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
    
    // MARK: - Icon Selection Section
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Icon")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button {
                showingIconSelection = true
            } label: {
                HStack {
                    Image(selectedIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(selectedColor)
                    
                    Text("Tap to change icon")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Account Type Section
    private var accountTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Type")
                .font(.headline)
                .foregroundColor(.primary)
            
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
                        .frame(width: 24, height: 24)
                        .foregroundStyle(selectedColor)
                    
                    Text(selectedAccountType.displayName)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image("chevron.up.down")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                )
            }
        }
    }
    
    // MARK: - Currency Section
    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currency")
                .font(.headline)
                .foregroundColor(.primary)
            
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
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(currency.code) - \(currency.name)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Symbol: \(currency.symbol)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                        
                        Text("Select Currency")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Balance Section
    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Initial Balance")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text(selectedCurrency?.symbol ?? "$")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                
                TextField("0.00", text: $initialBalance)
                    .font(.title3)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.1))
            )
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
    
    // Доступные иконки для аккаунтов
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
