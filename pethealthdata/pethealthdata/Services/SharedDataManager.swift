import Foundation

final class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let defaults: UserDefaults?
    private let appGroupIdentifier = "group.com.zzoutuo.pethealthdata"
    
    private init() {
        defaults = UserDefaults(suiteName: appGroupIdentifier)
    }
    
    func savePetCount(_ count: Int) {
        defaults?.set(count, forKey: "petCount")
    }
    
    func getPetCount() -> Int {
        return defaults?.integer(forKey: "petCount") ?? 0
    }
    
    func saveUpcomingVaccines(_ count: Int) {
        defaults?.set(count, forKey: "upcomingVaccines")
    }
    
    func getUpcomingVaccines() -> Int {
        return defaults?.integer(forKey: "upcomingVaccines") ?? 0
    }
    
    func savePetNames(_ names: [String]) {
        defaults?.set(names, forKey: "petNames")
    }
    
    func getPetNames() -> [String] {
        return defaults?.stringArray(forKey: "petNames") ?? []
    }
    
    func savePetSpecies(_ species: [String]) {
        defaults?.set(species, forKey: "petSpecies")
    }
    
    func getPetSpecies() -> [String] {
        return defaults?.stringArray(forKey: "petSpecies") ?? []
    }
    
    func clearAll() {
        defaults?.removeObject(forKey: "petCount")
        defaults?.removeObject(forKey: "upcomingVaccines")
        defaults?.removeObject(forKey: "petNames")
        defaults?.removeObject(forKey: "petSpecies")
    }
}
