//
//  OpenClawAPI.swift
//  Services
//
//  REST API client for OpenClaw Gateway
//

import Foundation

actor OpenClawAPI {
    static let shared = OpenClawAPI()
    
    private var baseURL: URL = URL(string: "http://127.0.0.1:18789")!
    private var authToken: String = ""
    
    private init() {}
    
    func configure(serverURL: String, authToken: String) {
        self.baseURL = URL(string: serverURL)!
        self.authToken = authToken
    }
    
    // MARK: - Status
    func fetchStatus() async throws -> GatewayStatus {
        let data = try await request("/status")
        return try JSONDecoder().decode(GatewayStatus.self, from: data)
    }
    
    // MARK: - Sessions
    func listSessions() async throws -> [SessionDTO] {
        let data = try await request("/sessions")
        return try JSONDecoder().decode([SessionDTO].self, from: data)
    }
    
    func fetchSessionHistory(sessionId: String, limit: Int = 50) async throws -> [MessageDTO] {
        let data = try await request("/sessions/\(sessionId)/history?limit=\(limit)")
        return try JSONDecoder().decode([MessageDTO].self, from: data)
    }
    
    func sendMessage(to sessionId: String, content: String) async throws {
        let body = ["message": content]
        _ = try await request("/sessions/\(sessionId)/send", method: "POST", body: body)
    }
    
    func spawnSubAgent(task: String, model: String? = nil) async throws -> String {
        var body: [String: Any] = ["task": task]
        if let model = model {
            body["model"] = model
        }
        let data = try await request("/sessions/spawn", method: "POST", body: body)
        let response = try JSONDecoder().decode(SpawnResponse.self, from: data)
        return response.sessionKey
    }
    
    func killSession(_ sessionId: String) async throws {
        _ = try await request("/sessions/\(sessionId)/kill", method: "POST")
    }
    
    // MARK: - Files
    func listFiles(path: String = ".") async throws -> [FileDTO] {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let data = try await request("/files?path=\(encodedPath)")
        return try JSONDecoder().decode([FileDTO].self, from: data)
    }
    
    func readFile(path: String) async throws -> String {
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let data = try await request("/files/\(encodedPath)")
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func writeFile(path: String, content: String) async throws {
        let body = ["content": content]
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        _ = try await request("/files/\(encodedPath)", method: "PUT", body: body)
    }
    
    // MARK: - Terminal/Commands
    func executeCommand(_ command: String, timeout: Int = 30) async throws -> CommandResult {
        let body = [
            "command": command,
            "timeout": timeout
        ] as [String: Any]
        let data = try await request("/exec", method: "POST", body: body)
        return try JSONDecoder().decode(CommandResult.self, from: data)
    }
    
    // MARK: - Cron
    func listCronJobs() async throws -> [CronJobDTO] {
        let data = try await request("/cron/list")
        return try JSONDecoder().decode([CronJobDTO].self, from: data)
    }
    
    func runCronJob(id: String) async throws {
        _ = try await request("/cron/run/\(id)", method: "POST")
    }
    
    // MARK: - Private
    private func request(
        _ path: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        return data
    }
}

// MARK: - DTOs
struct SessionDTO: Codable, Identifiable {
    let id: String
    let key: String
    let kind: String
    let age: String
    let model: String?
    let tokens: TokenInfo?
    
    struct TokenInfo: Codable {
        let used: Int
        let total: Int
    }
}

struct MessageDTO: Codable, Identifiable {
    let id: String
    let role: String
    let content: String
    let timestamp: String
}

struct FileDTO: Codable {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let modified: String
}

struct CommandResult: Codable {
    let output: String
    let exitCode: Int
    let executionTime: Double?
}

struct SpawnResponse: Codable {
    let sessionKey: String
    let status: String
}

struct CronJobDTO: Codable, Identifiable {
    let id: String
    let name: String
    let schedule: String
    let isEnabled: Bool
    let lastRun: String?
    let nextRun: String?
}

// MARK: - Errors
enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, let message):
            return "HTTP \(code): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
