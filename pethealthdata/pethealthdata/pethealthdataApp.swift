import SwiftUI
import SwiftData

@main
struct pethealthdataApp: App {
    @State private var modelContainer: ModelContainer?
    @State private var hasError = false
    @State private var errorMessage = ""
    @State private var isInitializing = false
    @AppStorage("useLocalStorage") private var useLocalStorage = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let container = modelContainer {
                    MainTabView()
                        .modelContainer(container)
                        .onAppear {
                            requestNotificationPermission()
                            NotificationService.shared.setupNotificationCategories()
                        }
                } else if hasError {
                    ErrorView(
                        message: errorMessage,
                        onRetry: {
                            Task {
                                await initializeModelContainer()
                            }
                        },
                        onUseLocal: {
                            Task {
                                await initializeLocalModelContainer()
                            }
                        }
                    )
                } else {
                    LoadingView()
                        .task {
                            if !isInitializing {
                                await initializeModelContainer()
                            }
                        }
                }
            }
        }
    }
    
    private func initializeModelContainer() async {
        guard !isInitializing else { return }
        isInitializing = true
        
        if useLocalStorage {
            await performLocalInitialization()
            return
        }
        
        do {
            let config = ModelConfiguration()
            let container = try ModelContainer(
                for: Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self,
                configurations: config
            )
            
            await MainActor.run {
                modelContainer = container
                isInitializing = false
            }
            
            print("ModelContainer initialized with CloudKit")
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
            
            await MainActor.run {
                errorMessage = "Unable to connect to iCloud. You can retry or use local storage."
                hasError = true
                isInitializing = false
            }
        }
    }
    
    private func initializeLocalModelContainer() async {
        guard !isInitializing else { return }
        isInitializing = true
        
        await performLocalInitialization()
    }
    
    private func performLocalInitialization() async {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let localURL = documentsURL.appendingPathComponent("PetHealthData.sqlite")
            
            let config = ModelConfiguration(url: localURL, allowsSave: true, cloudKitDatabase: .none)
            
            let container = try ModelContainer(
                for: Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self,
                configurations: config
            )
            
            await MainActor.run {
                modelContainer = container
                useLocalStorage = true
                hasError = false
                isInitializing = false
            }
            
            print("ModelContainer initialized with local storage")
        } catch {
            print("Failed to initialize local ModelContainer: \(error)")
            
            await MainActor.run {
                errorMessage = "Failed to initialize storage: \(error.localizedDescription)"
                hasError = true
                isInitializing = false
            }
        }
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

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onUseLocal: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "icloud.slash")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("iCloud Unavailable")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: onUseLocal) {
                    HStack {
                        Image(systemName: "internaldrive")
                        Text("Use Local Storage")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
            
            Text("Local storage won't sync across devices")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}
