import Foundation
import SwiftData

@Model
final class Pet {
    var id: UUID
    var name: String
    var species: String
    var breed: String?
    var birthDate: Date?
    var weight: Double
    var photoData: Data?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \VaccineRecord.pet)
    var vaccines: [VaccineRecord] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Medication.pet)
    var medications: [Medication] = []
    
    @Relationship(deleteRule: .cascade, inverse: \WeightRecord.pet)
    var weightRecords: [WeightRecord] = []
    
    @Relationship(deleteRule: .cascade, inverse: \HealthEvent.pet)
    var healthEvents: [HealthEvent] = []
    
    init(
        id: UUID = UUID(),
        name: String = "",
        species: String = "dog",
        breed: String? = nil,
        birthDate: Date? = nil,
        weight: Double = 0.0,
        photoData: Data? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.birthDate = birthDate
        self.weight = weight
        self.photoData = photoData
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var age: String {
        guard let birthDate = birthDate else { return "Unknown" }
        let calendar = Calendar.current
        let years = calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        let months = calendar.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
        
        if years > 0 {
            return "\(years) year\(years == 1 ? "" : "s") old"
        } else if months > 0 {
            return "\(months) month\(months == 1 ? "" : "s") old"
        } else {
            return "Less than 1 month"
        }
    }
    
    var speciesIcon: String {
        switch species.lowercased() {
        case "dog": return "dog.fill"
        case "cat": return "cat.fill"
        case "bird": return "bird.fill"
        default: return "pawprint.fill"
        }
    }
    
    var speciesColor: String {
        switch species.lowercased() {
        case "dog": return "0A84FF"
        case "cat": return "FF6B9D"
        case "bird": return "34C759"
        default: return "FFA726"
        }
    }
    
    var upcomingVaccinesCount: Int {
        let calendar = Calendar.current
        let thirtyDaysFromNow = calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        
        return vaccines.filter { vaccine in
            guard let nextDueDate = vaccine.nextDueDate else { return false }
            return nextDueDate >= Date() && nextDueDate <= thirtyDaysFromNow
        }.count
    }
    
    var activeMedicationsCount: Int {
        medications.filter { $0.isActive }.count
    }
}
