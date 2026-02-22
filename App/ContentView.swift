//
//  ContentView.swift
//  App
//
//  Main container with tab navigation
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Query private var settings: [AppSettings]
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Home")
                }
                .tag(AppState.Tab.dashboard)
            
            SessionsView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Sessions")
                }
                .tag(AppState.Tab.sessions)
            
            FilesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Files")
                }
                .tag(AppState.Tab.files)
            
            TerminalView()
                .tabItem {
                    Image(systemName: "terminal.fill")
                    Text("Terminal")
                }
                .tag(AppState.Tab.terminal)
            
            ToolsView()
                .tabItem {
                    Image(systemName: "wrench.fill")
                    Text("Tools")
                }
                .tag(AppState.Tab.tools)
            
            StatusView()
                .tabItem {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                    Text("Status")
                }
                .tag(AppState.Tab.status)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(AppState.Tab.settings)
        }
        .tint(.violet)
        .onAppear {
            appState.connect()
            configureAppearance()
        }
    }
    
    private func configureAppearance() {
        // Custom tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingNewSessionSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status Cards Row
                HStack(spacing: 12) {
                    ConnectionStatusCard()
                        .frame(maxWidth: .infinity)
                    
                    MemoryUsageCard()
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 120)
                
                // Active Sessions Preview
                ActiveSessionsSection()
                
                // Quick Actions
                QuickActionsSection()
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .navigationTitle("VooDoo Control")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewSessionSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .sheet(isPresented: $showingNewSessionSheet) {
            NewSessionSheet()
        }
    }
}

// MARK: - Connection Status Card
struct ConnectionStatusCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: appState.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(appState.isConnected ? .green : .red)
                    .pulse(color: appState.isConnected ? .green : .red)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Gateway")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Text(appState.isConnected ? "Connected" : "Disconnected")
                    .font(.headline)
            }
            
            if let heartbeat = appState.lastHeartbeat {
                Text("Last sync: \(timeAgo(from: heartbeat))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .glassCard(thickness: .thick)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Memory Usage Card
struct MemoryUsageCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cpu.fill")
                    .font(.title2)
                    .foregroundStyle(.violet)
                
                Spacer()
                
                Text("\(Int(appState.memoryUsage))%")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.violet)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Memory")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Text("\(appState.activeSessions) active sessions")
                    .font(.headline)
            }
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.violet.opacity(0.7), .violet],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * (appState.memoryUsage / 100), height: 4)
                        .animation(.glassSmooth, value: appState.memoryUsage)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .glassCard(thickness: .thick)
    }
}

// MARK: - Active Sessions Section
struct ActiveSessionsSection: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \SavedSession.timestamp, order: .reverse) var sessions: [SavedSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Sessions")
                    .font(.title3.weight(.semibold))
                
                Spacer()
                
                Button("See All") {
                    appState.selectedTab = .sessions
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.violet)
            }
            
            if sessions.isEmpty {
                EmptySessionsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(sessions.prefix(3)) { session in
                        SessionPreviewRow(session: session)
                    }
                }
            }
        }
        .padding()
        .glassCard(thickness: .regular)
    }
}

struct SessionPreviewRow: View {
    let session: SavedSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.violet.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "bubble.left.fill")
                    .font(.title3)
                    .foregroundStyle(.violet)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                
                Text(session.lastMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Unread badge
            if session.unreadCount > 0 {
                Text("\(session.unreadCount)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.violet)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct EmptySessionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No active sessions")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    let actions: [(icon: String, title: String, color: Color)] = [
        ("plus.bubble.fill", "New Chat", .violet),
        ("terminal.fill", "Run Command", .green),
        ("doc.text.fill", "View Logs", .orange),
        ("gear", "Settings", .gray)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title3.weight(.semibold))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(actions, id: \.title) { action in
                    QuickActionButton(
                        icon: action.icon,
                        title: action.title,
                        color: action.color
                    )
                }
            }
        }
        .padding()
        .glassCard(thickness: .regular)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                
                Spacer()
            }
            .padding()
            .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - New Session Sheet
struct NewSessionSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var sessionName = ""
    @State private var selectedModel = "default"
    
    let models = ["default", "kimi-k2-thinking", "claude-3-opus", "gpt-4"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Details") {
                    TextField("Name", text: $sessionName)
                    
                    Picker("Model", selection: $selectedModel) {
                        ForEach(models, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
                
                Section {
                    Button("Create Session") {
                        // Create session logic
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.violet)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    static let violet = Color(red: 0.482, green: 0.380, blue: 1.0)
}
