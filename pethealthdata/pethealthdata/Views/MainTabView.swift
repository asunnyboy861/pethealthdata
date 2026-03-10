import SwiftUI
import SwiftData

/// Main tab bar view with three primary navigation tabs
struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Pet list
            NavigationStack {
                PetListView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Today Tab - Today's reminders
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "calendar.badge.clock")
            }
            .tag(1)
            
            // Settings Tab - App settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .tint(.appPrimary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self], inMemory: true)
}