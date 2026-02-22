//
//  StatusView.swift
//  Features/Status
//
//  Gateway status and settings
//

import SwiftUI
import SwiftData
import Charts

struct StatusView: View {
    @EnvironmentObject var appState: AppState
    @Query var settings: [AppSettings]
    
    @State private var selectedTab: StatusTab = .overview
    
    enum StatusTab: String, CaseIterable {
        case overview = "Overview"
        case channels = "Channels"
        case cron = "Cron Jobs"
        case settings = "Settings"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented control
                GlassSegmentedControl(
                    options: StatusTab.allCases,
                    titles: { $0.rawValue },
                    selection: $selectedTab
                )
                .padding()
                
                // Content
                Group {
                    switch selectedTab {
                    case .overview:
                        OverviewTab()
                    case .channels:
                        ChannelsTab()
                    case .cron:
                        CronTab()
                    case .settings:
                        SettingsTab()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Status")
        }
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Connection Status
                StatusCard(
                    title: "Gateway Status",
                    icon: appState.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill",
                    iconColor: appState.isConnected ? .green : .red,
                    value: appState.isConnected ? "Online" : "Offline"
                )
                
                // Memory Usage
                StatusCard(
                    title: "Memory Usage",
                    icon: "memorychip",
                    iconColor: memoryColor,
                    value: "\(Int(appState.memoryUsage))%"
                )
                
                // Active Sessions
                StatusCard(
                    title: "Active Sessions",
                    icon: "person.2.fill",
                    iconColor: .violet,
                    value: "\(appState.activeSessions)"
                )
                
                // Uptime
                StatusCard(
                    title: "Uptime",
                    icon: "clock.arrow.circlepath",
                    iconColor: .blue,
                    value: "2h 34m"
                )
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
    
    private var memoryColor: Color {
        switch appState.memoryUsage {
        case 0..<50: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
}

struct StatusCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.title2.weight(.bold))
            }
            
            Spacer()
        }
        .padding()
        .glassCard(thickness: .thick)
    }
}

// MARK: - Channels Tab
struct ChannelsTab: View {
    let channels = [
        (name: "Telegram", isEnabled: true, status: "Connected"),
        (name: "Discord", isEnabled: false, status: "Not configured"),
        (name: "WhatsApp", isEnabled: false, status: "Not configured"),
        (name: "Email", isEnabled: false, status: "Not configured")
    ]
    
    var body: some View {
        List {
            ForEach(channels, id: \.name) { channel in
                ChannelRow(
                    name: channel.name,
                    isEnabled: channel.isEnabled,
                    status: channel.status
                )
            }
        }
        .listStyle(.plain)
        .background(.ultraThinMaterial)
    }
}

struct ChannelRow: View {
    let name: String
    let isEnabled: Bool
    let status: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isEnabled ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconForChannel(name))
                    .font(.title3)
                    .foregroundStyle(isEnabled ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(isEnabled))
                .toggleStyle(.glass)
                .disabled(true)
        }
        .padding(.vertical, 4)
    }
    
    private func iconForChannel(_ name: String) -> String {
        switch name.lowercased() {
        case "telegram": return "paperplane.fill"
        case "discord": return "bubble.left.and.bubble.right.fill"
        case "whatsapp": return "phone.fill"
        case "email": return "envelope.fill"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Cron Tab
struct CronTab: View {
    let jobs = [
        (name: "Health Check", schedule: "*/30 * * * *", isEnabled: true, lastRun: "2 min ago"),
        (name: "Backup", schedule: "0 2 * * *", isEnabled: true, lastRun: "5 hours ago"),
        (name: "Cleanup", schedule: "0 0 * * 0", isEnabled: false, lastRun: "1 week ago")
    ]
    
    var body: some View {
        List {
            ForEach(jobs, id: \.name) { job in
                CronJobRow(
                    name: job.name,
                    schedule: job.schedule,
                    isEnabled: job.isEnabled,
                    lastRun: job.lastRun
                )
            }
        }
        .listStyle(.plain)
        .background(.ultraThinMaterial)
    }
}

struct CronJobRow: View {
    let name: String
    let schedule: String
    let isEnabled: Bool
    let lastRun: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                    
                    if !isEnabled {
                        Text("Disabled")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Capsule())
                    }
                }
                
                Text(schedule)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .font(.system(.caption, design: .monospaced))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(lastRun)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Button("Run Now") {
                    // Run job
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.violet)
            }
        }
        .padding(.vertical, 4)
        .opacity(isEnabled ? 1 : 0.6)
    }
}

// MARK: - Settings Tab
struct SettingsTab: View {
    @Query var settings: [AppSettings]
    @State private var serverURL = "ws://127.0.0.1:18789"
    @State private var authToken = ""
    @State private var selectedTheme: AppSettings.Theme = .auto
    @State private var selectedHaptic: AppSettings.HapticIntensity = .medium
    @State private var notificationsEnabled = true
    
    var body: some View {
        Form {
            Section("Server") {
                TextField("Server URL", text: $serverURL)
                    .font(.system(.body, design: .monospaced))
                
                SecureField("Auth Token", text: $authToken)
                    .font(.system(.body, design: .monospaced))
                
                Button("Test Connection") {
                    // Test connection
                }
                .foregroundStyle(.violet)
            }
            
            Section("Appearance") {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(AppSettings.Theme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                
                Picker("Haptics", selection: $selectedHaptic) {
                    ForEach(AppSettings.HapticIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.displayName).tag(intensity)
                    }
                }
            }
            
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .toggleStyle(.glass)
                
                if notificationsEnabled {
                    Toggle("Session Messages", isOn: .constant(true))
                        .toggleStyle(.glass)
                    Toggle("Command Completion", isOn: .constant(true))
                        .toggleStyle(.glass)
                    Toggle("Errors", isOn: .constant(true))
                        .toggleStyle(.glass)
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2026.02.22")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
    }
}
