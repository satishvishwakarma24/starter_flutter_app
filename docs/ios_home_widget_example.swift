// Reference for iOS Widget Extension (add via Xcode: File → New → Target → Widget Extension).
// 1. Set App Group on Runner + Extension (must match EngagementConfig.iosAppGroupId).
// 2. Call HomeWidget.setAppGroupId from Dart (already done in HomeWidgetService).
// 3. Use the same data keys as Android: widget_title, widget_subtitle, widget_updated_at.

import WidgetKit
import SwiftUI

struct StarterAppWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
}

struct StarterAppWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StarterAppWidgetEntry {
        StarterAppWidgetEntry(date: .now, title: "Starter App", subtitle: "Tap to open")
    }

    func getSnapshot(in context: Context, completion: @escaping (StarterAppWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StarterAppWidgetEntry>) -> Void) {
        let entry = loadEntry()
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600))))
    }

    private func loadEntry() -> StarterAppWidgetEntry {
        let data = UserDefaults(suiteName: "group.com.example.starterapp")
        return StarterAppWidgetEntry(
            date: .now,
            title: data?.string(forKey: "widget_title") ?? "Starter App",
            subtitle: data?.string(forKey: "widget_subtitle") ?? "Tap to open"
        )
    }
}

struct StarterAppWidgetView: View {
    var entry: StarterAppWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title).font(.headline)
            Text(entry.subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}

@main
struct StarterAppWidget: Widget {
    let kind: String = "StarterAppWidget" // must match EngagementConfig.iosWidgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StarterAppWidgetProvider()) { entry in
            StarterAppWidgetView(entry: entry)
        }
        .configurationDisplayName("Starter App")
        .description("Quick glance without opening the app.")
    }
}
