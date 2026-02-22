//
//  WidgetDataManager.swift
//  Services
//
//  Shares data with widgets via App Groups
//

import Foundation

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let suiteName = "group.com.voodoo.control"
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    private init() {}
    
    // MARK: - Update Methods
    func updateConnectionStatus(isConnected: Bool) {
        defaults?.set(isConnected, forKey: "isConnected")
        defaults?.set(Date(), forKey: "lastUpdate")
        reloadWidgets()
    }
    
    func updateActiveSessions(_ count: Int) {
        defaults?.set(count, forKey: "activeSessions")
        reloadWidgets()
    }
    
    func updateMemoryUsage(_ percentage: Double) {
        defaults?.set(percentage, forKey: "memoryUsage")
        reloadWidgets()
    }
    
    func updateLastHeartbeat(_ date: Date) {
        defaults?.set(date, forKey: "lastHeartbeat")
        reloadWidgets()
    }
    
    func updateAll(
        isConnected: Bool,
        activeSessions: Int,
        memoryUsage: Double,
        lastHeartbeat: Date?
    ) {
        defaults?.set(isConnected, forKey: "isConnected")
        defaults?.set(activeSessions, forKey: "activeSessions")
        defaults?.set(memoryUsage, forKey: "memoryUsage")
        if let heartbeat = lastHeartbeat {
            defaults?.set(heartbeat, forKey: "lastHeartbeat")
        }
        defaults?.set(Date(), forKey: "lastUpdate")
        reloadWidgets()
    }
    
    // MARK: - Read Methods
    func getStatus() -> WidgetStatus {
        WidgetStatus(
            isConnected: defaults?.bool(forKey: "isConnected") ?? false,
            activeSessions: defaults?.integer(forKey: "activeSessions") ?? 0,
            memoryUsage: defaults?.double(forKey: "memoryUsage") ?? 0,
            lastHeartbeat: defaults?.object(forKey: "lastHeartbeat") as? Date,
            lastUpdate: defaults?.object(forKey: "lastUpdate") as? Date
        )
    }
    
    // MARK: - Private
    private func reloadWidgets() {
        #if canImport(WidgetKit)
        import WidgetKit
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

struct WidgetStatus {
    let isConnected: Bool
    let activeSessions: Int
    let memoryUsage: Double
    let lastHeartbeat: Date?
    let lastUpdate: Date?
}
