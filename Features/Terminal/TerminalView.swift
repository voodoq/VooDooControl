//
//  TerminalView.swift
//  Features/Terminal
//
//  Command execution interface
//

import SwiftUI
import SwiftData

struct TerminalView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \CommandHistory.timestamp, order: .reverse) var history: [CommandHistory]
    
    @State private var commandText = ""
    @State private var isExecuting = false
    @State private var currentOutput = ""
    @State private var scrollToBottom = false
    @FocusState private var isInputFocused: Bool
    
    let quickCommands = [
        "openclaw status",
        "git status",
        "ls -la",
        "pwd",
        "npm run dev"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Terminal output
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(history) { entry in
                            TerminalEntryRow(entry: entry)
                                .id(entry.id)
                        }
                        
                        if !currentOutput.isEmpty {
                            CurrentOutputView(output: currentOutput)
                                .id("current")
                        }
                    }
                    .padding()
                }
                .onChange(of: history.count) { _, _ in
                    if let first = history.first {
                        withAnimation {
                            proxy.scrollTo(first.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: currentOutput) { _, _ in
                    withAnimation {
                        proxy.scrollTo("current", anchor: .bottom)
                    }
                }
            }
            .background(
                Color.black.opacity(0.3)
                    .overlay(.ultraThinMaterial)
            )
            
            // Quick commands toolbar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickCommands, id: \.self) { cmd in
                        Button(cmd) {
                            commandText = cmd
                        }
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .glassCapsule(thickness: .thin)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .glassBackground(.thick, in: Rectangle())
            
            // Input area
            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack(spacing: 12) {
                    Text("$")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.green)
                    
                    TextField("Enter command...", text: $commandText)
                        .font(.system(.body, design: .monospaced))
                        .focused($isInputFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            executeCommand()
                        }
                        .disabled(isExecuting)
                    
                    if isExecuting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Button(action: executeCommand) {
                            Image(systemName: "return")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(commandText.isEmpty ? .secondary : .green)
                        }
                        .disabled(commandText.isEmpty)
                    }
                }
                .padding()
            }
            .glassBackground(.thick, in: Rectangle())
        }
        .navigationTitle("Terminal")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: clearHistory) {
                        Label("Clear History", systemImage: "trash")
                    }
                    Button(action: {}) {
                        Label("Favorite Commands", systemImage: "star")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private func executeCommand() {
        guard !commandText.isEmpty else { return }
        
        isExecuting = true
        let cmd = commandText
        commandText = ""
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Simulate command execution
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            let output = "Mock output for: \(cmd)\n\nLine 1\nLine 2\nLine 3"
            let newEntry = CommandHistory(
                command: cmd,
                output: output,
                exitCode: 0,
                executionTime: 1.0
            )
            
            // Save to SwiftData (would need context)
            currentOutput = ""
            isExecuting = false
        }
    }
    
    private func clearHistory() {
        // Clear history logic
    }
}

struct TerminalEntryRow: View {
    let entry: CommandHistory
    @State private var isExpanded = false
    @State private var showCopyFeedback = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Command header
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("$")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.green)
                    
                    Text(entry.command)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(entry.wasSuccessful ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        if let time = entry.executionTime {
                            Text(String(format: "%.2fs", time))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Output (if expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.output)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    HStack {
                        Button(action: copyOutput) {
                            Image(systemName: showCopyFeedback ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                        }
                        .foregroundStyle(.violet)
                        
                        Spacer()
                        
                        Text(formattedDate(entry.timestamp))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 24)
            }
        }
        .glassScale()
    }
    
    private func copyOutput() {
        UIPasteboard.general.string = entry.output
        showCopyFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopyFeedback = false
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CurrentOutputView: View {
    let output: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                
                Text("Running...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !output.isEmpty {
                Text(output)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }
}
