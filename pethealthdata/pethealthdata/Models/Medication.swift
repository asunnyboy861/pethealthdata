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
}
