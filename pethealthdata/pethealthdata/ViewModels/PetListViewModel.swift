import Foundation
import SwiftData
import SwiftUI
import WidgetKit

@Observable
final class PetListViewModel {
    var pets: [Pet] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var showingAddPet: Bool = false
    var selectedPet: Pet?
    
    private var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchPets()
    }
    
    func fetchPets() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<Pet>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            pets = try modelContext.fetch(descriptor)
            syncToWidget()
        } catch {
            print("Failed to fetch pets: \(error)")
        }
    }
    
    private func syncToWidget() {
        let sharedData = SharedDataManager.shared
        
        sharedData.savePetCount(pets.count)
        sharedData.savePetNames(pets.map { $0.name })
        sharedData.savePetSpecies(pets.map { $0.species })
        
        let upcomingCount = pets.reduce(0) { $0 + $1.upcomingVaccinesCount }
        sharedData.saveUpcomingVaccines(upcomingCount)
        
        WidgetCenter.shared.reloadTimelines(ofKind: "PetHealthWidget")
    }
    
    func addPet(_ pet: Pet) {
        guard let modelContext = modelContext else { return }
        modelContext.insert(pet)
        try? modelContext.save()
        fetchPets()
    }
    
    func deletePet(_ pet: Pet) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(pet)
        try? modelContext.save()
        fetchPets()
    }
    
    func deletePets(at offsets: IndexSet) {
        for index in offsets {
            deletePet(pets[index])
        }
    }
    
    var filteredPets: [Pet] {
        if searchText.isEmpty {
            return pets
        }
        return pets.filter { pet in
            pet.name.localizedCaseInsensitiveContains(searchText) ||
            pet.species.localizedCaseInsensitiveContains(searchText) ||
            (pet.breed?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var totalPetsCount: Int {
        pets.count
    }
    
    var upcomingRemindersCount: Int {
        pets.reduce(0) { $0 + $1.upcomingVaccinesCount }
    }
}
