//
//  CommandActivity.swift
//  VooDooControl
//
//  Live Activity for running commands
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes
struct CommandActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double
        var status: String
        var output: String
    }
    
    var command: String
    var startTime: Date
}

// MARK: - Live Activity View
struct CommandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CommandActivityAttributes.self) { context in
            // Lock Screen / Notification Center
            CommandLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "terminal.fill")
                        .foregroundStyle(.violet)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(String(format: "%.0f%%", context.state.progress * 100))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.violet)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.status)
                        .font(.caption)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(.violet)
                }
            } compactLeading: {
                Image(systemName: "terminal.fill")
                    .foregroundStyle(.violet)
            } compactTrailing: {
                Text(String(format: "%.0f%%", context.state.progress * 100))
                    .font(.caption2)
                    .foregroundStyle(.violet)
            } minimal: {
                Image(systemName: "terminal.fill")
                    .foregroundStyle(.violet)
            }
        }
    }
}

struct CommandLockScreenView: View {
    let context: ActivityViewContext<CommandActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "terminal.fill")
                    .foregroundStyle(.violet)
                
                Text(context.attributes.command)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(String(format: "%.0f%%", context.state.progress * 100))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.violet)
            }
            
            ProgressView(value: context.state.progress)
                .tint(.violet)
            
            HStack {
                Text(context.state.status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(elapsedTime(from: context.attributes.startTime))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
            
            if !context.state.output.isEmpty {
                Text(context.state.output)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
            }
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.8))
        .activitySystemActionForegroundColor(Color.white)
    }
    
    private func elapsedTime(from startDate: Date) -> String {
        let interval = Date().timeIntervalSince(startDate)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Activity Manager
class CommandActivityManager {
    static let shared = CommandActivityManager()
    private var currentActivity: Activity<CommandActivityAttributes>?
    
    private init() {}
    
    func startActivity(command: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }
        
        let attributes = CommandActivityAttributes(
            command: command,
            startTime: Date()
        )
        
        let contentState = CommandActivityAttributes.ContentState(
            progress: 0.0,
            status: "Running...",
            output: ""
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
        } catch {
            print("Failed to start activity: \(error)")
        }
    }
    
    func updateProgress(_ progress: Double, status: String, output: String = "") {
        Task {
            let contentState = CommandActivityAttributes.ContentState(
                progress: progress,
                status: status,
                output: output
            )
            
            await currentActivity?.update(using: contentState)
        }
    }
    
    func endActivity(success: Bool) {
        Task {
            let finalState = CommandActivityAttributes.ContentState(
                progress: 1.0,
                status: success ? "Completed" : "Failed",
                output: ""
            )
            
            await currentActivity?.end(using: finalState, dismissalPolicy: .default)
            currentActivity = nil
        }
    }
}
