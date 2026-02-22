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
    @Published var isConnected: Bool = false
    @Published var lastHeartbeat: Date?
    @Published var memoryUsage: Double = 0
    @Published var activeSessions: Int = 0
    @Published var currentError: String?
    
    private var webSocketManager: WebSocketManager?
    
    enum Tab {
        case dashboard, sessions, files, terminal, status
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
