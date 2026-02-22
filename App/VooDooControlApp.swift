//
//  VooDooControlApp.swift
//  VooDooControl
//
//  Mission Control for OpenClaw — Liquid Glass Edition
//

import SwiftUI
import SwiftData

@main
struct VooDooControlApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .glassBackground(.thick)
        }
        .modelContainer(for: [SavedSession.self, CommandHistory.self, AppSettings.self])
    }
}

// MARK: - Global App State
@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .dashboard
    @Published var isConnected: Bool = false {
        didSet {
            WidgetDataManager.shared.updateConnectionStatus(isConnected)
        }
    }
    @Published var lastHeartbeat: Date? {
        didSet {
            if let date = lastHeartbeat {
                WidgetDataManager.shared.updateLastHeartbeat(date)
            }
        }
    }
    @Published var memoryUsage: Double = 0 {
        didSet {
            WidgetDataManager.shared.updateMemoryUsage(memoryUsage)
        }
    }
    @Published var activeSessions: Int = 0 {
        didSet {
            WidgetDataManager.shared.updateActiveSessions(activeSessions)
        }
    }
    @Published var currentError: String?
    
    private var webSocketManager: WebSocketManager?
    
    enum Tab {
        case dashboard, sessions, files, terminal, tools, status, settings
    }
    
    func connect() {
        // Initialize WebSocket connection
        webSocketManager = WebSocketManager(appState: self)
        webSocketManager?.connect()
    }
    
    func disconnect() {
        webSocketManager?.disconnect()
        webSocketManager = nil
    }
}
