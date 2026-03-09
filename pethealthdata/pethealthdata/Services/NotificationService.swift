import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func scheduleVaccineReminder(for pet: Pet, vaccine: VaccineRecord) {
        guard let nextDueDate = vaccine.nextDueDate else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let calendar = Calendar.current
        
        let daysToNotify = [7, 3, 1, 0]
        
        for days in daysToNotify {
            let notifyDate = calendar.date(byAdding: .day, value: -days, to: nextDueDate) ?? nextDueDate
            
            guard notifyDate > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Vaccination Reminder"
            
            let daysText: String
            switch days {
            case 0:
                daysText = "today"
            case 1:
                daysText = "tomorrow"
            default:
                daysText = "in \(days) days"
            }
            
            content.body = "\(pet.name)'s \(vaccine.vaccineName) vaccination is due \(daysText)"
            content.sound = .default
            content.badge = 1
            content.userInfo = ["petId": pet.id.uuidString, "vaccineId": vaccine.id.uuidString, "type": "vaccine"]
            
            var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notifyDate)
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "\(pet.id.uuidString)-\(vaccine.id.uuidString)-\(days)days"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule vaccine reminder: \(error)")
                }
            }
        }
    }
    
    func scheduleMedicationReminder(for pet: Pet, medication: Medication) {
        let center = UNUserNotificationCenter.current()
        
        for (index, reminderTime) in medication.reminderTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "\(pet.name) needs \(medication.name) - \(medication.dosage)"
            content.sound = .default
            content.badge = 1
            content.userInfo = ["petId": pet.id.uuidString, "medicationId": medication.id.uuidString, "type": "medication"]
            
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let identifier = "\(pet.id.uuidString)-\(medication.id.uuidString)-\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule medication reminder: \(error)")
                }
            }
        }
    }
    
    func cancelVaccineReminders(for pet: Pet, vaccine: VaccineRecord) {
        let center = UNUserNotificationCenter.current()
        let daysToNotify = [7, 3, 1, 0]
        
        var identifiers: [String] = []
        for days in daysToNotify {
            identifiers.append("\(pet.id.uuidString)-\(vaccine.id.uuidString)-\(days)days")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelMedicationReminders(for pet: Pet, medication: Medication) {
        let center = UNUserNotificationCenter.current()
        
        var identifiers: [String] = []
        for index in 0..<medication.reminderTimes.count {
            identifiers.append("\(pet.id.uuidString)-\(medication.id.uuidString)-\(index)")
        }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllReminders(for pet: Pet) {
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.content.userInfo["petId"] as? String == pet.id.uuidString }
                .map { $0.identifier }
            
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to clear badge: \(error)")
            }
        }
    }
}
