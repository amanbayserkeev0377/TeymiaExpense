import SwiftUI

// MARK: - Date Range Header Component
struct DateRangeHeader: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    enum PeriodType {
        case week, month, year, custom
    }
    
    private var dateRangeText: String {
        DateFormatter.formatDateRange(startDate: startDate, endDate: endDate)
    }
    
    var body: some View {
        Section {
            HStack {
                CustomMenuView {
                    HStack(spacing: 8) {
                        Text(dateRangeText)
                            .font(.headline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Image("calendar")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                } content: {
                    DateFilterView(
                        startDate: $startDate,
                        endDate: $endDate
                    )
                }
            }
            .padding(.horizontal, 32)
        }
        .listRowInsets(EdgeInsets())
        .listSectionSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

// MARK: - Shared Date Filter View
struct DateFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 8) {
                Image("calendar.week")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("week".localized)
                .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                setWeekPeriod()
                dismiss()
            }
            
            HStack(spacing: 8) {
                Image("calendar.month")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("month".localized)
                .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                setMonthPeriod()
                dismiss()
            }
            
            HStack(spacing: 8) {
                Image("calendar.year")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("year".localized)
                .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                setYearPeriod()
                dismiss()
            }
            
            Divider().opacity(0.3)
            
            // Custom Date Range
            HStack(spacing: 8) {
                Image("calendar.custom")
                    .resizable()
                    .frame(width: 18, height: 18)
                DatePicker("start".localized, selection: $startDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
            }
            
            HStack(spacing: 8) {
                Image("calendar.custom")
                    .resizable()
                    .frame(width: 18, height: 18)
                DatePicker("end".localized, selection: $endDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
            }
        }
        .padding(15)
    }
    
    // MARK: - Period Setting Methods
    
    private func setWeekPeriod() {
        startDate = Date.startOfCurrentWeek
        endDate = Date.endOfCurrentWeek
    }
    
    private func setMonthPeriod() {
        startDate = Date.startOfCurrentMonth
        endDate = Date.endOfCurrentMonth
    }
    
    private func setYearPeriod() {
        startDate = Date.startOfCurrentYear
        endDate = Date()
    }
}

// MARK: - Custom Menu View
struct CustomMenuView<Label: View, Content: View>: View {
    var isHapticsEnabled: Bool = true
    @ViewBuilder var label: Label
    @ViewBuilder var content: Content
    
    @State private var haptics: Bool = false
    @State private var isExpanded: Bool = false
    @Namespace private var namespace
    
    var body: some View {
        Button {
            if isHapticsEnabled {
                haptics.toggle()
            }
            isExpanded.toggle()
        } label: {
            label
                .matchedTransitionSource(id: "MENUCONTENT", in: namespace)
        }
        .applyGlassButtonStyle()
        .popover(isPresented: $isExpanded) {
            PopOverHelper {
                content
            }
            #if !targetEnvironment(macCatalyst)
            .navigationTransition(.zoom(sourceID: "MENUCONTENT", in: namespace))
            #endif
        }
        .sensoryFeedback(.selection, trigger: haptics)
    }
}

private extension View {
    @ViewBuilder
    func applyGlassButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(GlassLikeButtonStyle())
        }
    }
}

// MARK: - Glass-like Button Style (Fallback)
struct GlassLikeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

fileprivate struct PopOverHelper<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var isVisible: Bool = false
    
    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .task {
                try? await Task.sleep(for: .seconds(0.1))
                withAnimation(.snappy(duration: 0.4, extraBounce: 0)) {
                    isVisible = true
                }
            }
            .presentationCompactAdaptation(.popover)
    }
}
