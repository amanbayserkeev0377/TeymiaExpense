import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
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
    @State private var showingImageCropper = false
    @State private var showingPhotoPicker = false
    @State private var imageForCropping: UIImage?

    
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
                        name: accountName.isEmpty ? (isEditMode ? editingAccount?.name ?? "account_name".localized : "account_name".localized) : accountName,
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
                        TextField("account_name".localized, text: $accountName)
                            .autocorrectionDisabled()
                            .focused($isAccountNameFocused)
                            .submitLabel(.next)
                            .onSubmit {
                                isAccountNameFocused = false
                                isInitialBalanceFocused = true
                            }
                            .fontDesign(.rounded)

                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                accountName = ""
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.secondary.opacity(0.5))
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.plain)
                        .opacity(accountName.isEmpty ? 0 : 1)
                        .scaleEffect(accountName.isEmpty ? 0.001 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: accountName.isEmpty)
                        .disabled(accountName.isEmpty)
                    }
                    .contentShape(Rectangle())
                    
                    HStack {
                        TextField(isEditMode ? "current_balance".localized : "initial_balance".localized, text: $initialBalance)
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
                
                CardDesignSelectionSection(
                    selectedDesignType: $selectedDesignType,
                    selectedDesignIndex: $selectedDesignIndex,
                    customImage: $customImage,
                    imageForCropping: $imageForCropping,
                    showingPhotoPicker: $showingPhotoPicker
                )
                
                AccountIconSection(selectedIcon: $selectedIcon)
                
                Section {
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
                            
                            Text("currency".localized)
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
            }
            .navigationTitle(isEditMode ? "edit_account" : "add_account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CloseToolbarButton()

                ConfirmationToolbarButton(
                    action: {
                        isEditMode ? updateAccount() : saveAccount()
                    },
                    isDisabled: !canSave
                )
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
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker { image in
                imageForCropping = image
                showingPhotoPicker = false
            }
        }
        .fullScreenCover(isPresented: $showingImageCropper) {
            if let image = imageForCropping {
                ImageCropperView(originalImage: image) { croppedImage in
                    customImage = croppedImage
                    selectedDesignIndex = -1
                    imageForCropping = nil
                    showingImageCropper = false
                }
            }
        }
        .onChange(of: imageForCropping) { oldValue, newValue in
            if newValue != nil {
                showingImageCropper = true
            }
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
        if selectedCurrency == nil {
            let userCode = CurrencyService.detectUserCurrency()
            selectedCurrency = CurrencyDataProvider.findCurrency(by: userCode)
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
            currencyCode: currency.code,
            designIndex: finalDesignIndex,
            customIcon: selectedIcon,
            designType: selectedDesignType,
            customImageData: imageData,
            sortOrder: accounts.count
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
        account.currencyCode = currency.code
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
