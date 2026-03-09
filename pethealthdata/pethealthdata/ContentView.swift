import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        PetListView()
    }
}

@available(iOS 17.0, *)
#Preview {
    ContentView()
        .modelContainer(for: [Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self], inMemory: true)
}
