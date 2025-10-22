import SwiftUI
import CloudKit

// MARK: - Row for Settings

struct CloudKitSyncRowView: View {
    var body: some View {
        ZStack {
            NavigationLink(destination: CloudKitSyncView()) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Label(
                    title: { Text("iCloud Sync") },
                    icon: {
                        Image("cloud.upload")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.primary)
                    }
                )
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Main CloudKit View

struct CloudKitSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cloudKitStatus: CloudKitStatus = .checking
    @State private var lastSyncTime: Date?
    @State private var isSyncing = false
    
    var body: some View {
        BlurNavigationView(
            title: "iCloud Sync",
            showBackButton: true
        ) {
            VStack(spacing: 24) {
                // Status Section
                CustomSection(title: "Status") {
                    HStack {
                        Text(cloudKitStatus.statusInfo.text)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundStyle(cloudKitStatus.statusInfo.color)
                        
                        Spacer()
                        
                        if case .checking = cloudKitStatus {
                            ProgressView()
                        }
                    }
                }
                
                // Actions Section (only when available)
                if case .available = cloudKitStatus {
                    CustomSection(title: "Sync", footer: "Data syncs automatically in the background. Use force sync only if needed.") {
                        // Force Sync Button
                        Button {
                            Task { await forceSync() }
                        } label: {
                            HStack {
                                Text("Force Sync")
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.appTint)
                                
                                Spacer()
                                
                                if isSyncing {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isSyncing)
                        
                        // Last Sync Time
                        if let lastSync = lastSyncTime {
                            Divider()
                                .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Sync")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fontDesign(.rounded)
                                
                                Text(formatTime(lastSync))
                                    .foregroundStyle(.primary)
                                    .fontDesign(.rounded)
                            }
                        }
                    }
                }
                
                // Troubleshooting Section (when unavailable)
                if case .unavailable = cloudKitStatus {
                    CustomSection(title: "Setup Required") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sign in to iCloud")
                                .font(.headline)
                                .fontDesign(.rounded)
                            
                            Text("To enable sync:\n1. Open Settings\n2. Tap your name\n3. Sign in with Apple ID")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fontDesign(.rounded)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Error Section
                if case .error(let message) = cloudKitStatus {
                    CustomSection(title: "Troubleshooting") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sync Error")
                                .font(.headline)
                                .fontDesign(.rounded)
                            
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fontDesign(.rounded)
                            
                            Button {
                                Task { await checkAccountStatus() }
                            } label: {
                                Text("Retry")
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.appTint)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Restricted Section
                if case .restricted = cloudKitStatus {
                    CustomSection(title: "Setup Required") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("iCloud Restricted")
                                .font(.headline)
                                .fontDesign(.rounded)
                            
                            Text("iCloud sync is restricted on this device. Check your device settings or parental controls.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fontDesign(.rounded)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color.mainBackground)
        .navigationBarHidden(true)
        .onAppear {
            loadLastSyncTime()
            Task { await checkAccountStatus() }
        }
    }
    
    // MARK: - Methods
    
    private func forceSync() async {
        await MainActor.run { isSyncing = true }
        
        do {
            try modelContext.save()
            try await Task.sleep(for: .seconds(2))
            
            let container = CKContainer(identifier: "iCloud.com.amanbayserkeev.teymiabudget")
            let status = try await container.accountStatus()
            
            guard status == .available else {
                throw NSError(domain: "CloudKit", code: -1)
            }
            
            await MainActor.run {
                lastSyncTime = Date()
                UserDefaults.standard.set(Date(), forKey: "lastSyncTime")
                isSyncing = false
            }
        } catch {
            await MainActor.run { isSyncing = false }
        }
    }
    
    @MainActor
    private func checkAccountStatus() async {
        do {
            let container = CKContainer(identifier: "iCloud.com.amanbayserkeev.teymiabudget")
            let accountStatus = try await container.accountStatus()
            
            switch accountStatus {
            case .available:
                do {
                    let database = container.privateCloudDatabase
                    _ = try await database.allRecordZones()
                    cloudKitStatus = .available
                } catch {
                    cloudKitStatus = .error("Unable to connect to iCloud database. Check your internet connection.")
                }
                
            case .noAccount:
                cloudKitStatus = .unavailable
                
            case .restricted:
                cloudKitStatus = .restricted
                
            case .couldNotDetermine:
                cloudKitStatus = .error("Could not determine iCloud status. Please try again.")
                
            case .temporarilyUnavailable:
                cloudKitStatus = .error("iCloud is temporarily unavailable. Please try again later.")
                
            @unknown default:
                cloudKitStatus = .error("Unknown iCloud error occurred.")
            }
        } catch {
            cloudKitStatus = .error("Failed to check iCloud status. Check your internet connection.")
        }
    }
    
    private func loadLastSyncTime() {
        lastSyncTime = UserDefaults.standard.object(forKey: "lastSyncTime") as? Date
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if Calendar.current.isDateInToday(date) {
            return "Today at \(formatter.string(from: date))"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday at \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Custom Section Component

struct CustomSection<Content: View>: View {
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
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 24)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.mainRowBackground)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.1), radius: 10)
            .padding(.horizontal)
            
            // Footer
            if let footer = footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - CloudKit Status

enum CloudKitStatus: Equatable {
    case checking
    case available
    case unavailable
    case restricted
    case error(String)
    
    var statusInfo: (text: String, color: Color) {
        switch self {
        case .checking:
            return ("Checking...", .secondary)
        case .available:
            return ("Active", .income)
        case .unavailable:
            return ("Not Signed In", .orange)
        case .restricted:
            return ("Restricted", .expense)
        case .error(let message):
            return (message, .expense)
        }
    }
}
