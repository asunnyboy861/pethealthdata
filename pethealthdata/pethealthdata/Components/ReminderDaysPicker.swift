import SwiftUI

/// Reminder days picker for selecting advance notification days
struct ReminderDaysPicker: View {
    @Binding var selectedDays: [Int]
    
    private let options = VaccineReminderConfig.ReminderTimeOption.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(options) { option in
                HStack {
                    Text(option.displayName)
                    Spacer()
                    Image(systemName: selectedDays.contains(option.days) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.accentColor)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleDay(option.days)
                }
            }
        }
    }
    
    private func toggleDay(_ days: Int) {
        if selectedDays.contains(days) {
            selectedDays.removeAll { $0 == days }
        } else {
            selectedDays.append(days)
            selectedDays.sort()
        }
    }
}

#Preview {
    ReminderDaysPicker(selectedDays: .constant([30, 14, 7, 3, 1, 0]))
}