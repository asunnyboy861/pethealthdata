import SwiftUI
import SwiftData
import CloudKit

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
            
            // Enable CloudKit synchronization for cross-device data sync
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                cloudKitDatabase: .automatic
            )
            
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
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
