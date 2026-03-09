import Foundation
import SwiftData

@Model
final class HealthEvent {
    var id: UUID
    var eventType: String
    var title: String
    var eventDescription: String?
    var date: Date
    var attachmentsData: [Data]?
    var createdAt: Date
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        eventType: String = "other",
        title: String = "",
        eventDescription: String? = nil,
        date: Date = Date(),
        attachmentsData: [Data]? = nil,
        createdAt: Date = Date(),
        pet: Pet? = nil
    ) {
        self.id = id
        self.eventType = eventType
        self.title = title
        self.eventDescription = eventDescription
        self.date = date
        self.attachmentsData = attachmentsData
        self.createdAt = createdAt
        self.pet = pet
    }
    
    var eventTypeIcon: String {
        switch eventType {
        case "checkup": return "stethoscope"
        case "vaccination": return "syringe"
        case "medication": return "pills.fill"
        case "grooming": return "scissors"
        case "surgery": return "cross.case"
        case "emergency": return "exclamationmark.triangle.fill"
        case "other": return "heart.fill"
        default: return "heart.fill"
        }
    }
    
    var eventTypeColor: String {
        switch eventType {
        case "checkup": return "34C759"
        case "vaccination": return "0A84FF"
        case "medication": return "FF9500"
        case "grooming": return "FF6B9D"
        case "surgery": return "FF3B30"
        case "emergency": return "FF3B30"
        case "other": return "6B7280"
        default: return "6B7280"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static let eventTypes: [(type: String, name: String, icon: String)] = [
        ("checkup", "Checkup", "stethoscope"),
        ("vaccination", "Vaccination", "syringe"),
        ("medication", "Medication", "pills.fill"),
        ("grooming", "Grooming", "scissors"),
        ("surgery", "Surgery", "cross.case"),
        ("emergency", "Emergency", "exclamationmark.triangle.fill"),
        ("other", "Other", "heart.fill")
    ]
}
