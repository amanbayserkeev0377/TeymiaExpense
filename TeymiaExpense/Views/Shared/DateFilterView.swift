import SwiftUI

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
                    .frame(width: 20, height: 20)
                Text("Week")
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
                    .frame(width: 20, height: 20)
                Text("Month")
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
                    .frame(width: 20, height: 20)
                Text("Year")
                .foregroundStyle(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                setYearPeriod()
                dismiss()
            }
            
            Divider()
            
            // Custom Date Range
            HStack(spacing: 8) {
                Image("calendar.custom")
                    .resizable()
                    .frame(width: 20, height: 20)
                DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
            }
            
            HStack(spacing: 8) {
                Image("calendar.custom")
                    .resizable()
                    .frame(width: 20, height: 20)
                DatePicker("End", selection: $endDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
            }
        }
        .padding(15)
        .frame(width: 250, height: 250)
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
    var style: CustomMenuStyle = .glass
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
        .applyStyle(style)
        .popover(isPresented: $isExpanded) {
            PopOverHelper {
                content
            }
            .navigationTransition(.zoom(sourceID: "MENUCONTENT", in: namespace))
        }
        .sensoryFeedback(.selection, trigger: haptics)
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
                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                    isVisible = true
                }
            }
            .presentationCompactAdaptation(.popover)
    }
}

enum CustomMenuStyle: String, CaseIterable {
    case glass = "Glass"
    case glassProminent = "Glass Prominent"
}

fileprivate extension View {
    @ViewBuilder
    func applyStyle(_ style: CustomMenuStyle) -> some View {
        switch style {
        case .glass:
            self
                .buttonStyle(.glass)
        case .glassProminent:
            self
                .buttonStyle(.glassProminent)
        }
    }
}
