//
//  Models.swift
//  Models
//
//  Data models for VooDoo Mission Control
//

import SwiftData
import Foundation

// MARK: - Saved Session
@Model
class SavedSession {
    @Attribute(.unique) var id: String
    var name: String
    var sessionType: SessionType
    var lastMessage: String
    var timestamp: Date
    var unreadCount: Int
    var isPinned: Bool
    var isActive: Bool
    var modelName: String?
    var tokenCount: Int?
    
    init(
        id: String,
        name: String,
        sessionType: SessionType = .direct,
        lastMessage: String = "",
        timestamp: Date = Date(),
        unreadCount: Int = 0,
        isPinned: Bool = false,
        isActive: Bool = true,
        modelName: String? = nil,
        tokenCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.sessionType = sessionType
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.unreadCount = unreadCount
        self.isPinned = isPinned
        self.isActive = isActive
        self.modelName = modelName
        self.tokenCount = tokenCount
    }
    
    enum SessionType: String, Codable {
        case direct, agent, subagent, cron
        
        var icon: String {
            switch self {
            case .direct: return "bubble.left.fill"
            case .agent: return "cpu.fill"
            case .subagent: return "person.2.fill"
            case .cron: return "clock.fill"
            }
        }
        
        var color: String {
            switch self {
            case .direct: return "blue"
            case .agent: return "purple"
            case .subagent: return "green"
            case .cron: return "orange"
            }
        }
    }
}

// MARK: - Command History
@Model
class CommandHistory {
    @Attribute(.unique) var id: UUID
    var command: String
    var output: String
    var exitCode: Int
    var timestamp: Date
    var isFavorite: Bool
    var executionTime: TimeInterval?
    
    init(
        command: String,
        output: String = "",
        exitCode: Int = 0,
        timestamp: Date = Date(),
        isFavorite: Bool = false,
        executionTime: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.command = command
        self.output = output
        self.exitCode = exitCode
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.executionTime = executionTime
    }
    
    var wasSuccessful: Bool {
        exitCode == 0
    }
}

// MARK: - App Settings
@Model
class AppSettings {
    @Attribute(.unique) var id: UUID
    var serverURL: String
    var authToken: String
    var theme: Theme
    var hapticIntensity: HapticIntensity
    var notificationsEnabled: Bool
    var sessionNotifications: Bool
    var commandNotifications: Bool
    var errorNotifications: Bool
    var lastSyncDate: Date?
    
    init(
        serverURL: String = "ws://127.0.0.1:18789",
        authToken: String = "",
        theme: Theme = .auto,
        hapticIntensity: HapticIntensity = .medium,
        notificationsEnabled: Bool = true,
        sessionNotifications: Bool = true,
        commandNotifications: Bool = true,
        errorNotifications: Bool = true
    ) {
        self.id = UUID()
        self.serverURL = serverURL
        self.authToken = authToken
        self.theme = theme
        self.hapticIntensity = hapticIntensity
        self.notificationsEnabled = notificationsEnabled
        self.sessionNotifications = sessionNotifications
        self.commandNotifications = commandNotifications
        self.errorNotifications = errorNotifications
    }
    
    enum Theme: String, Codable, CaseIterable {
        case auto, light, dark
        
        var displayName: String {
            switch self {
            case .auto: return "Automatic"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }
    
    enum HapticIntensity: String, Codable, CaseIterable {
        case light, medium, heavy
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .medium: return "Medium"
            case .heavy: return "Heavy"
            }
        }
        
        var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            }
        }
    }
}

// MARK: - Gateway Status
struct GatewayStatus: Codable {
    let isRunning: Bool
    let version: String
    let uptime: TimeInterval
    let memoryUsage: MemoryUsage
    let channels: [ChannelStatus]
    let sessions: SessionSummary
    
    struct MemoryUsage: Codable {
        let used: Int64
        let total: Int64
        let percentage: Double
    }
    
    struct ChannelStatus: Codable {
        let name: String
        let isEnabled: Bool
        let state: String
    }
    
    struct SessionSummary: Codable {
        let active: Int
        let total: Int
    }
}

// MARK: - File Node
struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let modifiedDate: Date
    let children: [FileNode]?
    
    var icon: String {
        if isDirectory {
            return "folder.fill"
        }
        switch name.fileExtension.lowercased() {
        case "swift": return "swift"
        case "js", "ts": return "j.square.fill"
        case "json": return "curlybraces"
        case "md": return "doc.text.fill"
        case "png", "jpg", "jpeg", "gif": return "photo.fill"
        default: return "doc.fill"
        }
    }
    
    var formattedSize: String {
        guard let size = size, !isDirectory else { return "--" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - Message
struct Message: Identifiable, Codable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let type: MessageType
    
    enum MessageType: String, Codable {
        case text, code, image, tool, error, system
    }
}

// MARK: - Helper Extensions
extension String {
    var fileExtension: String {
        (self as NSString).pathExtension
    }
    
    var fileNameWithoutExtension: String {
        (self as NSString).deletingPathExtension
    }
}
