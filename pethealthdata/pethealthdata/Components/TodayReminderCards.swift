import SwiftUI
import SwiftData

/// Today's vaccine reminder card
struct TodayVaccineCard: View {
    let vaccine: VaccineRecord
    let pet: Pet?
    @State private var isCompleted: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Left icon
            VStack(spacing: 4) {
                Image(systemName: "syringe")
                    .font(.system(size: 20))
                    .foregroundColor(.appPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(10)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.appSuccess)
                }
            }
            
            // Middle content
            VStack(alignment: .leading, spacing: 4) {
                Text(vaccine.vaccineName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                if let pet = pet {
                    Text("For \(pet.name)")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }
                
                if let dueDate = vaccine.nextDueDate {
                    Text(dueDate.formattedRelative)
                        .font(.system(size: 12))
                        .foregroundColor(isOverdue ? .appError : .appTextSecondary)
                }
            }
            
            Spacer()
            
            // Right action
            Button(action: toggleComplete) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .appSuccess : .appTextSecondary)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .opacity(isCompleted ? 0.6 : 1.0)
    }
    
    private var isOverdue: Bool {
        guard let dueDate = vaccine.nextDueDate else { return false }
        return dueDate < Date()
    }
    
    private func toggleComplete() {
        withAnimation {
            isCompleted.toggle()
        }
    }
}

/// Today's medication reminder card
struct TodayMedicationCard: View {
    let medication: Medication
    let pet: Pet?
    @State private var isTaken: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Left icon
            VStack(spacing: 4) {
                Image(systemName: medication.frequencyIcon)
                    .font(.system(size: 20))
                    .foregroundColor(.appWarning)
                    .frame(width: 40, height: 40)
                    .background(Color.appWarning.opacity(0.1))
                    .cornerRadius(10)
                
                if isTaken {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.appSuccess)
                }
            }
            
            // Middle content
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: 8) {
                    Text(medication.dosage)
                        .font(.system(size: 13))
                    Text("•")
                        .font(.system(size: 10))
                    Text(medication.frequencyText)
                        .font(.system(size: 13))
                }
                .foregroundColor(.appTextSecondary)
                
                if let pet = pet {
                    Text("For \(pet.name)")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            Spacer()
            
            // Right action
            Button(action: toggleTaken) {
                Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isTaken ? .appSuccess : .appTextSecondary)
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .opacity(isTaken ? 0.6 : 1.0)
    }
    
    private func toggleTaken() {
        withAnimation {
            isTaken.toggle()
        }
    }
}

/// Upcoming reminder card
struct UpcomingReminderCard: View {
    let reminder: UpcomingReminder
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.typeIcon)
                .font(.system(size: 18))
                .foregroundColor(reminder.typeColor)
                .frame(width: 36, height: 36)
                .background(reminder.typeColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                
                Text("\(reminder.subtitle) • \(reminder.petName)")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            Text(reminder.date.formattedRelative)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Helper Extensions
extension UpcomingReminder {
    var typeIcon: String {
        switch type {
        case .vaccine: return "syringe"
        case .medication: return "pills.fill"
        case .weight: return "scale"
        case .event: return "star"
        }
    }
    
    var typeColor: Color {
        switch type {
        case .vaccine: return .appPrimary
        case .medication: return .appWarning
        case .weight: return .appInfo
        case .event: return .appAccent
        }
    }
}

// MARK: - Date Extension for Relative Formatting
extension Date {
    var formattedRelative: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: self)
        
        if calendar.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: self)
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if let days = components.day, days <= 7 {
            return "In \(days) day\(days == 1 ? "" : "s")"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TodayVaccineCard(
            vaccine: VaccineRecord(vaccineName: "Rabies", vaccinationDate: Date()),
            pet: Pet(name: "Buddy", species: "dog")
        )
        
        TodayMedicationCard(
            medication: Medication(name: "Heartgard", dosage: "1 tablet", frequency: "daily"),
            pet: Pet(name: "Buddy", species: "dog")
        )
        
        UpcomingReminderCard(
            reminder: UpcomingReminder(
                id: UUID(),
                title: "DHPP Booster",
                subtitle: "Vaccine due",
                date: Date().addingTimeInterval(86400 * 2),
                type: .vaccine,
                petName: "Buddy"
            )
        )
    }
    .padding()
    .background(Color.appBackground)
}