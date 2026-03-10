import SwiftUI
import SwiftData

@main
struct pethealthdataApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            // 暂时禁用 CloudKit 以避免启动崩溃 - 上架前恢复
            // 使用默认配置（无 CloudKit）
            let container = try ModelContainer(for: Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self)
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
