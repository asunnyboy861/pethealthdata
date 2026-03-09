import Foundation
import SwiftData

@Model
final class VaccineRecord {
    var id: UUID
    var vaccineName: String
    var vaccinationDate: Date
    var nextDueDate: Date?
    var veterinarian: String?
    var notes: String?
    var createdAt: Date
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        vaccineName: String = "",
        vaccinationDate: Date = Date(),
        nextDueDate: Date? = nil,
        veterinarian: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        pet: Pet? = nil
    ) {
        self.id = id
        self.vaccineName = vaccineName
        self.vaccinationDate = vaccinationDate
        self.nextDueDate = nextDueDate
        self.veterinarian = veterinarian
        self.notes = notes
        self.createdAt = createdAt
        self.pet = pet
    }
    
    var isOverdue: Bool {
        guard let nextDueDate = nextDueDate else { return false }
        return nextDueDate < Date()
    }
    
    var daysUntilDue: Int? {
        guard let nextDueDate = nextDueDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: nextDueDate).day
    }
    
    var statusText: String {
        if isOverdue {
            return "Overdue"
        } else if let days = daysUntilDue {
            if days == 0 {
                return "Due today"
            } else if days == 1 {
                return "Due tomorrow"
            } else if days <= 7 {
                return "Due in \(days) days"
            } else if days <= 30 {
                return "Due in \(days) days"
            } else {
                return "Scheduled"
            }
        } else {
            return "No reminder set"
        }
    }
    
    static let commonVaccines: [(name: String, intervalMonths: Int)] = [
        ("Rabies", 12),
        ("DHPP (Distemper)", 12),
        ("Bordetella (Kennel Cough)", 6),
        ("Lyme Disease", 12),
        ("Leptospirosis", 12),
        ("Canine Influenza", 12),
        ("FVRCP (Cat Vaccine)", 12),
        ("FeLV (Feline Leukemia)", 12),
        ("FIV (Feline Immunodeficiency)", 12)
    ]
}
