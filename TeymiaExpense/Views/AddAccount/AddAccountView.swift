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
    @State private var selectedImageIndex: Int = 0
    @State private var selectedIcon: String = "cash"
    
    @State private var showingCurrencySelection = false
    @State private var showingIconSelection = false
    
    // View Properties
    @State private var topInset: CGFloat = 0
    @State private var scrollOffsetY: CGFloat = 0
    @State private var scrollProgressX: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 15) {
                    // Header
                    HStack {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    
                    // Image Selection Carousel
                    imageSelectionCarousel
                        .zIndex(-1)
                    
                    // Account Details Form
                    VStack(spacing: 16) {
                        accountDetailsSection
                        accountSettingsSection
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            Button {
                                saveAccount()
                            } label: {
                                Text("Save Account")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(canSave ? .white.opacity(0.9) : .white.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .foregroundStyle(canSave ? .black : .white.opacity(0.5))
                            .disabled(!canSave)
                        }
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .safeAreaPadding(15)
            .background {
                Rectangle()
                    .fill(colorScheme == .light ? Color.white.gradient : Color.black.gradient)
                    .scaleEffect(y: -1)
                    .ignoresSafeArea()
            }
            .onScrollGeometryChange(for: ScrollGeometry.self) {
                $0
            } action: { oldValue, newValue in
                topInset = newValue.contentInsets.top + 100
                scrollOffsetY = newValue.contentOffset.y + newValue.contentInsets.top
            }
            .navigationBarHidden(true)
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
    }
    
    // MARK: - Image Selection Carousel
    @ViewBuilder
    private var imageSelectionCarousel: some View {
        VStack(spacing: 16) {
            Text("Choose Card Design")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            // Carousel View (same as HomeView)
            let spacing: CGFloat = 6
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: spacing) {
                    ForEach(Array(AccountImageData.images.enumerated()), id: \.element.id) { index, imageData in
                        AccountCardPreview(
                            name: accountName,
                            balance: initialBalance,
                            imageIndex: index,
                            icon: selectedIcon,
                            currencyCode: selectedCurrency?.code ?? "USD"
                        )
                        .containerRelativeFrame(.horizontal)
                        .frame(height: 220)
                        .onTapGesture {
                            selectedImageIndex = index
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: 220)
            .background(PreviewBackdropEffect())
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .onScrollGeometryChange(for: CGFloat.self) {
                let offsetX = $0.contentOffset.x + $0.contentInsets.leading
                let width = $0.containerSize.width + spacing
                
                return offsetX / width
            } action: { oldValue, newValue in
                let maxValue = CGFloat(max(AccountImageData.images.count - 1, 0))
                scrollProgressX = min(max(newValue, 0), maxValue)
            }
        }
    }
    
    // MARK: - Preview Backdrop Effect
    @ViewBuilder
    private func PreviewBackdropEffect() -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                ForEach(Array(AccountImageData.images.reversed().enumerated()), id: \.element.id) { arrayIndex, imageData in
                    let index = CGFloat(AccountImageData.images.count - 1 - arrayIndex) + 1
                    
                    Image(imageData.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                        .opacity(index - scrollProgressX)
                }
            }
            .compositingGroup()
            .blur(radius: 25, opaque: true)
            .overlay {
                Rectangle()
                    .fill(.black.opacity(0.25))
            }
            .mask {
                Rectangle()
                    .fill(.linearGradient(colors: [
                        .black,
                        .black.opacity(0.7),
                        .black.opacity(0.6),
                        .black.opacity(0.3),
                        .black.opacity(0.25),
                        .clear
                    ], startPoint: .top, endPoint: .bottom))
            }
        }
        .containerRelativeFrame(.horizontal)
        .padding(.bottom, -60)
        .padding(.top, -topInset)
        .offset(y: scrollOffsetY < 0 ? scrollOffsetY : 0)
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
                    .foregroundStyle(.primary)
                    .keyboardType(keyboardType)
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.body)
                        .foregroundStyle(.primary.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.primary.opacity(0.2), lineWidth: 1)
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
                        .foregroundStyle(.primary)
                    
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.primary.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
        .buttonStyle(.plain)
    }
}
