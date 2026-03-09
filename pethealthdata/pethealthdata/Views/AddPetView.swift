import SwiftUI
import SwiftData
import PhotosUI

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var species: String = "dog"
    @State private var breed: String = ""
    @State private var birthDate: Date = Date()
    @State private var hasBirthDate: Bool = false
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    
    let speciesOptions = ["dog", "cat", "bird", "other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Pet Name", text: $name)
                    
                    Picker("Species", selection: $species) {
                        ForEach(speciesOptions, id: \.self) { option in
                            HStack {
                                Image(systemName: speciesIcon(for: option))
                                Text(option.capitalized)
                            }
                            .tag(option)
                        }
                    }
                    
                    TextField("Breed (Optional)", text: $breed)
                    
                    Toggle("Add Birth Date", isOn: $hasBirthDate)
                    
                    if hasBirthDate {
                        DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                    }
                    
                    TextField("Weight (lbs)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section("Photo") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            if let photoData = photoData,
                               let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.appTextSecondary)
                                    .frame(width: 80, height: 80)
                                    .background(Color.appBackground)
                                    .clipShape(Circle())
                            }
                            
                            Text(selectedPhotoItem == nil ? "Select Photo" : "Change Photo")
                                .foregroundColor(.appPrimary)
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePet()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func speciesIcon(for species: String) -> String {
        switch species {
        case "dog": return "dog.fill"
        case "cat": return "cat.fill"
        case "bird": return "bird.fill"
        default: return "pawprint.fill"
        }
    }
    
    private func savePet() {
        let pet = Pet(
            name: name,
            species: species,
            breed: breed.isEmpty ? nil : breed,
            birthDate: hasBirthDate ? birthDate : nil,
            weight: Double(weight) ?? 0.0,
            photoData: photoData,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(pet)
        
        try? modelContext.save()
        
        dismiss()
    }
}

@available(iOS 17.0, *)
#Preview {
    AddPetView()
        .modelContainer(for: [Pet.self], inMemory: true)
}
