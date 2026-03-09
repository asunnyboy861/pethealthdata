import WidgetKit
import SwiftUI

struct PetHealthWidget: Widget {
    let kind: String = "PetHealthWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetHealthProvider()) { entry in
            PetHealthWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Pets")
        .description("Quick view of your pets")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PetHealthEntry: TimelineEntry {
    let date: Date
    let petCount: Int
    let upcomingVaccines: Int
    let petNames: [String]
    let petSpecies: [String]
}

struct PetHealthProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetHealthEntry {
        PetHealthEntry(
            date: Date(),
            petCount: 0,
            upcomingVaccines: 0,
            petNames: [],
            petSpecies: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PetHealthEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PetHealthEntry>) -> Void) {
        let entry = loadCurrentEntry()
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadCurrentEntry() -> PetHealthEntry {
        let sharedData = SharedDataManager.shared
        
        return PetHealthEntry(
            date: Date(),
            petCount: sharedData.getPetCount(),
            upcomingVaccines: sharedData.getUpcomingVaccines(),
            petNames: sharedData.getPetNames(),
            petSpecies: sharedData.getPetSpecies()
        )
    }
}

struct PetHealthWidgetEntryView: View {
    var entry: PetHealthEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if entry.petCount == 0 {
            emptyStateView
        } else {
            if #available(iOS 17.0, *) {
                if family == .systemSmall {
                    smallWidgetView
                } else {
                    mediumWidgetView
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No pets")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    @ViewBuilder
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "pawprint.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.petCount) pet\(entry.petCount == 1 ? "" : "s")")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if entry.upcomingVaccines > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("\(entry.upcomingVaccines) due")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    @ViewBuilder
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("My Pets")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if entry.upcomingVaccines > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text("\(entry.upcomingVaccines)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Divider()
            
            if entry.petNames.isEmpty {
                Text("Open app to view details")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(entry.petNames.prefix(3).enumerated()), id: \.offset) { index, name in
                    HStack(spacing: 6) {
                        let species = index < entry.petSpecies.count ? entry.petSpecies[index] : "other"
                        Image(systemName: speciesIcon(for: species))
                            .font(.caption2)
                            .foregroundColor(speciesColor(for: species))
                        
                        Text(name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                if entry.petCount > 3 {
                    Text("+\(entry.petCount - 3) more")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func speciesIcon(for species: String) -> String {
        switch species.lowercased() {
        case "dog": return "dog.fill"
        case "cat": return "cat.fill"
        case "bird": return "bird.fill"
        default: return "pawprint.fill"
        }
    }
    
    private func speciesColor(for species: String) -> Color {
        switch species.lowercased() {
        case "dog": return .blue
        case "cat": return .pink
        case "bird": return .green
        default: return .orange
        }
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    PetHealthWidget()
} timeline: {
    PetHealthEntry(
        date: .now,
        petCount: 2,
        upcomingVaccines: 1,
        petNames: ["Max", "Luna"],
        petSpecies: ["dog", "cat"]
    )
}
