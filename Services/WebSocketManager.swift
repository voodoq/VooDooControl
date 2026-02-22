//
//  WebSocketManager.swift
//  Services
//
//  Real-time connection to OpenClaw Gateway
//

import Foundation

@MainActor
class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let appState: AppState
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    private var reconnectTimer: Timer?
    
    @Published var isConnected = false
    @Published var lastError: String?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func connect() {
        guard webSocketTask?.state != .running else { return }
        
        let url = URL(string: "ws://127.0.0.1:18789/ws")!
        var request = URLRequest(url: url)
        request.setValue("your-auth-token", forHTTPHeaderField: "Authorization")
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.delegate = self
        
        isConnected = true
        appState.isConnected = true
        reconnectAttempts = 0
        
        receiveMessage()
        webSocketTask?.resume()
        
        // Send heartbeat every 30 seconds
        startHeartbeat()
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        appState.isConnected = false
    }
    
    func send(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocketTask?.send(.string(string)) { [weak self] error in
            if let error = error {
                Task { @MainActor in
                    self?.lastError = error.localizedDescription
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let message):
                    self?.handleMessage(message)
                    self?.receiveMessage() // Continue listening
                    
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            handleEvent(json)
            
        case .data(let data):
            // Handle binary data if needed
            print("Received binary data: \(data.count) bytes")
            
        @unknown default:
            break
        }
    }
    
    private func handleEvent(_ event: [String: Any]) {
        guard let type = event["type"] as? String else { return }
        
        switch type {
        case "heartbeat":
            appState.lastHeartbeat = Date()
            if let memory = event["memory"] as? Double {
                appState.memoryUsage = memory
            }
            if let sessions = event["sessions"] as? Int {
                appState.activeSessions = sessions
            }
            
        case "message":
            // Handle new message from session
            NotificationCenter.default.post(
                name: .newMessageReceived,
                object: nil,
                userInfo: event
            )
            
        case "session_update":
            // Handle session status change
            NotificationCenter.default.post(
                name: .sessionUpdated,
                object: nil,
                userInfo: event
            )
            
        case "command_complete":
            // Handle command completion
            NotificationCenter.default.post(
                name: .commandCompleted,
                object: nil,
                userInfo: event
            )
            
        case "error":
            if let error = event["message"] as? String {
                appState.currentError = error
            }
            
        default:
            break
        }
    }
    
    private func handleError(_ error: Error) {
        isConnected = false
        appState.isConnected = false
        lastError = error.localizedDescription
        
        // Attempt reconnection with exponential backoff
        guard reconnectAttempts < maxReconnectAttempts else {
            appState.currentError = "Max reconnection attempts reached"
            return
        }
        
        let delay = min(pow(2.0, Double(reconnectAttempts)), 60) // Max 60 seconds
        reconnectAttempts += 1
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.connect()
            }
        }
    }
    
    private func startHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.send(["type": "ping"])
        }
    }
}

// MARK: - WebSocket Delegate
extension WebSocketManager: URLSessionWebSocketDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        Task { @MainActor in
            self.isConnected = true
            self.appState.isConnected = true
            self.reconnectAttempts = 0
        }
    }
    
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        Task { @MainActor in
            self.isConnected = false
            self.appState.isConnected = false
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let newMessageReceived = Notification.Name("newMessageReceived")
    static let sessionUpdated = Notification.Name("sessionUpdated")
    static let commandCompleted = Notification.Name("commandCompleted")
}
