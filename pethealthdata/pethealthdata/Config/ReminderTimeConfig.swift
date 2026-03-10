import Foundation

/// Vaccine reminder time configuration
enum VaccineReminderConfig {
    
    /// UserDefaults keys for user preferences
    private enum Keys {
        static let defaultTimeKey = "reminderDefaultTime"
        static let defaultDaysKey = "reminderDefaultDays"
    }
    
    /// Preset reminder time options
    struct ReminderTimeOption: Identifiable, Hashable {
        let id: Int
        let days: Int
        let displayName: String
        
        static let allCases: [ReminderTimeOption] = [
            .init(id: 30, days: 30, displayName: "30 days before"),
            .init(id: 14, days: 14, displayName: "14 days before"),
            .init(id: 7, days: 7, displayName: "7 days before"),
            .init(id: 3, days: 3, displayName: "3 days before"),
            .init(id: 1, days: 1, displayName: "1 day before"),
            .init(id: 0, days: 0, displayName: "On the day")
        ]
        
        /// Hardcoded default selected options (used when no user preference exists)
        static let hardcodedDefaults: [Int] = [30, 14, 7, 3, 1, 0]
    }
    
    /// Default reminder send time from user settings, or hardcoded default (9:00 AM)
    static var defaultReminderTime: Date {
        if let savedTime = UserDefaults.standard.object(forKey: Keys.defaultTimeKey) as? Date {
            return savedTime
        }
        // Hardcoded default: 9:00 AM
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }
    
    /// Default reminder days from user settings, or hardcoded defaults
    static var defaultReminderDays: [Int] {
        if let savedDays = UserDefaults.standard.array(forKey: Keys.defaultDaysKey) as? [Int],
           !savedDays.isEmpty {
            return savedDays.sorted(by: >)
        }
        // Hardcoded default: all options
        return [30, 14, 7, 3, 1, 0]
    }
    
    /// Reset to hardcoded defaults
    static func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: Keys.defaultTimeKey)
        UserDefaults.standard.removeObject(forKey: Keys.defaultDaysKey)
    }
}
