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
                            .foregroundStyle(.primary)
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
        List {
            // Status Section
            Section("Status") {
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
            .listRowBackground(Color.mainRowBackground)
            
            // Actions Section
            if case .available = cloudKitStatus {
                Section {
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
                } footer: {
                    Text("Data syncs automatically in the background. Use force sync only if needed.")
                        .fontDesign(.rounded)
                }
                .listRowBackground(Color.mainRowBackground)
            }
            
            // Troubleshooting Section
            if case .unavailable = cloudKitStatus {
                Section {
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
                } header: {
                    Text("Setup Required")
                        .fontDesign(.rounded)
                }
                .listRowBackground(Color.mainRowBackground)
            }
            
            // Error Section
            if case .error(let message) = cloudKitStatus {
                Section {
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
                } header: {
                    Text("Troubleshooting")
                        .fontDesign(.rounded)
                }
                .listRowBackground(Color.mainRowBackground)
            }
            
            // Restricted Section
            if case .restricted = cloudKitStatus {
                Section {
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
                } header: {
                    Text("Setup Required")
                        .fontDesign(.rounded)
                }
                .listRowBackground(Color.mainRowBackground)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.mainBackground)
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.large)
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
