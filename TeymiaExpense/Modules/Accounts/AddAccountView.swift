import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var currencies: [Currency]
    @Query private var accounts: [Account]
    
    // MARK: - Edit Mode Support
    private let editingAccount: Account?
    private var isEditMode: Bool { editingAccount != nil }
    
    @State private var accountName: String = ""
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedDesignType: AccountDesignType = .image
    @State private var selectedDesignIndex: Int = 0
    @State private var customImage: UIImage?
    @State private var selectedIcon: String = "cash"
    @State private var showingCurrencySelection = false
    @State private var showingIconSelection = false
    @State private var showingCardDesignSelection = false
    @State private var showingImageCropper = false
    @State private var imageForCropping: UIImage?
    @State private var shouldShowCropper = false

    
    @FocusState private var isAccountNameFocused: Bool
    @FocusState private var isInitialBalanceFocused: Bool
    
    // MARK: - Initializers
    init(editingAccount: Account? = nil) {
        self.editingAccount = editingAccount
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Card Preview Section
                Section {
                    AccountCardPreview(
                        name: accountName.isEmpty ? (isEditMode ? editingAccount?.name ?? "Account Name" : "Account Name") : accountName,
                        balance: initialBalance.isEmpty ? (isEditMode ? String(describing: editingAccount?.balance ?? 0) : "0") : initialBalance,
                        designType: selectedDesignType,
                        designIndex: selectedDesignIndex,
                        icon: selectedIcon,
                        currencyCode: selectedCurrency?.code ?? "USD",
                        customImage: customImage
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.smooth(duration: 0.4), value: selectedDesignType)
                    .animation(.smooth(duration: 0.4), value: selectedDesignIndex)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Account Details
                Section {
                    HStack {
                        TextField("Account Name", text: $accountName)
                            .autocorrectionDisabled()
                            .focused($isAccountNameFocused)
                            .submitLabel(.next)
                            .onSubmit {
                                isAccountNameFocused = false
                                isInitialBalanceFocused = true
                            }
                            .fontDesign(.rounded)
                        
                        if !accountName.isEmpty {
                            Button(action: {
                                accountName = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.secondary)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    
                    HStack {
                        TextField(isEditMode ? "Current Balance" : "Initial Balance", text: $initialBalance)
                            .keyboardType(.decimalPad)
                            .focused($isInitialBalanceFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                isInitialBalanceFocused = false
                            }
                            .fontDesign(.rounded)
                        
                        Text(selectedCurrency?.symbol ?? "$")
                            .foregroundStyle(.secondary)
                            .fontDesign(.rounded)
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.mainRowBackground)
                
                Section {
                    // Card Design Selection
                    Button {
                        showingCardDesignSelection = true
                    } label: {
                        HStack {
                            Image(selectedDesignType == .image ? "photo" : "palette")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.primary)
                            
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
                            Image(selectedCurrency != nil ? CurrencyService.getCurrencyIcon(for: selectedCurrency!) : "questionmark.circle")
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
                .listRowBackground(Color.mainRowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(Color.mainBackground.ignoresSafeArea())
            .navigationTitle(isEditMode ? "Edit Account" : "Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditMode ? updateAccount() : saveAccount()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        isAccountNameFocused = false
                        isInitialBalanceFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
        .onAppear {
            setupInitialValues()
            if !isEditMode {
                DispatchQueue.main.async {
                    isAccountNameFocused = true
                }
            }
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
            if imageForCropping != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingImageCropper = true
                }
            }
        } content: {
            CardDesignSelectionView(
                selectedDesignType: $selectedDesignType,
                selectedDesignIndex: $selectedDesignIndex,
                customImage: $customImage,
                shouldShowCropper: $shouldShowCropper,
                imageForCropping: $imageForCropping
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showingImageCropper) {
            if let image = imageForCropping {
                ImageCropperView(originalImage: image) { croppedImage in
                    customImage = croppedImage
                    selectedDesignIndex = -1
                    imageForCropping = nil
                }
            }
        }
        .onChange(of: imageForCropping) { oldValue, newValue in
            print("📸 imageForCropping changed: \(newValue != nil)")
        }
        .onChange(of: showingImageCropper) { oldValue, newValue in
            print("🎬 showingImageCropper: \(newValue)")
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCurrency != nil
    }
    
    // MARK: - Setup Methods
    private func setupInitialValues() {
        if let account = editingAccount {
            setupEditMode(with: account)
        } else {
            setupCreateMode()
        }
    }
    
    private func setupEditMode(with account: Account) {
        accountName = account.name
        initialBalance = String(describing: account.balance)
        selectedCurrency = account.currency
        selectedDesignType = account.designType
        selectedDesignIndex = account.designIndex
        selectedIcon = account.customIcon
        
        // Load custom image if exists
        if let imageData = account.customImageData {
            customImage = UIImage(data: imageData)
        }
    }
    
    private func setupCreateMode() {
        // Set defaults for new account
        guard !currencies.isEmpty else { return }
        
        if selectedCurrency == nil {
            selectedCurrency = currencies.first { $0.isDefault } ?? currencies.first
        }
    }
    
    // MARK: - Save Account
    private func saveAccount() {
        guard let currency = selectedCurrency else { return }
        
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let balance = Decimal(string: initialBalance) ?? 0
        
        // Convert UIImage to Data if custom image exists
        var imageData: Data?
        var finalDesignIndex = selectedDesignIndex
        
        if let image = customImage {
            imageData = image.jpegData(compressionQuality: 0.8)
            finalDesignIndex = -1 // Special index for custom image
        }
        
        let account = Account(
            name: trimmedName,
            balance: balance,
            currency: currency,
            isDefault: false,
            designIndex: finalDesignIndex,
            customIcon: selectedIcon,
            designType: selectedDesignType,
            customImageData: imageData
        )
        
        modelContext.insert(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }

    // MARK: - Update Account
    private func updateAccount() {
        guard let account = editingAccount,
              let currency = selectedCurrency else { return }
        
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let newBalance = Decimal(string: initialBalance) ?? 0
        
        // Convert UIImage to Data if custom image exists
        var imageData: Data?
        var finalDesignIndex = selectedDesignIndex
        
        if let image = customImage {
            imageData = image.jpegData(compressionQuality: 0.8)
            finalDesignIndex = -1 // Special index for custom image
        }
        
        // Update account properties
        account.name = trimmedName
        account.balance = newBalance
        account.currency = currency
        account.designIndex = finalDesignIndex
        account.customIcon = selectedIcon
        account.designType = selectedDesignType
        account.customImageData = imageData
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error updating account: \(error)")
        }
    }
}
