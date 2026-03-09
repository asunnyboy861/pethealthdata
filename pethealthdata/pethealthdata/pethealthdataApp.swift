import SwiftUI
import SwiftData

@main
struct pethealthdataApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet.self,
            VaccineRecord.self,
            Medication.self,
            WeightRecord.self,
            HealthEvent.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestNotificationPermission()
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
