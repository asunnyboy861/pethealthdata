import Foundation
import UIKit

final class PDFExportService {
    static let shared = PDFExportService()
    
    private init() {}
    
    func generateHealthReport(for pet: Pet, dateRange: DateRange = .allTime) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - (margin * 2)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "PetHealthData",
            kCGPDFContextAuthor: "PetHealthData App",
            kCGPDFContextTitle: "\(pet.name) Health Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let filteredVaccines: [VaccineRecord]
        let filteredMedications: [Medication]
        let filteredWeightRecords: [WeightRecord]
        let filteredEvents: [HealthEvent]
        
        switch dateRange {
        case .lastThreeMonths:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            filteredVaccines = pet.vaccines.filter { $0.vaccinationDate >= threeMonthsAgo }
            filteredMedications = pet.medications.filter { $0.startDate >= threeMonthsAgo }
            filteredWeightRecords = pet.weightRecords.filter { $0.date >= threeMonthsAgo }
            filteredEvents = pet.healthEvents.filter { $0.date >= threeMonthsAgo }
        case .lastSixMonths:
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            filteredVaccines = pet.vaccines.filter { $0.vaccinationDate >= sixMonthsAgo }
            filteredMedications = pet.medications.filter { $0.startDate >= sixMonthsAgo }
            filteredWeightRecords = pet.weightRecords.filter { $0.date >= sixMonthsAgo }
            filteredEvents = pet.healthEvents.filter { $0.date >= sixMonthsAgo }
        case .lastYear:
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            filteredVaccines = pet.vaccines.filter { $0.vaccinationDate >= oneYearAgo }
            filteredMedications = pet.medications.filter { $0.startDate >= oneYearAgo }
            filteredWeightRecords = pet.weightRecords.filter { $0.date >= oneYearAgo }
            filteredEvents = pet.healthEvents.filter { $0.date >= oneYearAgo }
        case .allTime:
            filteredVaccines = pet.vaccines
            filteredMedications = pet.medications
            filteredWeightRecords = pet.weightRecords
            filteredEvents = pet.healthEvents
        }
        
        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = margin
            
            yPosition = drawHeader(pet: pet, yPosition: yPosition, margin: margin, width: contentWidth)
            yPosition = drawPetInfo(pet: pet, yPosition: yPosition, margin: margin, width: contentWidth)
            yPosition = drawVaccineSection(vaccines: filteredVaccines, yPosition: yPosition, margin: margin, width: contentWidth, context: context, pageHeight: pageHeight, pageWidth: pageWidth)
            yPosition = drawMedicationSection(medications: filteredMedications, yPosition: yPosition, margin: margin, width: contentWidth, context: context, pageHeight: pageHeight, pageWidth: pageWidth)
            yPosition = drawWeightSection(weightRecords: filteredWeightRecords, yPosition: yPosition, margin: margin, width: contentWidth, context: context, pageHeight: pageHeight, pageWidth: pageWidth)
            yPosition = drawHealthEventsSection(events: filteredEvents, yPosition: yPosition, margin: margin, width: contentWidth, context: context, pageHeight: pageHeight, pageWidth: pageWidth)
            
            drawFooter(pageRect: pageRect)
        }
        
        return data
    }
    
    private func drawHeader(pet: Pet, yPosition: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        var y = yPosition
        
        let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let title = "Pet Health Report"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 1)
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
        y += 35
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = "Generated: \(dateFormatter.string(from: Date()))"
        let dateFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor.gray
        ]
        dateString.draw(at: CGPoint(x: margin, y: y), withAttributes: dateAttributes)
        y += 30
        
        return y
    }
    
    private func drawPetInfo(pet: Pet, yPosition: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        var y = yPosition
        
        let headerFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        "Pet Information".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
        y += 25
        
        let infoFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: infoFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let info = [
            "Name: \(pet.name)",
            "Species: \(pet.species.capitalized)",
            "Breed: \(pet.breed ?? "Not specified")",
            "Age: \(pet.age)",
            "Current Weight: \(String(format: "%.1f", pet.weight)) lbs"
        ]
        
        for line in info {
            line.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
            y += 18
        }
        
        y += 10
        return y
    }
    
    private func drawVaccineSection(vaccines: [VaccineRecord], yPosition: CGFloat, margin: CGFloat, width: CGFloat, context: UIGraphicsPDFRendererContext, pageHeight: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var y = yPosition
        
        if y > pageHeight - 200 {
            context.beginPage()
            y = 50
        }
        
        let headerFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        "Vaccination Records".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
        y += 25
        
        let infoFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: infoFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        if vaccines.isEmpty {
            "No vaccination records".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
            y += 20
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            for vaccine in vaccines {
                if y > pageHeight - 50 {
                    context.beginPage()
                    y = 50
                }
                
                var vaccineInfo = "\(vaccine.vaccineName) - \(dateFormatter.string(from: vaccine.vaccinationDate))"
                if let nextDate = vaccine.nextDueDate {
                    vaccineInfo += " (Next: \(dateFormatter.string(from: nextDate)))"
                }
                vaccineInfo.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
                y += 16
            }
        }
        
        return y + 10
    }
    
    private func drawMedicationSection(medications: [Medication], yPosition: CGFloat, margin: CGFloat, width: CGFloat, context: UIGraphicsPDFRendererContext, pageHeight: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var y = yPosition
        
        if y > pageHeight - 200 {
            context.beginPage()
            y = 50
        }
        
        let headerFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        "Medication Records".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
        y += 25
        
        let infoFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: infoFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        if medications.isEmpty {
            "No medication records".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
            y += 20
        } else {
            for medication in medications {
                if y > pageHeight - 50 {
                    context.beginPage()
                    y = 50
                }
                
                let status = medication.isActive ? "(Active)" : "(Inactive)"
                let medInfo = "\(medication.name) - \(medication.dosage) - \(medication.frequencyText) \(status)"
                medInfo.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
                y += 16
            }
        }
        
        return y + 10
    }
    
    private func drawWeightSection(weightRecords: [WeightRecord], yPosition: CGFloat, margin: CGFloat, width: CGFloat, context: UIGraphicsPDFRendererContext, pageHeight: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var y = yPosition
        
        if y > pageHeight - 200 {
            context.beginPage()
            y = 50
        }
        
        let headerFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        "Weight Records".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
        y += 25
        
        let infoFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: infoFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        if weightRecords.isEmpty {
            "No weight records".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
            y += 20
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            for record in weightRecords.sorted(by: { $0.date > $1.date }) {
                if y > pageHeight - 50 {
                    context.beginPage()
                    y = 50
                }
                
                let weightInfo = "\(dateFormatter.string(from: record.date)): \(record.weightString)"
                weightInfo.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
                y += 16
            }
        }
        
        return y + 10
    }
    
    private func drawHealthEventsSection(events: [HealthEvent], yPosition: CGFloat, margin: CGFloat, width: CGFloat, context: UIGraphicsPDFRendererContext, pageHeight: CGFloat, pageWidth: CGFloat) -> CGFloat {
        var y = yPosition
        
        if y > pageHeight - 200 {
            context.beginPage()
            y = 50
        }
        
        let headerFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        "Health Events".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttributes)
        y += 25
        
        let infoFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: infoFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        if events.isEmpty {
            "No health events".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            for event in events.sorted(by: { $0.date > $1.date }) {
                if y > pageHeight - 50 {
                    context.beginPage()
                    y = 50
                }
                
                let eventInfo = "\(dateFormatter.string(from: event.date)): \(event.title) (\(event.eventType))"
                eventInfo.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: infoAttributes)
                y += 16
            }
        }
        
        return y + 10
    }
    
    private func drawFooter(pageRect: CGRect) {
        let footerFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.gray
        ]
        let footer = "Generated by PetHealthData App"
        let footerSize = footer.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (pageRect.width - footerSize.width) / 2,
            y: pageRect.height - 30,
            width: footerSize.width,
            height: footerSize.height
        )
        footer.draw(in: footerRect, withAttributes: footerAttributes)
    }
    
    enum DateRange: String, CaseIterable, Identifiable {
        case lastThreeMonths = "Last 3 Months"
        case lastSixMonths = "Last 6 Months"
        case lastYear = "Last 1 Year"
        case allTime = "All Time"
        
        var id: String { rawValue }
    }
}
