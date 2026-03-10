import SwiftUI

/// Settings view for configuring default vaccine reminder times
struct ReminderTimeConfigView: View {
    @Environment(\.dismiss) private var dismiss
    
    // User defaults keys
    private let defaultTimeKey = "reminderDefaultTime"
    private let defaultDaysKey = "reminderDefaultDays"
    
    @State private var defaultReminderTime: Date = Date()
    @State private var defaultReminderDays: [Int] = []
    
    // Available time options (hour)
    private let hourOptions = Array(0...23)
    
    // Available minute options (15-minute intervals)
    private let minuteOptions = [0, 15, 30, 45]
    
    // Available reminder day options
    private let dayOptions = [
        (days: 30, label: "30 days before"),
        (days: 14, label: "14 days before"),
        (days: 7, label: "7 days before"),
        (days: 3, label: "3 days before"),
        (days: 1, label: "1 day before"),
        (days: 0, label: "On the day")
    ]
    
    var body: some View {
        Form {
            Section("Default Reminder Time") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Set the default time for vaccine reminders. This time will be used when adding new vaccines.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Time")
                        Spacer()
                        DatePicker("", selection: $defaultReminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
            }
            
            Section("Default Reminder Days") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select which reminder notifications to enable by default. You can still customize these when adding each vaccine.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(dayOptions, id: \.days) { option in
                        Toggle(option.label, isOn: Binding(
                            get: { defaultReminderDays.contains(option.days) },
                            set: { isSelected in
                                if isSelected {
                                    if !defaultReminderDays.contains(option.days) {
                                        defaultReminderDays.append(option.days)
                                        defaultReminderDays.sort(by: >)
                                    }
                                } else {
                                    defaultReminderDays.removeAll { $0 == option.days }
                                }
                            }
                        ))
                    }
                }
            }
            
            Section("Preview") {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text("Reminders will be sent at:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedTime)
                            .font(.body)
                    }
                }
                
                if !defaultReminderDays.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Default reminders:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formattedDays)
                                .font(.body)
                        }
                    }
                }
            }
            
            Section {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Reminder Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    saveSettings()
                    dismiss()
                }
            }
        }
    }
    
    private func loadSettings() {
        // Load saved time
        if let savedTime = UserDefaults.standard.object(forKey: defaultTimeKey) as? Date {
            defaultReminderTime = savedTime
        } else {
            // Default to 9:00 AM
            defaultReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
        
        // Load saved days
        let savedDays = UserDefaults.standard.array(forKey: defaultDaysKey) as? [Int]
        if let savedDays = savedDays, !savedDays.isEmpty {
            defaultReminderDays = savedDays.sorted(by: >)
        } else {
            // Default: all options selected
            defaultReminderDays = [30, 14, 7, 3, 1, 0]
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(defaultReminderTime, forKey: defaultTimeKey)
        UserDefaults.standard.set(defaultReminderDays, forKey: defaultDaysKey)
    }
    
    private func resetToDefaults() {
        defaultReminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        defaultReminderDays = [30, 14, 7, 3, 1, 0]
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: defaultReminderTime)
    }
    
    private var formattedDays: String {
        let sortedDays = defaultReminderDays.sorted(by: >)
        return sortedDays.map { day in
            switch day {
            case 30: return "30 days"
            case 14: return "14 days"
            case 7: return "7 days"
            case 3: return "3 days"
            case 1: return "1 day"
            case 0: return "On the day"
            default: return "\(day) days"
            }
        }.joined(separator: ", ")
    }
}

#Preview {
    NavigationStack {
        ReminderTimeConfigView()
    }
}