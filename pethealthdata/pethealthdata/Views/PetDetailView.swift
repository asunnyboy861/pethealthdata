import SwiftUI
import SwiftData

struct PetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var pet: Pet
    
    @State private var selectedTab: Int = 0
    @State private var showingAddVaccine: Bool = false
    @State private var showingAddMedication: Bool = false
    @State private var showingAddWeight: Bool = false
    @State private var showingAddEvent: Bool = false
    @State private var showingExportSheet: Bool = false
    @State private var showingDeleteAlert: Bool = false
    @State private var selectedDateRange: PDFExportService.DateRange = .allTime
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                statsSection
                
                tabSelector
                
                tabContent
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Label("Export Health Report", systemImage: "doc.text")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Pet", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddVaccine) {
            AddVaccineView(pet: pet)
        }
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView(pet: pet)
        }
        .sheet(isPresented: $showingAddWeight) {
            AddWeightView(pet: pet)
        }
        .sheet(isPresented: $showingAddEvent) {
            AddHealthEventView(pet: pet)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportReportSheet(pet: pet)
        }
        .alert("Delete \(pet.name)?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deletePet()
            }
        } message: {
            Text("This will permanently delete all records for \(pet.name) including:\n\n• Vaccinations (\(pet.vaccines.count))\n• Medications (\(pet.medications.count))\n• Weight history (\(pet.weightRecords.count))\n• Health events (\(pet.healthEvents.count))\n\nThis action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            PetAvatarView(pet: pet, size: 100)
            
            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: 8) {
                    Text(pet.species.capitalized)
                    if let breed = pet.breed, !breed.isEmpty {
                        Text("•")
                        Text(breed)
                    }
                }
                .font(.system(size: 15))
                .foregroundColor(.appTextSecondary)
                
                if pet.birthDate != nil {
                    Text(pet.age)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "syringe",
                value: "\(pet.vaccines.count)",
                label: "Vaccines",
                iconColor: .appPrimary
            )
            
            StatCard(
                icon: "pills.fill",
                value: "\(pet.activeMedicationsCount)",
                label: "Active Meds",
                iconColor: .appWarning
            )
            
            StatCard(
                icon: "scalemass",
                value: String(format: "%.1f", pet.weight),
                label: "Weight (lbs)",
                iconColor: .appSuccess
            )
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 20))
                        Text(tabTitle(for: index))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(selectedTab == index ? .appPrimary : .appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == index ? Color.appPrimary.opacity(0.1) : Color.clear)
                    .cornerRadius(12)
                }
            }
        }
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .padding(.horizontal, 0)
    }
    
    private var tabContent: some View {
        VStack(spacing: 16) {
            switch selectedTab {
            case 0:
                vaccinesTab
            case 1:
                medicationsTab
            case 2:
                weightTab
            case 3:
                eventsTab
            default:
                EmptyView()
            }
        }
    }
    
    private var vaccinesTab: some View {
        VStack(spacing: 16) {
            if pet.vaccines.isEmpty {
                emptyTabView(
                    icon: "syringe",
                    title: "No Vaccinations",
                    message: "Track vaccination records and get reminders"
                )
            } else {
                ForEach(sortedVaccines) { vaccine in
                    VaccineRowView(vaccine: vaccine) {
                        deleteVaccine(vaccine)
                    }
                }
            }
            
            addRecordButton(title: "Add Vaccine", icon: "plus.circle.fill") {
                showingAddVaccine = true
            }
        }
    }
    
    private var medicationsTab: some View {
        VStack(spacing: 16) {
            if pet.medications.isEmpty {
                emptyTabView(
                    icon: "pills.fill",
                    title: "No Medications",
                    message: "Track medications and get daily reminders"
                )
            } else {
                ForEach(sortedMedications) { medication in
                    MedicationRowView(medication: medication) {
                        toggleMedicationActive(medication)
                    } onDelete: {
                        deleteMedication(medication)
                    }
                }
            }
            
            addRecordButton(title: "Add Medication", icon: "plus.circle.fill") {
                showingAddMedication = true
            }
        }
    }
    
    private var weightTab: some View {
        VStack(spacing: 16) {
            if pet.weightRecords.isEmpty {
                emptyTabView(
                    icon: "scalemass",
                    title: "No Weight Records",
                    message: "Track weight over time to monitor health"
                )
            } else {
                if pet.weightRecords.count >= 2 {
                    WeightChartView(records: sortedWeightRecords)
                        .frame(height: 200)
                        .padding()
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                }
                
                ForEach(sortedWeightRecords) { record in
                    WeightRowView(record: record) {
                        deleteWeightRecord(record)
                    }
                }
            }
            
            addRecordButton(title: "Add Weight", icon: "plus.circle.fill") {
                showingAddWeight = true
            }
        }
    }
    
    private var eventsTab: some View {
        VStack(spacing: 16) {
            if pet.healthEvents.isEmpty {
                emptyTabView(
                    icon: "heart.fill",
                    title: "No Health Events",
                    message: "Record checkups, surgeries, and other events"
                )
            } else {
                ForEach(sortedHealthEvents) { event in
                    HealthEventRowView(event: event) {
                        deleteHealthEvent(event)
                    }
                }
            }
            
            addRecordButton(title: "Add Event", icon: "plus.circle.fill") {
                showingAddEvent = true
            }
        }
    }
    
    private func emptyTabView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.appTextSecondary.opacity(0.5))
            
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private func addRecordButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.appPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appPrimary.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "syringe"
        case 1: return "pills.fill"
        case 2: return "scalemass"
        case 3: return "heart.fill"
        default: return "circle"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Vaccines"
        case 1: return "Meds"
        case 2: return "Weight"
        case 3: return "Events"
        default: return ""
        }
    }
    
    private var sortedVaccines: [VaccineRecord] {
        pet.vaccines.sorted { $0.vaccinationDate > $1.vaccinationDate }
    }
    
    private var sortedMedications: [Medication] {
        pet.medications.sorted { $0.createdAt > $1.createdAt }
    }
    
    private var sortedWeightRecords: [WeightRecord] {
        pet.weightRecords.sorted { $0.date > $1.date }
    }
    
    private var sortedHealthEvents: [HealthEvent] {
        pet.healthEvents.sorted { $0.date > $1.date }
    }
    
    private func deleteVaccine(_ vaccine: VaccineRecord) {
        modelContext.delete(vaccine)
        try? modelContext.save()
    }
    
    private func deleteMedication(_ medication: Medication) {
        modelContext.delete(medication)
        try? modelContext.save()
    }
    
    private func toggleMedicationActive(_ medication: Medication) {
        medication.isActive.toggle()
        try? modelContext.save()
    }
    
    private func deleteWeightRecord(_ record: WeightRecord) {
        modelContext.delete(record)
        try? modelContext.save()
    }
    
    private func deleteHealthEvent(_ event: HealthEvent) {
        modelContext.delete(event)
        try? modelContext.save()
    }
    
    private func deletePet() {
        modelContext.delete(pet)
        try? modelContext.save()
    }
}

@available(iOS 17.0, *)
#Preview {
    NavigationStack {
        PetDetailView(pet: Pet(name: "Buddy", species: "dog", breed: "Golden Retriever"))
    }
    .modelContainer(for: [Pet.self, VaccineRecord.self, Medication.self, WeightRecord.self, HealthEvent.self], inMemory: true)
}
