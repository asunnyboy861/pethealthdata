import SwiftUI
import SwiftData
import Charts

struct VaccineRowView: View {
    let vaccine: VaccineRecord
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "syringe")
                .font(.system(size: 20))
                .foregroundColor(.appPrimary)
                .frame(width: 40, height: 40)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vaccine.vaccineName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: 8) {
                    Text(vaccine.vaccinationDate.formattedMedium)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                    
                    if vaccine.nextDueDate != nil {
                        Text("•")
                            .foregroundColor(.appTextSecondary)
                        statusBadge
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.appError)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        if vaccine.isOverdue {
            Text("Overdue")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appError)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.appError.opacity(0.15))
                .cornerRadius(6)
        } else if let days = vaccine.daysUntilDue {
            if days <= 7 {
                Text("Due in \(days)d")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.appWarning)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appWarning.opacity(0.15))
                    .cornerRadius(6)
            }
        }
    }
}

struct MedicationRowView: View {
    let medication: Medication
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: medication.frequencyIcon)
                .font(.system(size: 20))
                .foregroundColor(medication.isActive ? .appWarning : .appTextSecondary)
                .frame(width: 40, height: 40)
                .background((medication.isActive ? Color.appWarning : Color.appTextSecondary).opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(medication.isActive ? .appTextPrimary : .appTextSecondary)
                
                HStack(spacing: 8) {
                    Text(medication.dosage)
                        .font(.system(size: 13))
                    
                    Text("•")
                    
                    Text(medication.frequencyText)
                        .font(.system(size: 13))
                }
                .foregroundColor(.appTextSecondary)
                
                if !medication.isActive {
                    Text("Inactive")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: medication.isActive ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(medication.isActive ? .appWarning : .appSuccess)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.appError)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct WeightRowView: View {
    let record: WeightRecord
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "scalemass")
                .font(.system(size: 20))
                .foregroundColor(.appSuccess)
                .frame(width: 40, height: 40)
                .background(Color.appSuccess.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.weightString)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text(record.formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.appError)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct HealthEventRowView: View {
    let event: HealthEvent
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.eventTypeIcon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: event.eventTypeColor))
                .frame(width: 40, height: 40)
                .background(Color(hex: event.eventTypeColor).opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                Text(event.formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.appTextSecondary)
                
                if let description = event.eventDescription {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.appError)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct WeightChartView: View {
    let records: [WeightRecord]
    
    var body: some View {
        if records.count >= 2 {
            Chart(records.sorted(by: { $0.date < $1.date })) { record in
                LineMark(
                    x: .value("Date", record.date),
                    y: .value("Weight", record.weight)
                )
                .foregroundStyle(Color.appPrimary)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", record.date),
                    y: .value("Weight", record.weight)
                )
                .foregroundStyle(Color.appPrimary)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        } else {
            Text("Add at least 2 weight records to see trends")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack(spacing: 16) {
        VaccineRowView(
            vaccine: VaccineRecord(vaccineName: "Rabies", vaccinationDate: Date()),
            onDelete: {}
        )
        
        MedicationRowView(
            medication: Medication(name: "Heartgard", dosage: "1 tablet", frequency: "daily"),
            onToggle: {},
            onDelete: {}
        )
        
        WeightRowView(
            record: WeightRecord(weight: 25.5, weightUnit: "lbs", date: Date()),
            onDelete: {}
        )
        
        HealthEventRowView(
            event: HealthEvent(eventType: "checkup", title: "Annual Checkup", date: Date()),
            onDelete: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}
