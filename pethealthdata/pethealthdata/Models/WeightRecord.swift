import Foundation
import SwiftData

@Model
final class WeightRecord {
    var id: UUID
    var weight: Double
    var weightUnit: String
    var date: Date
    var notes: String?
    var createdAt: Date
    var pet: Pet?
    
    init(
        id: UUID = UUID(),
        weight: Double = 0.0,
        weightUnit: String = "lbs",
        date: Date = Date(),
        notes: String? = nil,
        createdAt: Date = Date(),
        pet: Pet? = nil
    ) {
        self.id = id
        self.weight = weight
        self.weightUnit = weightUnit
        self.date = date
        self.notes = notes
        self.createdAt = createdAt
        self.pet = pet
    }
    
    var weightString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        let value = formatter.string(from: NSNumber(value: weight)) ?? "\(weight)"
        return "\(value) \(weightUnit)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
