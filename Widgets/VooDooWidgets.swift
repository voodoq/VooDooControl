//
//  VooDooWidgets.swift
//  VooDooWidgets
//
//  Home Screen and Lock Screen widgets
//

import WidgetKit
import SwiftUI

struct StatusEntry: TimelineEntry {
    let date: Date
    let isConnected: Bool
    let activeSessions: Int
    let memoryUsage: Double
    let lastHeartbeat: Date?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StatusEntry {
        StatusEntry(
            date: Date(),
            isConnected: true,
            activeSessions: 3,
            memoryUsage: 25.5,
            lastHeartbeat: Date()
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StatusEntry) -> Void) {
        let entry = StatusEntry(
            date: Date(),
            isConnected: true,
            activeSessions: 3,
            memoryUsage: 25.5,
            lastHeartbeat: Date()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StatusEntry>) -> Void) {
        // Fetch real data from shared UserDefaults or App Group
        let entry = StatusEntry(
            date: Date(),
            isConnected: UserDefaults.shared.bool(forKey: "isConnected"),
            activeSessions: UserDefaults.shared.integer(forKey: "activeSessions"),
            memoryUsage: UserDefaults.shared.double(forKey: "memoryUsage"),
            lastHeartbeat: UserDefaults.shared.object(forKey: "lastHeartbeat") as? Date
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(entry.isConnected ? .green : .red)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.activeSessions)")
                    .font(.title2.weight(.bold))
                
                Text("Active Sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let heartbeat = entry.lastHeartbeat {
                Text(timeAgo(from: heartbeat))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(.thickMaterial, for: .widget)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // Status section
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(entry.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(entry.isConnected ? "Online" : "Offline")
                        .font(.subheadline.weight(.medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.activeSessions)")
                        .font(.title.weight(.bold))
                    Text("sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Memory section
            VStack(alignment: .leading, spacing: 8) {
                Text("Memory")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", entry.memoryUsage))
                        .font(.title.weight(.bold))
                    Text("%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                        
                        Capsule()
                            .fill(entry.memoryUsage > 80 ? Color.red : Color.violet)
                            .frame(width: geo.size.width * (entry.memoryUsage / 100))
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Quick actions
            VStack(spacing: 8) {
                Button(intent: NewSessionIntent()) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.violet)
                .controlSize(.small)
                
                Button(intent: RefreshStatusIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .containerBackground(.thickMaterial, for: .widget)
    }
}

// MARK: - Lock Screen Widget
struct LockScreenWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(entry.isConnected ? .green : .red)
            
            VStack(alignment: .leading) {
                Text("\(entry.activeSessions) sessions")
                    .font(.headline)
                
                if entry.isConnected {
                    Text("Connected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.thickMaterial, for: .widget)
    }
}

// MARK: - Widget Configuration
@main
struct VooDooWidgets: WidgetBundle {
    var body: some Widget {
        VooDooStatusWidget()
        VooDooLockScreenWidget()
    }
}

struct VooDooStatusWidget: Widget {
    let kind: String = "VooDooStatusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VooDooWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("VooDoo Status")
        .description("Monitor your OpenClaw gateway status")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct VooDooLockScreenWidget: Widget {
    let kind: String = "VooDooLockScreenWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("VooDoo Lock")
        .description("Quick status on your Lock Screen")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct VooDooWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - App Intents
struct NewSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "New Session"
    static var description = IntentDescription("Create a new chat session")
    
    func perform() async throws -> some IntentResult {
        // Open app to new session
        return .result()
    }
}

struct RefreshStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
    static var description = IntentDescription("Refresh gateway status")
    
    func perform() async throws -> some IntentResult {
        // Trigger status refresh
        return .result()
    }
}

// MARK: - Extensions
extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.com.voodoo.control")!
    }
}

extension Color {
    static let violet = Color(red: 0.482, green: 0.380, blue: 1.0)
}
