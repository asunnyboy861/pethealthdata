import SwiftUI
import SwiftData

struct AddHealthEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pet: Pet
    
    @State private var eventType: String = "checkup"
    @State private var title: String = ""
    @State private var eventDescription: String = ""
    @State private var date: Date = Date()
    
    let eventTypes = [
        ("checkup", "Checkup", "stethoscope"),
        ("vaccination", "Vaccination", "syringe"),
        ("medication", "Medication", "pills.fill"),
        ("grooming", "Grooming", "scissors"),
        ("surgery", "Surgery", "cross.case"),
        ("emergency", "Emergency", "exclamationmark.triangle.fill"),
        ("other", "Other", "heart.fill")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Information") {
                    Picker("Event Type", selection: $eventType) {
                        ForEach(eventTypes, id: \.0) { type in
                            Label(type.1, systemImage: type.2)
                                .tag(type.0)
                        }
                    }
                    
                    TextField("Title", text: $title)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Description (Optional)") {
                    TextEditor(text: $eventDescription)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Health Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onChange(of: eventType) { _, newValue in
                if title.isEmpty || eventTypes.contains(where: { $0.0 == newValue && $0.1 == title }) {
                    if let eventTypeInfo = eventTypes.first(where: { $0.0 == newValue }) {
                        title = eventTypeInfo.1
                    }
                }
            }
        }
    }
    
    private func saveEvent() {
        let event = HealthEvent(
            eventType: eventType,
            title: title,
            eventDescription: eventDescription.isEmpty ? nil : eventDescription,
            date: date,
            pet: pet
        )
        
        modelContext.insert(event)
        pet.healthEvents.append(event)
        
        try? modelContext.save()
        dismiss()
    }
}

@available(iOS 17.0, *)
#Preview {
    AddHealthEventView(pet: Pet(name: "Buddy", species: "dog"))
        .modelContainer(for: [Pet.self, HealthEvent.self], inMemory: true)
}
