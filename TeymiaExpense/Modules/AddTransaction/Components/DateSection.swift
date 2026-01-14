import SwiftUI

struct DateNoteSection: View {
    @Binding var date: Date
    
    var body: some View {
        Section {
            HStack {
                Image("calendar.date")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.primary)
                DatePicker("date".localized, selection: $date, displayedComponents: [.date])
            }
        }
    }
}
