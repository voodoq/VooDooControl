//
//  ToolsView.swift
//  Features/Tools
//
//  Quick actions and utilities
//

import SwiftUI

struct ToolsView: View {
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var searchResults: [SearchResult] = []
    
    let tools: [ToolItem] = [
        ToolItem(
            icon: "magnifyingglass",
            title: "Web Search",
            description: "Search the web",
            color: .blue,
            action: .webSearch
        ),
        ToolItem(
            icon: "doc.text.magnifyingglass",
            title: "Fetch URL",
            description: "Extract content from a webpage",
            color: .green,
            action: .fetchURL
        ),
        ToolItem(
            icon: "arrow.triangle.branch",
            title: "Git Status",
            description: "Check repository status",
            color: .orange,
            action: .gitStatus
        ),
        ToolItem(
            icon: "arrow.up.arrow.down",
            title: "Git Pull",
            description: "Pull latest changes",
            color: .orange,
            action: .gitPull
        ),
        ToolItem(
            icon: "checkmark.circle",
            title: "Git Commit",
            description: "Commit changes",
            color: .orange,
            action: .gitCommit
        ),
        ToolItem(
            icon: "arrow.up.circle",
            title: "Git Push",
            description: "Push to remote",
            color: .orange,
            action: .gitPush
        ),
        ToolItem(
            icon: "memorychip",
            title: "Clear Memory",
            description: "Free up memory",
            color: .red,
            action: .clearMemory
        ),
        ToolItem(
            icon: "arrow.clockwise",
            title: "Restart Gateway",
            description: "Restart OpenClaw",
            color: .red,
            action: .restartGateway
        ),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search bar
                    SearchBar(query: $searchQuery, isSearching: $isSearching)
                    
                    // Tools grid
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 12
                    ) {
                        ForEach(tools) { tool in
                            ToolButton(tool: tool)
                        }
                    }
                    
                    // Recent actions
                    RecentActionsSection()
                }
                .padding()
            }
            .navigationTitle("Tools")
        }
    }
}

struct SearchBar: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search the web...", text: $query)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !query.isEmpty {
                    Button(action: { query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .glassCapsule(thickness: .thin)
            
            if isSearching {
                HStack {
                    Spacer()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
    }
    
    private func performSearch() {
        guard !query.isEmpty else { return }
        isSearching = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isSearching = false
        }
    }
}

struct ToolButton: View {
    let tool: ToolItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            executeTool()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tool.icon)
                        .font(.title2)
                        .foregroundStyle(tool.color)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.title)
                        .font(.subheadline.weight(.semibold))
                    
                    Text(tool.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(height: 100, alignment: .topLeading)
            .glassCard(thickness: .thin, cornerRadius: 16)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.glassQuick) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.glassQuick) {
                isPressed = false
            }
        }
    }
    
    private func executeTool() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Execute based on action type
        switch tool.action {
        case .webSearch:
            print("Web search")
        case .gitStatus:
            print("Git status")
        default:
            break
        }
    }
}

struct RecentActionsSection: View {
    let actions = [
        ("Web search: SwiftUI animations", "2m ago", "magnifyingglass"),
        ("Git commit: Fix memory leak", "15m ago", "checkmark.circle"),
        ("Fetched URL: docs.openclaw.ai", "1h ago", "doc.text"),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Actions")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear") {}
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ForEach(actions, id: \.0) { action in
                HStack(spacing: 12) {
                    Image(systemName: action.2)
                        .font(.body)
                        .foregroundStyle(.violet)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(action.0)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Text(action.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding()
        .glassCard(thickness: .regular)
    }
}

struct ToolItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: ToolAction
}

enum ToolAction {
    case webSearch, fetchURL
    case gitStatus, gitPull, gitCommit, gitPush
    case clearMemory, restartGateway
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let snippet: String
}

// MARK: - Press Events Modifier
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}
