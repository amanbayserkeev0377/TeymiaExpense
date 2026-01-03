import SwiftUI

struct CloseToolbarButton: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
            }
        }
    }
}

struct ConfirmationToolbarButton: ToolbarContent {
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            
            Button("save".localized, systemImage: "checkmark", role: .confirm) {
                action()
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
    }
}

struct EditDoneToolbarButton: ToolbarContent {
    @Binding var isEditMode: Bool
    let action: (() -> Void)?
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                action?()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEditMode.toggle()
                }
            } label: {
                Image(systemName: isEditMode ? "checkmark" : "pencil")
                    .fontWeight(.semibold)
            }
        }
    }
}

struct AddToolbarButton: ToolbarContent {
    
    let action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: action) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
            }
        }
    }
}
