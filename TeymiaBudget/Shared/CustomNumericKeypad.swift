import SwiftUI

struct CustomNumericKeypad: View {
    @Binding var amount: String
    @Environment(\.colorScheme) private var colorScheme
    
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            //Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.3)
                .edgesIgnoringSafeArea(.horizontal)

                .frame(width: 2)
            // ToolbarItem keyboard
            HStack {
                Button("Clear") {
                    amount = ""
                }
                .foregroundStyle(.red)
                .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    onDismiss()
                }) {
                    Image("chevron.down")
                        .resizable()
                        .frame(width: 26, height: 26)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.3)
                .edgesIgnoringSafeArea(.horizontal)
            
            // Keypad Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 6) {
                // Row 1: 1, 2, 3
                ForEach(1...3, id: \.self) { number in
                    numericButton("\(number)")
                }
                
                // Row 2: 4, 5, 6
                ForEach(4...6, id: \.self) { number in
                    numericButton("\(number)")
                }
                
                // Row 3: 7, 8, 9
                ForEach(7...9, id: \.self) { number in
                    numericButton("\(number)")
                }
                
                // Row 4: ., 0, backspace
                decimalButton()
                numericButton("0")
                backspaceButton()
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)
            .padding(.bottom, 36)
        }
        .background(.ultraThinMaterial)
    }
    
    private func numericButton(_ title: String) -> some View {
        Button {
            handleNumericInput(title)
        } label: {
            Text(title)
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    colorScheme == .dark ? Color.secondary.opacity(0.1) : Color.white.opacity(0.8)
                )
                .cornerRadius(8)
                .foregroundStyle(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.4)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
    
    private func decimalButton() -> some View {
        Button {
            handleDecimalInput()
        } label: {
            Text(".")
                .font(.system(size: 26, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.clear)
                .cornerRadius(8)
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func backspaceButton() -> some View {
        Button {
            if !amount.isEmpty {
                amount.removeLast()
            }
        } label: {
            Image("delete.left")
                .resizable()
                .frame(width: 30, height: 30)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.clear)
                .cornerRadius(8)
                .foregroundStyle(.primary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func handleNumericInput(_ input: String) {
        if amount == "0" {
            amount = input
        } else {
            amount += input
        }
    }
    
    private func handleDecimalInput() {
        if !amount.contains(".") {
            if amount.isEmpty {
                amount = "0."
            } else {
                amount += "."
            }
        }
    }
}
