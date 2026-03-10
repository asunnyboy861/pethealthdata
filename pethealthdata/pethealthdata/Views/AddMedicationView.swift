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
    @State private var reminderTimes: [Date] = []
    @State private var selectedSound: String = NotificationSoundConfig.SoundOption.medicationDefault.fileName
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
                        // Multiple reminder times list
                        VStack(alignment: .leading) {
                            Text("Reminder Times")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if reminderTimes.isEmpty {
                                Button(action: addReminderTime) {
                                    Label("Add Time", systemImage: "plus.circle")
                                }
                                .buttonStyle(.borderless)
                            } else {
                                ForEach(reminderTimes.indices, id: \.self) { index in
                                    HStack {
                                        DatePicker("", selection: $reminderTimes[index], displayedComponents: .hourAndMinute)
                                        Spacer()
                                        Button(action: { removeReminder(at: index) }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                
                                Button(action: addReminderTime) {
                                    Label("Add Another Time", systemImage: "plus.circle")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Sound selection
                        NavigationLink(destination: NotificationSoundPickerView(selectedSound: $selectedSound)) {
                            HStack {
                                Text("Notification Sound")
                                Spacer()
                                Text(NotificationSoundConfig.SoundOption.allCases.first { $0.fileName == selectedSound }?.name ?? "Bamboo")
                                    .foregroundColor(.secondary)
                            }
                        }
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
        let medication = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            reminderTimes: reminderTimes.isEmpty && enableReminder && frequency != "as_needed" ? [Date()] : reminderTimes,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            notes: notes.isEmpty ? nil : notes,
            notificationSound: selectedSound,
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
    
    private func addReminderTime() {
        reminderTimes.append(Date())
    }
    
    private func removeReminder(at index: Int) {
        reminderTimes.remove(at: index)
    }
}

@available(iOS 17.0, *)
#Preview {
    AddMedicationView(pet: Pet(name: "Buddy", species: "dog"))
        .modelContainer(for: [Pet.self, Medication.self], inMemory: true)
}
