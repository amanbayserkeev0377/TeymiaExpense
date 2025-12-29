import SwiftUI

struct CloseToolbarButton: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if #available(iOS 26.0, *) {
                Button(role: .close) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .fontWeight(.semibold)
                }
            } else {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .contentShape(Circle())
                }
            }
        }
    }
}

struct ConfirmationToolbarButton: ToolbarContent {
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if #available(iOS 26.0, *) {
                Button("save".localized, systemImage: "checkmark", role: .confirm) {
                    action()
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
            } else {
                Button("save".localized) {
                    action()
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
                
            }
        }
    }
}

struct EditDoneToolbarButton: ToolbarContent {
    @Binding var isEditMode: Bool
    let action: (() -> Void)?
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if #available(iOS 26.0, *) {
                Button {
                    action?()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEditMode.toggle()
                    }
                } label: {
                    Image(systemName: isEditMode ? "checkmark" : "pencil")
                        .fontWeight(.semibold)
                }
            } else {
                Button {
                    action?()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                    }
                } label: {
                    Image(systemName: isEditMode ? "checkmark" : "pencil")
                        .font(.system(size: 12, weight: .bold))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .contentShape(Circle())
                }
            }
        }
    }
}

struct AddToolbarButton: ToolbarContent {
    
    let action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if #available(iOS 26.0, *) {
                Button(action: action) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            } else {
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .contentShape(Circle())
                }
            }
        }
    }
}
