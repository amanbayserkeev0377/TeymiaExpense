import SwiftUI

// MARK: - Settings Row Component

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconGradient: LinearGradient?
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconGradient: LinearGradient? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconGradient = iconGradient
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconGradient != nil ? AnyShapeStyle(iconGradient!) : AnyShapeStyle(Color.primary))
                
                if let iconGradient = iconGradient {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(iconGradient)
                } else {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                }
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .padding(.leading, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings Link Row (with NavigationLink)

struct SettingsLinkRow<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconGradient: LinearGradient?
    let destination: Destination
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconGradient: LinearGradient? = nil,
        @ViewBuilder destination: () -> Destination
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconGradient = iconGradient
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconGradient != nil ? AnyShapeStyle(iconGradient!) : AnyShapeStyle(Color.primary))
                
                if let iconGradient = iconGradient {
                    Text(title)
                        .font(.body)
                        .fontDesign(.rounded)
                        .fontWeight(.medium)
                        .foregroundStyle(iconGradient)
                } else {
                    Text(title)
                        .font(.body)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.primary)
                }
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.body)
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                }
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .padding(.leading, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Settings Section Container

struct SettingsSection<Content: View>: View {
    let title: String?
    let footer: String?
    let content: Content
    
    init(
        title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            if let title = title {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            
            // Content Card
            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.mainRowBackground)
            .cornerRadius(30)
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        .gray.opacity(0.2),
                        lineWidth: 0.7
                    )
            }
            .shadow(color: .black.opacity(0.1), radius: 10)
            .padding(.horizontal, 16)
            
            // Footer
            if let footer = footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 30)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Settings Divider

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 40)
            .padding(.vertical, 8)
    }
}
