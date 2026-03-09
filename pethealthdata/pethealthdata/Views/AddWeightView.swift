import SwiftUI
import SwiftData

struct AddWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pet: Pet
    
    @State private var weight: String = ""
    @State private var weightUnit: String = "lbs"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    let weightUnits = ["lbs", "kg"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Weight Information") {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $weightUnit) {
                            ForEach(weightUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWeight()
                    }
                    .disabled(weight.isEmpty)
                }
            }
        }
    }
    
    private func saveWeight() {
        let weightValue = Double(weight) ?? 0
        
        let weightRecord = WeightRecord(
            weight: weightValue,
            weightUnit: weightUnit,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            pet: pet
        )
        
        modelContext.insert(weightRecord)
        pet.weightRecords.append(weightRecord)
        
        pet.weight = weightValue
        
        try? modelContext.save()
        dismiss()
    }
}

@available(iOS 17.0, *)
#Preview {
    AddWeightView(pet: Pet(name: "Buddy", species: "dog"))
        .modelContainer(for: [Pet.self, WeightRecord.self], inMemory: true)
}
