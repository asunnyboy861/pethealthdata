import SwiftUI

/// Settings view (as a standalone Tab)
struct SettingsView: View {
    @AppStorage("reminderTime") private var reminderTimeInterval: TimeInterval = Date().timeIntervalSince1970
    @AppStorage("reminderDays") private var reminderDaysString: String = "[30, 14, 7, 3, 1, 0]"
    
    private var reminderTime: Date {
        get { Date(timeIntervalSince1970: reminderTimeInterval) }
        set { reminderTimeInterval = newValue.timeIntervalSince1970 }
    }
    
    private var reminderDays: [Int] {
        get {
            guard let data = reminderDaysString.data(using: .utf8),
                  let days = try? JSONDecoder().decode([Int].self, from: data) else {
                return [30, 14, 7, 3, 1, 0]
            }
            return days
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                reminderDaysString = string
            }
        }
    }
    
    var body: some View {
        Form {
            // MARK: - Reminders
            Section("Reminders") {
                NavigationLink(destination: ReminderTimeConfigView()) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Text("Reminder Time")
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            Text("Default time and days for vaccine reminders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink(destination: NotificationSoundPickerView(
                    selectedSound: .constant(NotificationSoundConfig.SoundOption.default.fileName)
                )) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Text("Notification Sound")
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            Text("Choose alert sounds")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // MARK: - iCloud & Sync
            Section("iCloud & Sync") {
                NavigationLink(destination: CloudKitStatusView()) {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Text("iCloud Sync Status")
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            Text("Check cross-device synchronization")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // MARK: - Data Management
            Section("Data Management") {
                NavigationLink(destination: ExportDataView()) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.purple)
                            .frame(width: 30)
                        Text("Export Data")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // MARK: - App Information
            Section("App Information") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Container")
                    Spacer()
                    Text("iCloud.com.zzoutuo.pethealthdata")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                Link(destination: URL(string: "https://privacy.example.com")!) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://terms.example.com")!) {
                    HStack {
                        Text("Terms of Service")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// Export Data View placeholder
struct ExportDataView: View {
    var body: some View {
        Form {
            Section("Export Options") {
                Button("Export as PDF") {
                    // Export functionality
                }
                
                Button("Export as CSV") {
                    // Export functionality
                }
            }
            
            Section("Share") {
                Button("Share with Vet") {
                    // Share functionality
                }
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}