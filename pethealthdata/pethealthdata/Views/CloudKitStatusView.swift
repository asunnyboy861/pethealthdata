import SwiftUI
import CloudKit

/// View to display CloudKit synchronization status
struct CloudKitStatusView: View {
    @State private var accountStatus: CKAccountStatus = .couldNotDetermine
    @State private var isAvailable: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        Form {
            Section("CloudKit Status") {
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Checking status...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    StatusRow(
                        title: "iCloud Account",
                        status: accountStatusDescription,
                        icon: accountStatusIcon,
                        color: accountStatusColor
                    )
                    
                    StatusRow(
                        title: "CloudKit Available",
                        status: isAvailable ? "Yes" : "No",
                        icon: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill",
                        color: isAvailable ? .green : .red
                    )
                    
                    if isAvailable {
                        Text("Your data will automatically sync across devices using the same Apple ID.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Container Information") {
                HStack {
                    Text("Container ID")
                    Spacer()
                    Text("iCloud.com.zzoutuo.pethealthdata")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                StatusRow(
                    title: "Sync Status",
                    status: isAvailable ? "Automatic" : "Disabled",
                    icon: isAvailable ? "arrow.triangle.2.circlepath" : "arrow.triangle.2.circlepath.slash",
                    color: isAvailable ? .blue : .gray
                )
            }
            
            if !isAvailable {
                Section("How to Enable") {
                    Text("To enable cross-device synchronization:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Make sure you're signed in to iCloud")
                            .font(.caption)
                        Text("2. Go to Settings > [Your Name] > iCloud")
                            .font(.caption)
                        Text("3. Ensure CloudKit is enabled for this app")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("iCloud Sync")
        .onAppear {
            checkCloudKitStatus()
        }
    }
    
    private func checkCloudKitStatus() {
        isLoading = true
        
        let container = CKContainer(identifier: "iCloud.com.zzoutuo.pethealthdata")
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                self.accountStatus = status
                self.isAvailable = (status == .available)
                self.isLoading = false
            }
        }
    }
    
    private var accountStatusDescription: String {
        switch accountStatus {
        case .available: return "Available"
        case .couldNotDetermine: return "Unknown"
        case .noAccount: return "No iCloud Account"
        case .restricted: return "Restricted"
        case .temporarilyUnavailable: return "Temporarily Unavailable"
        @unknown default: return "Unknown"
        }
    }
    
    private var accountStatusIcon: String {
        switch accountStatus {
        case .available: return "checkmark.circle.fill"
        case .couldNotDetermine: return "questionmark.circle.fill"
        case .noAccount: return "xmark.circle.fill"
        case .restricted: return "exclamationmark.circle.fill"
        case .temporarilyUnavailable: return "exclamationmark.circle.fill"
        @unknown default: return "questionmark.circle.fill"
        }
    }
    
    private var accountStatusColor: Color {
        switch accountStatus {
        case .available: return .green
        case .couldNotDetermine: return .gray
        case .noAccount: return .red
        case .restricted: return .orange
        case .temporarilyUnavailable: return .orange
        @unknown default: return .gray
        }
    }
}

/// Helper row for status display
struct StatusRow: View {
    let title: String
    let status: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        CloudKitStatusView()
    }
}