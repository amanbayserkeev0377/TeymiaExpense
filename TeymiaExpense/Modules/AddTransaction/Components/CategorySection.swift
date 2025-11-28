import SwiftUI

struct CategoriesSection: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let colorScheme: ColorScheme
    
    private let itemsPerPage = 8
    private let columnsCount = 4
    private let rowsCount = 2
    
    private var categoryPages: [[Category]] {
        stride(from: 0, to: categories.count, by: itemsPerPage).map {
            Array(categories[$0..<min($0 + itemsPerPage, categories.count)])
        }
    }
    
    @State private var currentPage = 0
    
    var body: some View {
        if categories.isEmpty {
            ContentUnavailableView(
                "No categories",
                systemImage: "circle.grid.2x2"
            )
        } else {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(categoryPages.indices, id: \.self) { pageIndex in
                        categoryGrid(for: categoryPages[pageIndex])
                            .tag(pageIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 190)
                
                // Page indicators
                if categoryPages.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<categoryPages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.5))
                                .frame(width: 6, height: 6)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func categoryGrid(for pageCategories: [Category]) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: columnsCount),
            alignment: .leading, spacing: 16
        ) {
            ForEach(0..<itemsPerPage, id: \.self) { index in
                if index < pageCategories.count {
                    let category = pageCategories[index]
                    CategoryCircleButton(
                        category: category,
                        isSelected: selectedCategory?.id == category.id,
                        colorScheme: colorScheme
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 70)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CategoryCircleButton: View {
    let category: Category
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Image(category.iconName)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(
                            isSelected
                            ? (colorScheme == .light ? Color.white : Color.black)
                            : Color.primary
                        )
                        .padding(10)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.primary : Color.secondary.opacity(0.1))
                        )
                    
                    Spacer().frame(height: 8)
                }
                .frame(height: 50)
                
                VStack(spacing: 0) {
                    Text(category.name)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 2)
                    
                    Spacer()
                }
                .frame(height: 30)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
        }
        .buttonStyle(.plain)
    }
}
