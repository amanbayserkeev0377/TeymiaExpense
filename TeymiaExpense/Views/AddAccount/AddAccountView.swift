import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var currencies: [Currency]
    
    @State private var accountName: String = ""
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedDesignType: AccountDesignType = .image
    @State private var selectedDesignIndex: Int = 0
    @State private var selectedIcon: String = "cash"
    
    @State private var showingCurrencySelection = false
    @State private var showingIconSelection = false
    @State private var showingCardDesignSelection = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Card Preview Section - with backdrop effect
                Section {
                    AccountCardPreview(
                        name: accountName.isEmpty ? "Account Name" : accountName,
                        balance: initialBalance.isEmpty ? "0" : initialBalance,
                        designType: selectedDesignType,
                        designIndex: selectedDesignIndex,
                        icon: selectedIcon,
                        currencyCode: selectedCurrency?.code ?? "USD"
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.smooth(duration: 0.4), value: selectedDesignType)
                    .animation(.smooth(duration: 0.4), value: selectedDesignIndex)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Account Details
                Section {
                    TextField("Account Name", text: $accountName)
                        .autocorrectionDisabled()
                    
                    HStack {
                        TextField("Initial Balance", text: $initialBalance)
                            .keyboardType(.decimalPad)
                        
                        Text(selectedCurrency?.symbol ?? "$")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    
                    // Card Design Selection
                    Button {
                        showingCardDesignSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            
                            Text("Card Design")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image("chevron.right")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    
                    // Icon Selection
                    Button {
                        showingIconSelection = true
                    } label: {
                        HStack {
                            Image(selectedIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.primary)
                            
                            Text("Icon")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image("chevron.right")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    // Currency Selection
                    Button {
                        showingCurrencySelection = true
                    } label: {
                        HStack {
                            Image(selectedCurrency != nil ? CurrencyService.shared.getCurrencyIcon(for: selectedCurrency!) : "questionmark.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.primary)
                            
                            Text("Currency")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Text(selectedCurrency?.code ?? "Select")
                                .foregroundStyle(.secondary)
                            
                            Image("chevron.right")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.gray.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveAccount()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            setupDefaults()
        }
        .sheet(isPresented: $showingCurrencySelection) {
            CurrencySelectionView(selectedCurrency: $selectedCurrency)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingIconSelection) {
            AccountIconSelectionView(selectedIcon: $selectedIcon)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingCardDesignSelection) {
            CardDesignSelectionView(
                selectedDesignType: $selectedDesignType,
                selectedDesignIndex: $selectedDesignIndex
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCurrency != nil
    }
    
    // MARK: - Helper Methods
    private func setupDefaults() {
        guard !currencies.isEmpty else { return }
        
        if selectedCurrency == nil {
            selectedCurrency = currencies.first { $0.isDefault } ?? currencies.first
        }
    }
    
    private func saveAccount() {
        guard let currency = selectedCurrency else { return }
        
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let balance = Decimal(string: initialBalance) ?? 0
        
        let account = Account(
            name: trimmedName,
            balance: balance,
            currency: currency,
            isDefault: false,
            designIndex: selectedDesignIndex,
            customIcon: selectedIcon,
            designType: selectedDesignType
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
