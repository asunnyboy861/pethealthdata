import Foundation
import SwiftData

/// Today's reminder view model (Refactored to use @Observable)
@Observable
@MainActor
final class TodayViewModel {
    // MARK: - Properties
    
    var todayVaccines: [VaccineRecord] = []
    var todayMedications: [Medication] = []
    var upcomingReminders: [UpcomingReminder] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    /// Load today's reminders
    func loadTodaysReminders() {
        isLoading = true
        errorMessage = nil
        
        do {
            let today = calendar.startOfDay(for: Date())
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: today) ?? today
            
            // Load today's vaccines using predicate for better performance
            try loadTodayVaccines(today: today, endOfToday: endOfToday)
            
            // Load today's medications using predicate for better performance
            try loadTodayMedications(today: today)
            
            // Load upcoming reminders
            loadUpcomingReminders(today: today, until: threeDaysFromNow)
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Failed to load today's reminders: \(error)")
        }
    }
    
    /// Mark vaccine as completed
    func markVaccineAsCompleted(_ vaccine: VaccineRecord) {
        // Update vaccine record if needed based on business logic
    }
    
    /// Mark medication as taken
    func markMedicationAsTaken(_ medication: Medication, at time: Date) {
        medication.lastTaken = time
        try? modelContext.save()
    }
    
    /// Refresh data
    func refresh() {
        loadTodaysReminders()
    }
    
    // MARK: - Private Methods
    
    /// Load today's vaccines
    private func loadTodayVaccines(today: Date, endOfToday: Date) throws {
        // Fetch all vaccines and filter in memory (predicate doesn't support optional comparison)
        let descriptor = FetchDescriptor<VaccineRecord>()
        let allVaccines = try modelContext.fetch(descriptor)
        
        todayVaccines = allVaccines.filter { vaccine in
            guard let nextDueDate = vaccine.nextDueDate else { return false }
            return nextDueDate >= today && nextDueDate < endOfToday
        }
        
        print("✅ Loaded \(todayVaccines.count) vaccines due today")
    }
    
    /// Load today's medications
    private func loadTodayMedications(today: Date) throws {
        // Use predicate to filter active medications
        let predicate = #Predicate<Medication> { medication in
            return medication.isActive && medication.startDate <= today
        }
        
        let descriptor = FetchDescriptor<Medication>(predicate: predicate)
        let allMedications = try modelContext.fetch(descriptor)
        
        // Further filter in memory (complex logic)
        todayMedications = allMedications.filter { medication in
            // 1. Check end date
            if let endDate = medication.endDate, endDate < today {
                return false
            }
            
            // 2. Check if already taken today
            if let lastTaken = medication.lastTaken {
                let lastTakenDay = calendar.startOfDay(for: lastTaken)
                if lastTakenDay >= today {
                    // Already taken today
                    return false
                }
            }
            
            // 3. Check if due today
            return medication.isDueToday(today: today)
        }
        
        print("✅ Loaded \(todayMedications.count) medications due today")
    }
    
    /// Load upcoming reminders
    private func loadUpcomingReminders(today: Date, until: Date) {
        var reminders: [UpcomingReminder] = []
        
        do {
            // 1. Upcoming vaccines (fetch all and filter in memory)
            let vaccineDescriptor = FetchDescriptor<VaccineRecord>()
            let allVaccines = try modelContext.fetch(vaccineDescriptor)
            let upcomingVaccines = allVaccines.filter { vaccine in
                guard let nextDueDate = vaccine.nextDueDate else { return false }
                return nextDueDate > today && nextDueDate <= until
            }
            
            for vaccine in upcomingVaccines {
                reminders.append(UpcomingReminder(
                    id: UUID(),
                    title: vaccine.vaccineName,
                    subtitle: "Vaccine due",
                    date: vaccine.nextDueDate!,
                    type: .vaccine,
                    petName: vaccine.pet?.name ?? "Unknown"
                ))
            }
            
            // 2. Upcoming medication end dates (fetch all and filter in memory)
            let medicationDescriptor = FetchDescriptor<Medication>()
            let allMedications = try modelContext.fetch(medicationDescriptor)
            let upcomingMeds = allMedications.filter { medication in
                guard let endDate = medication.endDate else { return false }
                return endDate > today && endDate <= until && medication.isActive
            }
            
            for med in upcomingMeds {
                reminders.append(UpcomingReminder(
                    id: UUID(),
                    title: med.name,
                    subtitle: "Medication ends",
                    date: med.endDate!,
                    type: .medication,
                    petName: med.pet?.name ?? "Unknown"
                ))
            }
            
            // 3. Sort by date
            upcomingReminders = reminders.sorted { $0.date < $1.date }
            
            print("✅ Loaded \(upcomingReminders.count) upcoming reminders")
        } catch {
            print("⚠️ Error loading upcoming reminders: \(error)")
        }
    }
}

// MARK: - Upcoming Reminder Model

/// Upcoming reminder model
struct UpcomingReminder: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let date: Date
    let type: ReminderType
    let petName: String
    
    enum ReminderType {
        case vaccine
        case medication
        case weight
        case event
    }
}
