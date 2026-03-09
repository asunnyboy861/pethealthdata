import SwiftUI
import SwiftData

struct PetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.name) private var pets: [Pet]
    
    @State private var searchText: String = ""
    @State private var showingAddPet: Bool = false
    @State private var selectedPet: Pet?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if pets.isEmpty {
                    emptyStateView
                } else {
                    petGridView
                }
                
                addButton
            }
            .navigationTitle("My Pets")
            .searchable(text: $searchText, prompt: "Search pets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
            .navigationDestination(item: $selectedPet) { pet in
                PetDetailView(pet: pet)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.appPrimary.opacity(0.6))
            
            Text("No Pets Yet")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            
            Text("Tap the + button to add your first pet")
                .font(.system(size: 15))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var petGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredPets) { pet in
                    PetCardView(pet: pet)
                        .onTapGesture {
                            selectedPet = pet
                        }
                }
            }
            .padding()
        }
    }
    
    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingAddPet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                        .shadow(color: Color.appPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding()
            }
        }
    }
    
    private var filteredPets: [Pet] {
        if searchText.isEmpty {
            return pets
        }
        return pets.filter { pet in
            pet.name.localizedCaseInsensitiveContains(searchText) ||
            pet.species.localizedCaseInsensitiveContains(searchText) ||
            (pet.breed?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
}

struct PetCardView: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: 12) {
            PetAvatarView(pet: pet, size: 80)
            
            Text(pet.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Image(systemName: pet.speciesIcon)
                    .font(.system(size: 12))
                Text(pet.species.capitalized)
                    .font(.system(size: 13))
            }
            .foregroundColor(.appTextSecondary)
            
            if !pet.vaccines.isEmpty || !pet.medications.isEmpty {
                HStack(spacing: 8) {
                    if pet.upcomingVaccinesCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "syringe")
                                .font(.system(size: 10))
                            Text("\(pet.upcomingVaccinesCount)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.appWarning)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appWarning.opacity(0.15))
                        .cornerRadius(6)
                    }
                    
                    if pet.activeMedicationsCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "pills.fill")
                                .font(.system(size: 10))
                            Text("\(pet.activeMedicationsCount)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appPrimary.opacity(0.15))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

@available(iOS 17.0, *)
#Preview {
    PetListView()
        .modelContainer(for: [Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self], inMemory: true)
}
