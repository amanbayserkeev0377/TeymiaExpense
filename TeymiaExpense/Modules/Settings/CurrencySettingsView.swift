import SwiftUI
import SwiftData

struct CurrencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserPreferences.self) private var userPreferences
    @Query private var currencies: [Currency]
    
    @State private var selectedType: CurrencyType = .fiat
    @State private var searchText = ""
    
    private var filteredCurrencies: [Currency] {
        CurrencyDataProvider.searchCurrencies(query: searchText, type: selectedType)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            ZStack(alignment: .top) {
                // Main ScrollView
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        // Spacer for header
                        Color.clear
                            .frame(height: 100 + safeArea.top)
                        
                        // Search Bar
                        HStack {
                            Image("search")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.secondary)
                            
                            TextField("Search currencies", text: $searchText)
                                .textFieldStyle(.plain)
                                .tint(.appTint)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 16, height: 16)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.mainRowBackground)
                        .cornerRadius(30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.3),
                                            .white.opacity(0.15),
                                            .white.opacity(0.15),
                                            .white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.4
                                )
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                        
                        if filteredCurrencies.isEmpty {
                            VStack(spacing: 12) {
                                Image("search.question")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.secondary)
                                
                                Text("No currencies found")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .fontDesign(.rounded)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            // Currency List Card
                            LazyVStack(spacing: 10) {
                                ForEach(filteredCurrencies, id: \.code) { currency in
                                    CurrencyRowView(
                                        currency: currency,
                                        isSelected: userPreferences.baseCurrencyCode == currency.code
                                    ) {
                                        userPreferences.baseCurrencyCode = currency.code
                                        dismiss()
                                    }
                                    
                                    if currency != filteredCurrencies.last {
                                        Divider()
                                            .padding(.leading, 44)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.mainRowBackground)
                            .cornerRadius(30)
                            .overlay {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        .gray.opacity(0.2),
                                        lineWidth: 0.7
                                    )
                            }
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                // Blur Header with Segmented Control as title
                VStack(spacing: 0) {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 8, opaque: false)
                        .padding([.horizontal, .top], -30)
                        .overlay(alignment: .bottom) {
                            HStack(spacing: 12) {
                                Button {
                                    dismiss()
                                } label: {
                                    Image("chevron.left")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.appTint)
                                }
                                .buttonStyle(CircleButtonStyle())
                                
                                Spacer()
                                
                                CustomSegmentedControl(
                                    options: CurrencyType.allCases,
                                    titles: ["Fiat", "Crypto"],
                                    icons: ["dollar", "bitcoin.symbol"],
                                    iconSize: 16,
                                    selection: $selectedType
                                )
                                .frame(width: 200)
                                .onChange(of: selectedType) { searchText = "" }
                                
                                Spacer()
                                
                                Spacer()
                                    .frame(width: 44, height: 44)
                            }
                            .padding(.horizontal, 18)
                            .frame(height: 44)
                            .padding(.bottom, 8)
                        }
                        .frame(height: 110 + safeArea.top)
                        .padding(.top, -safeArea.top)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(Color.mainBackground)
        .navigationBarHidden(true)
    }
}
