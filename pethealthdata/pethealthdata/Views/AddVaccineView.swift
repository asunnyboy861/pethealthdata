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
