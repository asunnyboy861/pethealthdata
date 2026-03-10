import SwiftUI
import SwiftData

struct AddVaccineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pet: Pet
    
    @State private var vaccineName: String = ""
    @State private var vaccinationDate: Date = Date()
    @State private var nextDueDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var hasNextDueDate: Bool = true
    @State private var veterinarian: String = ""
    @State private var notes: String = ""
    @State private var selectedVaccineType: String = ""
    
    // Reminder settings
    @State private var reminderTime: Date = VaccineReminderConfig.defaultReminderTime
    @State private var selectedReminderDays: [Int] = VaccineReminderConfig.defaultReminderDays
    @State private var selectedSound: String = NotificationSoundConfig.SoundOption.default.fileName
    
    @ViewBuilder
    private func reminderSettingsContent() -> some View {
        // Reminder time picker
        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
        
        // Advance notification days
        DisclosureGroup {
            ReminderDaysPicker(selectedDays: $selectedReminderDays)
                .padding(.vertical, 4)
        } label: {
            HStack {
                Text("Notify Before")
                Spacer()
                Text("\(selectedReminderDays.count) reminders")
                    .foregroundColor(.secondary)
            }
        }
        
        // Sound selection
        NavigationLink(destination: NotificationSoundPickerView(selectedSound: $selectedSound)) {
            HStack {
                Text("Notification Sound")
                Spacer()
                Text(NotificationSoundConfig.SoundOption.allCases.first { $0.fileName == selectedSound }?.name ?? "Tri-Tone")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Vaccine Information") {
                    Picker("Vaccine Type", selection: $selectedVaccineType) {
                        Text("Select a vaccine").tag("")
                        ForEach(VaccineRecord.commonVaccines, id: \.name) { vaccine in
                            Text(vaccine.name).tag(vaccine.name)
                        }
                    }
                    
                    if !selectedVaccineType.isEmpty {
                        TextField("Custom Vaccine Name", text: $vaccineName)
                            .onChange(of: selectedVaccineType) { _, newValue in
                                vaccineName = newValue
                            }
                    } else {
                        TextField("Vaccine Name", text: $vaccineName)
                    }
                    
                    DatePicker("Vaccination Date", selection: $vaccinationDate, displayedComponents: .date)
                    
                    Toggle("Set Next Due Date", isOn: $hasNextDueDate)
                    
                    if hasNextDueDate {
                        DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                    }
                }
                
                // Reminder Settings section - using conditional Section content
                if hasNextDueDate {
                    Section("Reminder Settings") {
                        reminderSettingsContent()
                    }
                } else {
                    Section("Reminder Settings") {
                        Text("Set a next due date to enable reminders")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Veterinarian (Optional)") {
                    TextField("Veterinarian Name", text: $veterinarian)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Vaccine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVaccine()
                    }
                    .disabled(vaccineName.isEmpty)
                }
            }
        }
    }
    
    private func saveVaccine() {
        let vaccine = VaccineRecord(
            vaccineName: vaccineName,
            vaccinationDate: vaccinationDate,
            nextDueDate: hasNextDueDate ? nextDueDate : nil,
            veterinarian: veterinarian.isEmpty ? nil : veterinarian,
            notes: notes.isEmpty ? nil : notes,
            reminderTime: reminderTime,
            reminderDaysBefore: selectedReminderDays.isEmpty ? [30, 14, 7, 3, 1, 0] : selectedReminderDays,
            notificationSound: selectedSound,
            pet: pet
        )
        
        modelContext.insert(vaccine)
        pet.vaccines.append(vaccine)
        
        if hasNextDueDate {
            NotificationService.shared.scheduleVaccineReminder(for: pet, vaccine: vaccine)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

@available(iOS 17.0, *)
#Preview {
    AddVaccineView(pet: Pet(name: "Buddy", species: "dog"))
        .modelContainer(for: [Pet.self, VaccineRecord.self], inMemory: true)
}
