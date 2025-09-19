import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var currencies: [Currency]
    
    @State private var accountName: String = ""
    @State private var initialBalance: String = ""
    @State private var selectedCurrency: Currency?
    @State private var selectedImageIndex: Int = 0
    @State private var selectedIcon: String = "cash"
    
    @State private var showingCurrencySelection = false
    @State private var showingIconSelection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Image Selection Carousel
                    imageSelectionCarousel
                    
                    // Account Details Form
                    VStack(spacing: 16) {
                        accountDetailsSection
                        
                        accountSettingsSection
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
            }
            .background {
                GradientBackgroundView()
                    .ignoresSafeArea()
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        saveAccount()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .foregroundStyle(canSave ? .white : .gray)
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Image Selection Carousel
    @ViewBuilder
    private var imageSelectionCarousel: some View {
        VStack(spacing: 16) {
            Text("Choose Card Design")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(AccountImageData.images.enumerated()), id: \.element.id) { index, imageData in
                        Button {
                            selectedImageIndex = index
                        } label: {
                            AccountCardPreview(
                                name: accountName,
                                balance: initialBalance,
                                imageIndex: index,
                                icon: selectedIcon,
                                currencyCode: selectedCurrency?.code ?? "USD"
                            )
                            .frame(width: 260, height: 180)
                            .scaleEffect(selectedImageIndex == index ? 1.0 : 0.9)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        selectedImageIndex == index ? .white : .clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.2), value: selectedImageIndex)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 20)
            }
            .frame(height: 200)
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    // MARK: - Account Details Section
    @ViewBuilder
    private var accountDetailsSection: some View {
        VStack(spacing: 16) {
            // Account Name
            CustomInputField(
                title: "Account Name",
                text: $accountName,
                placeholder: "Enter account name"
            )
            
            // Initial Balance
            CustomInputField(
                title: "Initial Balance",
                text: $initialBalance,
                placeholder: "0.00",
                keyboardType: .decimalPad,
                suffix: selectedCurrency?.symbol ?? "$"
            )
        }
    }
    
    // MARK: - Account Settings Section
    @ViewBuilder
    private var accountSettingsSection: some View {
        VStack(spacing: 16) {
            // Icon Selection
            CustomSelectionRow(
                title: "Icon",
                value: "",
                icon: selectedIcon
            ) {
                showingIconSelection = true
            }
            
            // Currency Selection
            CustomSelectionRow(
                title: "Currency",
                value: selectedCurrency?.code ?? "Select Currency",
                icon: selectedCurrency != nil ? CurrencyService.shared.getCurrencyIcon(for: selectedCurrency!) : "questionmark.circle"
            ) {
                showingCurrencySelection = true
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canSave: Bool {
        !accountName.isEmpty && selectedCurrency != nil
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
        
        let balance = Decimal(string: initialBalance) ?? 0
        
        let account = Account(
            name: accountName,
            balance: balance,
            currency: currency,
            isDefault: false,
            colorIndex: selectedImageIndex, // Сохраняем индекс изображения
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

// MARK: - Custom Input Field
struct CustomInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var suffix: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            
            HStack {
                TextField(placeholder, text: $text)
                    .font(.body)
                    .foregroundStyle(.white)
                    .keyboardType(keyboardType)
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Custom Selection Row
struct CustomSelectionRow: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                HStack {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                    
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .buttonStyle(.plain)
    }
}
