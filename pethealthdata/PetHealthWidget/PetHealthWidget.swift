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
}

struct PetHealthProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetHealthEntry {
        PetHealthEntry(
            date: Date(),
            petCount: 0,
            upcomingVaccines: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PetHealthEntry) -> Void) {
        let entry = PetHealthEntry(
            date: Date(),
            petCount: 0,
            upcomingVaccines: 0
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PetHealthEntry>) -> Void) {
        let entry = PetHealthEntry(
            date: Date(),
            petCount: 0,
            upcomingVaccines: 0
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
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
                        
                        Text("Open app to view details")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    PetHealthWidget()
} timeline: {
    PetHealthEntry(
        date: .now,
        petCount: 0,
        upcomingVaccines: 0
    )
}
