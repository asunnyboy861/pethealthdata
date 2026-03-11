import SwiftUI
import SwiftData

/// Today's reminder view
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    
    @State private var viewModel: TodayViewModel?
    
    private let today = Date()
    private var threeDaysFromNow: Date {
        Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            if let viewModel = viewModel {
                if viewModel.isLoading {
                    loadingView
                } else if hasNoReminders {
                    emptyStateView
                } else {
                    reminderListView
                }
            } else {
                loadingView
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if viewModel == nil {
                viewModel = TodayViewModel(modelContext: modelContext)
            }
            await loadTodaysReminders()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading reminders...")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private var hasNoReminders: Bool {
        guard let viewModel = viewModel else { return true }
        return viewModel.todayVaccines.isEmpty && viewModel.todayMedications.isEmpty
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.appSuccess)
            
            Text("All Caught Up!")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            
            Text("No reminders for today. Enjoy your day with your pets!")
                .font(.system(size: 15))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
    
    private var reminderListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Vaccines Section
                if let viewModel = viewModel, !viewModel.todayVaccines.isEmpty {
                    reminderSection(
                        title: "Vaccines Due",
                        icon: "syringe",
                        color: .appPrimary,
                        count: viewModel.todayVaccines.count
                    ) {
                        ForEach(viewModel.todayVaccines, id: \.id) { vaccine in
                            TodayVaccineCard(vaccine: vaccine, pet: vaccine.pet)
                        }
                    }
                }
                
                // Medications Section
                if let viewModel = viewModel, !viewModel.todayMedications.isEmpty {
                    reminderSection(
                        title: "Medications",
                        icon: "pills.fill",
                        color: .appWarning,
                        count: viewModel.todayMedications.count
                    ) {
                        ForEach(viewModel.todayMedications, id: \.id) { medication in
                            TodayMedicationCard(medication: medication, pet: medication.pet)
                        }
                    }
                }
                
                // Upcoming Section
                if let viewModel = viewModel, !viewModel.upcomingReminders.isEmpty {
                    upcomingSection
                }
            }
            .padding()
        }
    }
    
    private func reminderSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        count: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 8) {
                content()
            }
        }
    }
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.appInfo)
                    Text("Coming Up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(viewModel?.upcomingReminders ?? []) { reminder in
                    UpcomingReminderCard(reminder: reminder)
                }
            }
        }
    }
    
    private func loadTodaysReminders() async {
        viewModel?.loadTodaysReminders()
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
}