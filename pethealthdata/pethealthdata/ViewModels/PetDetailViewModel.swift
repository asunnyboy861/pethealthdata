import Foundation
import SwiftData
import SwiftUI

@Observable
final class PetDetailViewModel {
    var pet: Pet
    var showingAddVaccine: Bool = false
    var showingAddMedication: Bool = false
    var showingAddWeight: Bool = false
    var showingAddEvent: Bool = false
    var showingEditPet: Bool = false
    var selectedTab: Int = 0
    
    private var modelContext: ModelContext?
    
    init(pet: Pet) {
        self.pet = pet
    }
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func refreshPet() {
        // SwiftData automatically updates @Query and @Bindable views
        // No manual refresh needed
    }
    
    func addVaccine(_ vaccine: VaccineRecord) {
        guard let modelContext = modelContext else { return }
        vaccine.pet = pet
        modelContext.insert(vaccine)
        pet.vaccines.append(vaccine)
        try? modelContext.save()
    }
    
    func deleteVaccine(_ vaccine: VaccineRecord) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(vaccine)
        if let index = pet.vaccines.firstIndex(where: { $0.id == vaccine.id }) {
            pet.vaccines.remove(at: index)
        }
        try? modelContext.save()
    }
    
    func addMedication(_ medication: Medication) {
        guard let modelContext = modelContext else { return }
        medication.pet = pet
        modelContext.insert(medication)
        pet.medications.append(medication)
        try? modelContext.save()
    }
    
    func deleteMedication(_ medication: Medication) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(medication)
        if let index = pet.medications.firstIndex(where: { $0.id == medication.id }) {
            pet.medications.remove(at: index)
        }
        try? modelContext.save()
    }
    
    func toggleMedicationActive(_ medication: Medication) {
        medication.isActive.toggle()
        try? modelContext?.save()
    }
    
    func addWeightRecord(_ weightRecord: WeightRecord) {
        guard let modelContext = modelContext else { return }
        weightRecord.pet = pet
        modelContext.insert(weightRecord)
        pet.weightRecords.append(weightRecord)
        try? modelContext.save()
    }
    
    func deleteWeightRecord(_ weightRecord: WeightRecord) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(weightRecord)
        if let index = pet.weightRecords.firstIndex(where: { $0.id == weightRecord.id }) {
            pet.weightRecords.remove(at: index)
        }
        try? modelContext.save()
    }
    
    func addHealthEvent(_ event: HealthEvent) {
        guard let modelContext = modelContext else { return }
        event.pet = pet
        modelContext.insert(event)
        pet.healthEvents.append(event)
        try? modelContext.save()
    }
    
    func deleteHealthEvent(_ event: HealthEvent) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(event)
        if let index = pet.healthEvents.firstIndex(where: { $0.id == event.id }) {
            pet.healthEvents.remove(at: index)
        }
        try? modelContext.save()
    }
    
    var sortedVaccines: [VaccineRecord] {
        pet.vaccines.sorted { $0.vaccinationDate > $1.vaccinationDate }
    }
    
    var sortedMedications: [Medication] {
        pet.medications.sorted { $0.createdAt > $1.createdAt }
    }
    
    var sortedWeightRecords: [WeightRecord] {
        pet.weightRecords.sorted { $0.date > $1.date }
    }
    
    var sortedHealthEvents: [HealthEvent] {
        pet.healthEvents.sorted { $0.date > $1.date }
    }
    
    var upcomingVaccines: [VaccineRecord] {
        pet.vaccines.filter { !$0.isOverdue && ($0.daysUntilDue ?? Int.max) <= 30 }
            .sorted { ($0.daysUntilDue ?? Int.max) < ($1.daysUntilDue ?? Int.max) }
    }
    
    var overdueVaccines: [VaccineRecord] {
        pet.vaccines.filter { $0.isOverdue }
    }
    
    var activeMedications: [Medication] {
        pet.medications.filter { $0.isActive }
    }
    
    var weightChangePercentage: Double? {
        let sorted = sortedWeightRecords
        guard sorted.count >= 2 else { return nil }
        let latest = sorted[0].weight
        let previous = sorted[1].weight
        guard previous > 0 else { return nil }
        return ((latest - previous) / previous) * 100
    }
}
