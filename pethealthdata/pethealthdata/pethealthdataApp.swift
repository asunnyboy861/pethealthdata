import SwiftUI
import SwiftData

@main
struct pethealthdataApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema([
                Pet.self,
                VaccineRecord.self,
                Medication.self,
                WeightRecord.self,
                HealthEvent.self
            ])
            
            // TEMPORARY: Use in-memory storage for testing
            // Change to false for persistent storage
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                allowsSave: true
            )
            
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestNotificationPermission()
                    NotificationService.shared.setupNotificationCategories()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func requestNotificationPermission() {
        NotificationService.shared.requestAuthorization { granted in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}
