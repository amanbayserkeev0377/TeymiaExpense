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
                        .fontWeight(.bold)
                }
            } else {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.secondary.opacity(0.13))
                        )
                }
            }
        }
    }
}

struct BackToolbarButton: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: "xmark")
                        .fontWeight(.bold)
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
                Button(action: action) {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
            } else {
                Button(action: action) {
                    Text("done".localized)
                        .fontWeight(.bold)
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                    }
                } label: {
                    Image(systemName: isEditMode ? "checkmark" : "pencil")
                        .fontWeight(.bold)
                }
            } else {
                Button {
                    action?()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                    }
                } label: {
                    Text(isEditMode ? "done".localized : "edit".localized)
                        .fontWeight(isEditMode ? .bold : .medium)
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
                        .fontWeight(.bold)
                }
            } else {
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.secondary.opacity(0.15))
                        )
                }
            }
        }
    }
}
