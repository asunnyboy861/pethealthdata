import Foundation
import SwiftData

@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String
    var frequency: String
    var reminderTimesData: Data?
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var notificationSoundData: Data?
    var isActive: Bool
    var createdAt: Date
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        dosage: String = "",
        frequency: String = "daily",
        reminderTimes: [Date] = [],
        startDate: Date = Date(),
        endDate: Date? = nil,
        notes: String? = nil,
        notificationSound: String = "reminder",
        isActive: Bool = true,
        createdAt: Date = Date(),
        pet: Pet? = nil
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.reminderTimesData = try? JSONEncoder().encode(reminderTimes)
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.notificationSoundData = try? JSONEncoder().encode(notificationSound)
        self.isActive = isActive
        self.createdAt = createdAt
        self.pet = pet
    }
    
    var reminderTimes: [Date] {
        get {
            guard let data = reminderTimesData else { return [] }
            return (try? JSONDecoder().decode([Date].self, from: data)) ?? []
        }
        set {
            reminderTimesData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var notificationSound: String {
        get {
            guard let data = notificationSoundData,
                  let sound = try? JSONDecoder().decode(String.self, from: data) else {
                return "reminder"
            }
            return sound
        }
        set {
            notificationSoundData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var frequencyText: String {
        switch frequency {
        case "daily": return "Daily"
        case "twice_daily": return "Twice Daily"
        case "three_times_daily": return "Three Times Daily"
        case "weekly": return "Weekly"
        case "as_needed": return "As Needed"
        default: return frequency
        }
    }
    
    var frequencyIcon: String {
        switch frequency {
        case "daily": return "sunrise.fill"
        case "twice_daily": return "sun.max.fill"
        case "three_times_daily": return "clock.fill"
        case "weekly": return "calendar"
        case "as_needed": return "questionmark.circle"
        default: return "pills.fill"
        }
    }
    
    var nextDoseTime: Date? {
        guard isActive else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch frequency {
        case "daily", "twice_daily", "three_times_daily":
            let times = reminderTimes.sorted()
            for time in times {
                if let todayTime = calendar.date(bySettingHour: calendar.component(.hour, from: time),
                                                 minute: calendar.component(.minute, from: time),
                                                 second: 0,
                                                 of: now),
                   todayTime > now {
                    return todayTime
                }
            }
            if let firstTime = times.first,
               let tomorrowTime = calendar.date(byAdding: .day, value: 1, to: firstTime) {
                return tomorrowTime
            }
        case "weekly":
            if let endDate = endDate, endDate > now {
                return startDate
            }
        default:
            break
        }
        
        return nil
    }
    
    /// Check if medication is due today
    /// - Parameter today: Today's date (typically Calendar.current.startOfDay(for: Date()))
    /// - Returns: true if medication is due, false otherwise
    /// 
    /// Logic:
    /// 1. Check if medication is active and within valid date range
    /// 2. For as-needed medications, always show
    /// 3. Check reminder times against CURRENT time (not start of day)
    ///    - Example: At 3 PM, 9 AM dose should show as "completed", not "due"
    func isDueToday(today: Date) -> Bool {
        guard isActive else { return false }
        
        let calendar = Calendar.current
        
        // 1. Check validity period
        guard startDate <= today else { return false }
        if let endDate = endDate, endDate < today {
            return false
        }
        
        // 2. For as-needed medications, always show
        if frequency == "as_needed" {
            return true
        }
        
        // 3. Check reminder times
        let times = reminderTimes.sorted()
        if times.isEmpty {
            return true // No specific times, show as pending
        }
        
        // 4. Check if any dose time is in the future (FIXED: Compare with current time, not start of day)
        let now = Date()
        for time in times {
            let hour = calendar.component(.hour, from: time)
            let minute = calendar.component(.minute, from: time)
            
            var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
            todayComponents.hour = hour
            todayComponents.minute = minute
            
            if let doseTime = calendar.date(from: todayComponents),
               doseTime >= now {  // FIXED: Compare with Date() instead of today
                return true
            }
        }
        
        // All dose times have passed
        return false
    }
}

// MARK: - Additional Properties Extension
extension Medication {
    /// Last time medication was taken (for tracking)
    var lastTaken: Date? {
        get {
            // Could be stored in notes or a separate field if needed
            return nil
        }
        set {
            // For now, this is a computed property placeholder
            // In a real app, you'd want to store this in a persistent field
        }
    }
}
