import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColor: IconColor
    @Binding var hexColor: String?
    @State private var pickedColor: Color = .red
    
    var buttonSize: CGFloat = 36
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    
    var body: some View {
           LazyVGrid(columns: columns, spacing: 12) {
               ForEach(IconColor.allCases, id: \.self) { iconColor in
                   Button {
                       withAnimation(.spring(response: 0.3)) {
                           selectedColor = iconColor
                           hexColor = nil
                       }
                   } label: {
                       Circle()
                           .fill(iconColor.color)
                           .frame(width: buttonSize, height: buttonSize)
                           .overlay(
                               Circle()
                                .stroke(Color.secondary.opacity(0.6), lineWidth: 2.5)
                                .frame(width: buttonSize * 1.2, height: buttonSize * 1.2)
                                .opacity(selectedColor == iconColor && hexColor == nil ? 1 : 0)
                           )
                   }
                   .buttonStyle(.plain)
               }
               
               ColorPicker("", selection: $pickedColor)
                   .scaleEffect(1.3)
                   .labelsHidden()
                   .onChange(of: pickedColor) { _, newValue in
                       withAnimation {
                           hexColor = newValue.toHex()
                       }
                   }
                   .background(
                       Circle()
                        .stroke(hexColor != nil ? Color.secondary.opacity(0.6) : Color.clear, lineWidth: 2.5)
                           .frame(width: buttonSize * 1.2, height: buttonSize * 1.2)
                   )
           }
           .onAppear {
               if let hex = hexColor {
                   pickedColor = Color(hex: hex)
               }
           }
       }
   }
