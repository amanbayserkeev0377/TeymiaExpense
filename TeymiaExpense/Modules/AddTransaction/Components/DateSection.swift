import SwiftUI

struct DateNoteSection: View {
    @Binding var date: Date
    
    var body: some View {
        Section {
            DatePicker("", selection: $date, displayedComponents: [.date])
                .labelsHidden()
                .datePickerStyle(.graphical)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}
