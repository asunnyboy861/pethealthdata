import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pet: Pet
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: String = "daily"
    @State private var startDate: Date = Date()
    @State private var hasEndDate: Bool = false
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var enableReminder: Bool = true
    @State private var notes: String = ""
    
    let frequencyOptions = [
        ("daily", "Daily"),
        ("twice_daily", "Twice Daily"),
        ("three_times_daily", "Three Times Daily"),
        ("weekly", "Weekly"),
        ("as_needed", "As Needed")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Medication Information") {
                    TextField("Medication Name", text: $name)
                    
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencyOptions, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }
                }
                
                Section("Schedule") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                    
                    Toggle("Enable Reminder", isOn: $enableReminder)
                    
                    if enableReminder && frequency != "as_needed" {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
    
    private func saveMedication() {
        var reminderTimes: [Date] = []
        if enableReminder && frequency != "as_needed" {
            reminderTimes = [reminderTime]
        }
        
        let medication = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            reminderTimes: reminderTimes,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            notes: notes.isEmpty ? nil : notes,
            isActive: true,
            pet: pet
        )
        
        modelContext.insert(medication)
        pet.medications.append(medication)
        
        if enableReminder && frequency != "as_needed" {
            NotificationService.shared.scheduleMedicationReminder(for: pet, medication: medication)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

@available(iOS 17.0, *)
#Preview {
    AddMedicationView(pet: Pet(name: "Buddy", species: "dog"))
        .modelContainer(for: [Pet.self, Medication.self], inMemory: true)
}
