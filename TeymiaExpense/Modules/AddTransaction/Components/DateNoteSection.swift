import SwiftUI

struct DateNoteSection: View {
    @Binding var date: Date
    @Binding var note: String
    
    var body: some View {
        Section {
            HStack {
                Image("calendar.date")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                DatePicker("date".localized, selection: $date, displayedComponents: [.date])
            }
            HStack {
                Image("note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                TextField("note".localized, text: $note, axis: .vertical)
            }
        }
        .listRowBackground(Color.mainRowBackground)
    }
}
