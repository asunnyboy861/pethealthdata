import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    
    // MARK: - New Properties (Enhanced)
    private let permissionService = NotificationPermissionService.shared
    private let soundValidator = NotificationSoundValidator.shared
    
    private init() {}
    
    // MARK: - Authorization Methods (Enhanced)
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        permissionService.requestAuthorization(completion: completion)
    }
    
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        permissionService.refreshStatus()
        completion(permissionService.authorizationStatus)
    }
    
    // MARK: - Scheduling Methods (Enhanced)
    
    func scheduleVaccineReminder(for pet: Pet, vaccine: VaccineRecord) {
        // ✅ Enhanced: Verify authorization before scheduling
        guard permissionService.isAuthorized() else {
            print("⚠️ Cannot schedule vaccine reminder: Not authorized")
            return
        }
        
        guard let nextDueDate = vaccine.nextDueDate else {
            print("⚠️ Cannot schedule vaccine reminder: No due date")
            return
        }
        
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        // Use custom reminder days from vaccine record, fallback to defaults
        let daysToNotify = vaccine.reminderDaysBefore.isEmpty ? [30, 14, 7, 3, 1, 0] : vaccine.reminderDaysBefore
        
        for days in daysToNotify {
            let notifyDate = calendar.date(byAdding: .day, value: -days, to: nextDueDate) ?? nextDueDate
            
            guard notifyDate > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            
            let daysText: String
            switch days {
            case 0:
                daysText = "today"
            case 1:
                daysText = "tomorrow"
            case 3:
                daysText = "in 3 days"
            case 7:
                daysText = "in 1 week"
            case 14:
                daysText = "in 2 weeks"
            case 30:
                daysText = "in 1 month"
            default:
                daysText = "in \(days) days"
            }
            
            content.title = "🏥 \(pet.name)'s Vaccine Due"
            content.body = "\(vaccine.vaccineName) is due \(daysText). Don't forget to schedule the vet appointment!"
            content.badge = 1
            content.categoryIdentifier = "VACCINE_REMINDER"
            content.userInfo = [
                "petId": pet.id.uuidString,
                "vaccineId": vaccine.id.uuidString,
                "type": "vaccine",
                "petName": pet.name,
                "vaccineName": vaccine.vaccineName,
                "dueDate": nextDueDate.timeIntervalSince1970
            ]
            
            // Use custom reminder time from vaccine record
            let reminderTimeComponents = calendar.dateComponents([.hour, .minute], from: vaccine.reminderTime)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: notifyDate)
            dateComponents.hour = reminderTimeComponents.hour
            dateComponents.minute = reminderTimeComponents.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // ✅ Enhanced: Use sound validator to get notification sound (with fallback)
            content.sound = soundValidator.notificationSound(for: vaccine.notificationSound)
            
            let identifier = "\(pet.id.uuidString)-\(vaccine.id.uuidString)-\(days)days"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule vaccine reminder: \(error)")
                } else {
                    print("✅ Scheduled vaccine reminder: \(identifier)")
                }
            }
        }
        
        print("✅ Scheduled vaccine reminders for \(vaccine.vaccineName)")
    }
    
    func scheduleMedicationReminder(for pet: Pet, medication: Medication) {
        // ✅ Enhanced: Verify authorization before scheduling
        guard permissionService.isAuthorized() else {
            print("⚠️ Cannot schedule medication reminder: Not authorized")
            return
        }
        
        // ✅ Enhanced: Verify reminder times
        guard !medication.reminderTimes.isEmpty else {
            print("⚠️ Cannot schedule medication reminder: No reminder times")
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        for (index, reminderTime) in medication.reminderTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "💊 Time for \(pet.name)'s Medication"
            content.body = "\(medication.name) - \(medication.dosage). Tap to mark as given."
            content.badge = 1
            content.categoryIdentifier = "MEDICATION_REMINDER"
            content.userInfo = [
                "petId": pet.id.uuidString,
                "medicationId": medication.id.uuidString,
                "type": "medication",
                "petName": pet.name,
                "medicationName": medication.name,
                "dosage": medication.dosage
            ]
            
            // ✅ Enhanced: Use sound validator to get notification sound (with fallback)
            content.sound = soundValidator.notificationSound(for: medication.notificationSound)
            
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let identifier = "\(pet.id.uuidString)-\(medication.id.uuidString)-\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule medication reminder: \(error)")
                } else {
                    print("✅ Scheduled medication reminder: \(identifier)")
                }
            }
        }
        
        print("✅ Scheduled medication reminders for \(medication.name)")
    }
    
    func cancelVaccineReminders(for pet: Pet, vaccine: VaccineRecord) {
        let center = UNUserNotificationCenter.current()
        let daysToNotify = [30, 14, 7, 3, 1, 0]
        
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
    
    func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        let vaccineAction = UNNotificationAction(identifier: "SCHEDULE_VET", title: "Schedule Vet", options: .foreground)
        let vaccineCategory = UNNotificationCategory(identifier: "VACCINE_REMINDER", actions: [vaccineAction], intentIdentifiers: [])
        
        let markGivenAction = UNNotificationAction(identifier: "MARK_GIVEN", title: "Mark as Given", options: .foreground)
        let medicationCategory = UNNotificationCategory(identifier: "MEDICATION_REMINDER", actions: [markGivenAction], intentIdentifiers: [])
        
        center.setNotificationCategories([vaccineCategory, medicationCategory])
    }
}
