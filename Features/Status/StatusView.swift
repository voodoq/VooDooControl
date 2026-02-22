//
//  StatusView.swift
//  Features/Status
//
//  Gateway health and system monitoring
//

import SwiftUI
import Charts

struct StatusView: View {
    @EnvironmentObject var appState: AppState
    @State private var status: GatewayStatus?
    @State private var memoryHistory: [MemoryPoint] = []
    @State private var isLoading = true
    @State private var selectedTab: StatusTab = .overview
    
    enum StatusTab {
        case overview, channels, cron, logs
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Tab selector
                GlassSegmentedControl(
                    options: StatusTab.allCases,
                    titles: { tab in
                        switch tab {
                        case .overview: return "Overview"
                        case .channels: return "Channels"
                        case .cron: return "Cron"
                        case .logs: return "Logs"
                        }
                    },
                    selection: $selectedTab
                )
                .padding(.horizontal)
                
                // Content based on tab
                switch selectedTab {
                case .overview:
                    OverviewSection(status: status, memoryHistory: memoryHistory)
                case .channels:
                    ChannelsSection()
                case .cron:
                    CronSection()
                case .logs:
                    LogsSection()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Status")
        .task {
            await loadStatus()
        }
        .refreshable {
            await loadStatus()
        }
    }
    
    private func loadStatus() async {
        isLoading = true
        // Mock data
        status = GatewayStatus(
            isRunning: true,
            version: "2026.2.19-2",
            uptime: 86400,
            memoryUsage: .init(used: 512_000_000, total: 2_000_000_000, percentage: 25.6),
            channels: [
                .init(name: "Telegram", isEnabled: true, state: "OK"),
                .init(name: "Discord", isEnabled: false, state: "OFF"),
                .init(name: "WhatsApp", isEnabled: false, state: "OFF")
            ],
            sessions: .init(active: 3, total: 5)
        )
        
        memoryHistory = (0..<24).map { hour in
            MemoryPoint(
                time: Date().addingTimeInterval(Double(hour) * -3600),
                usage: Double.random(in: 20...40)
            )
        }
        
        isLoading = false
    }
}

struct OverviewSection: View {
    let status: GatewayStatus?
    let memoryHistory: [MemoryPoint]
    
    var body: some View {
        VStack(spacing: 16) {
            // Health card
            if let status = status {
                HealthCard(status: status)
            }
            
            // Memory chart
            MemoryChartCard(history: memoryHistory)
            
            // Stats grid
            StatsGrid(status: status)
        }
        .padding(.horizontal)
    }
}

struct HealthCard: View {
    let status: GatewayStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gateway Health")
                        .font(.headline)
                    
                    Text("Version \(status.version)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(status.isRunning ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                        .pulse(color: status.isRunning ? .green : .red)
                    
                    Text(status.isRunning ? "Healthy" : "Offline")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(status.isRunning ? .green : .red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .glassCapsule(thickness: .thin)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 24) {
                StatItem(
                    icon: "clock",
                    value: formattedUptime(status.uptime),
                    label: "Uptime"
                )
                
                StatItem(
                    icon: "cpu",
                    value: String(format: "%.1f%%", status.memoryUsage.percentage),
                    label: "Memory"
                )
                
                StatItem(
                    icon: "person.2",
                    value: "\(status.sessions.active)/\(status.sessions.total)",
                    label: "Sessions"
                )
            }
        }
        .padding()
        .glassCard(thickness: .thick)
    }
    
    private func formattedUptime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct MemoryChartCard: View {
    let history: [MemoryPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Memory Usage (24h)")
                .font(.headline)
            
            Chart(history) { point in
                AreaMark(
                    x: .value("Time", point.time),
                    y: .value("Usage", point.usage)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.violet.opacity(0.3), .violet.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Time", point.time),
                    y: .value("Usage", point.usage)
                )
                .foregroundStyle(.violet)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartYScale(domain: 0...100)
            .frame(height: 150)
        }
        .padding()
        .glassCard(thickness: .regular)
    }
}

struct StatsGrid: View {
    let status: GatewayStatus?
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                icon: "checkmark.shield",
                title: "Security",
                value: "1 Critical",
                color: .red
            )
            
            StatCard(
                icon: "network",
                title: "Latency",
                value: "38ms",
                color: .green
            )
            
            StatCard(
                icon: "memorychip",
                title: "Heap Used",
                value: status?.memoryUsage.formattedUsed ?? "--",
                color: .orange
            )
            
            StatCard(
                icon: "arrow.down.arrow.up",
                title: "Requests",
                value: "1.2k/min",
                color: .blue
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3.weight(.bold))
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .glassCard(thickness: .thin, cornerRadius: 16)
    }
}

struct ChannelsSection: View {
    var body: some View {
        VStack(spacing: 12) {
            ChannelRow(
                name: "Telegram",
                icon: "paperplane.fill",
                status: "Connected",
                isEnabled: true
            )
            
            ChannelRow(
                name: "Discord",
                icon: "bubble.left.and.bubble.right.fill",
                status: "Disabled",
                isEnabled: false
            )
            
            ChannelRow(
                name: "WhatsApp",
                icon: "phone.fill",
                status: "Disabled",
                isEnabled: false
            )
        }
        .padding(.horizontal)
    }
}

struct ChannelRow: View {
    let name: String
    let icon: String
    let status: String
    @State var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isEnabled ? .violet : .secondary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                
                Text(status)
                    .font(.caption)
                    .foregroundStyle(isEnabled ? .green : .secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(.glass)
                .labelsHidden()
        }
        .padding()
        .glassCard(thickness: .thin, cornerRadius: 16)
    }
}

struct CronSection: View {
    var body: some View {
        VStack(spacing: 12) {
            CronJobRow(
                name: "Health Check",
                schedule: "Every 30m",
                lastRun: "2m ago",
                isEnabled: true
            )
            
            CronJobRow(
                name: "Backup",
                schedule: "Daily at 2am",
                lastRun: "10h ago",
                isEnabled: true
            )
            
            CronJobRow(
                name: "Cleanup",
                schedule: "Weekly",
                lastRun: "3d ago",
                isEnabled: false
            )
        }
        .padding(.horizontal)
    }
}

struct CronJobRow: View {
    let name: String
    let schedule: String
    let lastRun: String
    @State var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                
                Text(schedule)
                    .font(.caption)
                    .foregroundStyle(.violet)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(lastRun)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.glass)
                    .labelsHidden()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .glassCard(thickness: .thin, cornerRadius: 16)
    }
}

struct LogsSection: View {
    let logs = [
        (level: "INFO", message: "Gateway started successfully", time: "12:34:56"),
        (level: "WARN", message: "High memory usage detected", time: "12:30:12"),
        (level: "ERROR", message: "Failed to connect to Discord", time: "12:15:45"),
        (level: "INFO", message: "Session spawned: agent-123", time: "12:10:33"),
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(logs, id: \.time) { log in
                LogRow(level: log.level, message: log.message, time: log.time)
            }
        }
        .padding(.horizontal)
    }
}

struct LogRow: View {
    let level: String
    let message: String
    let time: String
    
    var levelColor: Color {
        switch level {
        case "INFO": return .blue
        case "WARN": return .orange
        case "ERROR": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(level)
                .font(.caption.weight(.bold))
                .foregroundStyle(levelColor)
                .frame(width: 50, alignment: .leading)
            
            Text(message)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospaced()
        }
        .padding()
        .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline.weight(.semibold))
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MemoryPoint: Identifiable {
    let id = UUID()
    let time: Date
    let usage: Double
}

extension GatewayStatus.MemoryUsage {
    var formattedUsed: String {
        ByteCountFormatter.string(fromByteCount: used, countStyle: .memory)
    }
}

extension StatusTab: CaseIterable {}
