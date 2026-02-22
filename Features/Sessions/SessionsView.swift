//
//  SessionsView.swift
//  Features/Sessions
//
//  Session management and messaging
//

import SwiftUI
import SwiftData

struct SessionsView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: [SortDescriptor(\.isPinned, order: .reverse), SortDescriptor(\.timestamp, order: .reverse)]) 
    var sessions: [SavedSession]
    
    @State private var selectedSession: SavedSession?
    @State private var searchText = ""
    
    var filteredSessions: [SavedSession] {
        if searchText.isEmpty {
            return sessions
        }
        return sessions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredSessions) { session in
                    SessionRow(session: session, isSelected: selectedSession?.id == session.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.glassQuick) {
                                selectedSession = session
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                togglePin(session)
                            } label: {
                                Label(session.isPinned ? "Unpin" : "Pin", 
                                      systemImage: session.isPinned ? "pin.slash" : "pin")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                killSession(session)
                            } label: {
                                Label("Kill", systemImage: "xmark.circle")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Sessions")
            .searchable(text: $searchText, prompt: "Search sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {}) {
                            Label("New Session", systemImage: "plus")
                        }
                        Button(action: {}) {
                            Label("Spawn Sub-agent", systemImage: "person.2")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .overlay {
                if sessions.isEmpty {
                    EmptySessionsListView()
                }
            }
            
            // Detail view or placeholder
            if let session = selectedSession {
                SessionDetailView(session: session)
            } else {
                NoSessionSelectedView()
            }
        }
        .navigationViewStyle(.columns)
    }
    
    private func togglePin(_ session: SavedSession) {
        session.isPinned.toggle()
    }
    
    private func killSession(_ session: SavedSession) {
        // API call to kill session
        session.isActive = false
    }
}

struct SessionRow: View {
    let session: SavedSession
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Session icon with status
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(session.isActive ? Color.violet.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconForType(session.sessionType))
                    .font(.title3)
                    .foregroundStyle(session.isActive ? .violet : .gray)
                
                if session.isActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 2, y: 2)
                }
            }
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    
                    if session.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    
                    Spacer()
                    
                    Text(formattedTime(session.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(session.lastMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                if let model = session.modelName {
                    HStack(spacing: 4) {
                        Image(systemName: "cpu")
                            .font(.system(size: 8))
                        Text(model)
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            // Unread count
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
        .padding(.vertical, 4)
        .background(isSelected ? Color.violet.opacity(0.1) : Color.clear)
        .contentTransition(.opacity)
    }
    
    private func iconForType(_ type: SavedSession.SessionType) -> String {
        type.icon
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct SessionDetailView: View {
    let session: SavedSession
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            
            // Input area
            VStack(spacing: 0) {
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "paperclip")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    TextEditor(text: $messageText)
                        .font(.body)
                        .frame(minHeight: 36, maxHeight: 100)
                        .padding(8)
                        .glassBackground(.thin, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .foregroundStyle(messageText.isEmpty ? .secondary : .violet)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .glassBackground(.thick, in: Rectangle())
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("View Logs", systemImage: "doc.text")
                    }
                    Button(action: {}) {
                        Label("Spawn Sub-agent", systemImage: "person.2")
                    }
                    Divider()
                    Button(role: .destructive, action: {}) {
                        Label("Kill Session", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await loadMessages()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date(),
            type: .text
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func loadMessages() async {
        isLoading = true
        // Load from API
        isLoading = false
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                contentView
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .glassBackground(
                        message.isFromUser ? .thin : .ultraThin,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .background(
                        message.isFromUser ?
                            Color.violet.opacity(0.2) :
                            Color.white.opacity(0.05)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                Text(formattedTime(message.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 280, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .glassScale()
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch message.type {
        case .code:
            Text(message.content)
                .font(.system(.body, design: .monospaced))
        case .image:
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 150)
        default:
            Text(message.content)
                .font(.body)
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NoSessionSelectedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Select a Session")
                .font(.title3.weight(.semibold))
            
            Text("Choose a session from the list to view messages")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

struct EmptySessionsListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("No Sessions")
                .font(.headline)
            
            Text("Create a new session to start chatting")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
