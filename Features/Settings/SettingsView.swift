//
//  SettingsView.swift
//  Features/Settings
//
//  App configuration and preferences
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var settingsList: [AppSettings]
    @Environment(\.modelContext) private var context
    
    private var settings: AppSettings {
        settingsList.first ?? AppSettings()
    }
    
    @State private var showToken = false
    @State private var testConnectionResult: Bool?
    @State private var isTesting = false
    
    var body: some View {
        NavigationView {
            Form {
                // Connection Section
                Section("Gateway Connection") {
                    HStack {
                        Text("Status")
                        Spacer()
                        ConnectionStatusBadge()
                    }
                    
                    TextField("Server URL", text: bindSettings(\.serverURL))
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    HStack {
                        if showToken {
                            TextField("Auth Token", text: bindSettings(\.authToken))
                                .autocapitalization(.none)
                        } else {
                            SecureField("Auth Token", text: bindSettings(\.authToken))
                        }
                        
                        Button(action: { showToken.toggle() }) {
                            Image(systemName: showToken ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button(action: testConnection) {
                        HStack {
                            Text("Test Connection")
                            Spacer()
                            if isTesting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else if let result = testConnectionResult {
                                Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(result ? .green : .red)
                            }
                        }
                    }
                    .disabled(settings.serverURL.isEmpty || isTesting)
                }
                
                // Appearance Section
                Section("Appearance") {
                    Picker("Theme", selection: bindSettings(\.theme)) {
                        ForEach(AppSettings.Theme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    
                    Picker("Haptic Intensity", selection: bindSettings(\.hapticIntensity)) {
                        ForEach(AppSettings.HapticIntensity.allCases) { intensity in
                            Text(intensity.displayName).tag(intensity)
                        }
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: bindSettings(\.notificationsEnabled))
                    
                    if settings.notificationsEnabled {
                        Toggle("Session Messages", isOn: bindSettings(\.sessionNotifications))
                        Toggle("Command Completed", isOn: bindSettings(\.commandNotifications))
                        Toggle("Errors", isOn: bindSettings(\.errorNotifications))
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2026.02.19")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://docs.openclaw.ai")!) {
                        HStack {
                            Text("Documentation")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/openclaw/openclaw")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive, action: resetSettings) {
                        Text("Reset All Settings")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func bindSettings<T>(_ keyPath: ReferenceWritableKeyPath<AppSettings, T>) -> Binding<T> {
        Binding(
            get: { self.settings[keyPath: keyPath] },
            set: { newValue in
                self.settings[keyPath: keyPath] = newValue
                try? self.context.save()
            }
        )
    }
    
    private func testConnection() {
        isTesting = true
        testConnectionResult = nil
        
        Task {
            do {
                // Test API connection
                let api = OpenClawAPI.shared
                api.configure(serverURL: settings.serverURL, authToken: settings.authToken)
                _ = try await api.fetchStatus()
                testConnectionResult = true
            } catch {
                testConnectionResult = false
            }
            isTesting = false
        }
    }
    
    private func resetSettings() {
        settings.serverURL = "ws://127.0.0.1:18789"
        settings.authToken = ""
        settings.theme = .auto
        settings.hapticIntensity = .medium
        settings.notificationsEnabled = true
        settings.sessionNotifications = true
        settings.commandNotifications = true
        settings.errorNotifications = true
        try? context.save()
    }
}

struct ConnectionStatusBadge: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(appState.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(appState.isConnected ? "Connected" : "Disconnected")
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glassCapsule(thickness: .ultraThin)
    }
}

extension AppSettings.Theme: Identifiable {
    var id: String { rawValue }
}

extension AppSettings.HapticIntensity: Identifiable {
    var id: String { rawValue }
}
