import Foundation
import SwiftData
import Combine

/// Today's reminder view model
@MainActor
class TodayViewModel: ObservableObject {
    @Published var todayVaccines: [VaccineRecord] = []
    @Published var todayMedications: [Medication] = []
    @Published var upcomingReminders: [UpcomingReminder] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Load today's reminders
    func loadTodaysReminders() {
        isLoading = true
        errorMessage = nil
        
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let endOfToday = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: today) ?? today
            
            // Load today's vaccines - fetch all and filter in Swift
            let vaccineDescriptor = FetchDescriptor<VaccineRecord>()
            let allVaccines = try modelContext.fetch(vaccineDescriptor)
            todayVaccines = allVaccines.filter { vaccine in
                guard let nextDueDate = vaccine.nextDueDate else { return false }
                return nextDueDate >= today && nextDueDate < endOfToday
            }
            
            // Load today's medications
            let medicationDescriptor = FetchDescriptor<Medication>(
                predicate: #Predicate { medication in
                    return medication.isActive
                }
            )
            let allMedications = try modelContext.fetch(medicationDescriptor)
            todayMedications = allMedications.filter { medication in
                guard medication.startDate <= today else { return false }
                
                if let endDate = medication.endDate {
                    guard endDate >= today else { return false }
                }
                
                // Check if medication is due today based on frequency
                return medication.isDueToday(today: today)
            }
            
            // Load upcoming reminders
            upcomingReminders = loadUpcomingReminders(until: threeDaysFromNow)
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func loadUpcomingReminders(until date: Date) -> [UpcomingReminder] {
        var reminders: [UpcomingReminder] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        do {
            // Upcoming vaccines (within 3 days) - fetch all and filter in Swift
            let upcomingVaccineDescriptor = FetchDescriptor<VaccineRecord>()
            let allVaccines = try modelContext.fetch(upcomingVaccineDescriptor)
            let upcomingVaccines = allVaccines.filter { vaccine in
                guard let nextDueDate = vaccine.nextDueDate else { return false }
                return nextDueDate > today && nextDueDate <= date
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
            
            // Upcoming medication end dates - fetch all and filter in Swift
            let upcomingMedsDescriptor = FetchDescriptor<Medication>()
            let allMedications = try modelContext.fetch(upcomingMedsDescriptor)
            let upcomingMeds = allMedications.filter { medication in
                guard let endDate = medication.endDate else { return false }
                return endDate > today && endDate <= date && medication.isActive
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
        } catch {
            print("Error loading upcoming reminders: \(error)")
        }
        
        return reminders.sorted { $0.date < $1.date }
    }
    
    /// Mark vaccine as completed
    func markVaccineAsCompleted(_ vaccine: VaccineRecord) {
        // Update vaccine record if needed
    }
    
    /// Mark medication as taken
    func markMedicationAsTaken(_ medication: Medication, at time: Date) {
        medication.lastTaken = time
        try? modelContext.save()
    }
}

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