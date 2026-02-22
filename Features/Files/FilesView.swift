//
//  FilesView.swift
//  Features/Files
//
//  File browser and editor
//

import SwiftUI

struct FilesView: View {
    @State private var currentPath = "."
    @State private var files: [FileNode] = []
    @State private var selectedFile: FileNode?
    @State private var isLoading = false
    @State private var pathHistory: [String] = []
    
    var body: some View {
        NavigationView {
            List {
                // Breadcrumb
                if !pathHistory.isEmpty {
                    Button(action: goBack) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .foregroundStyle(.violet)
                    }
                }
                
                // Current path display
                Text(currentPath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                
                // File list
                ForEach(files) { file in
                    FileRow(file: file)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleTap(file)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteFile(file)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { createNewFile() }) {
                            Label("New File", systemImage: "doc.badge.plus")
                        }
                        Button(action: { createNewFolder() }) {
                            Label("New Folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                await loadFiles()
            }
            .task {
                await loadFiles()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            
            // Detail or placeholder
            if let file = selectedFile, !file.isDirectory {
                FileEditorView(file: file)
            } else {
                NoFileSelectedView()
            }
        }
        .navigationViewStyle(.columns)
    }
    
    private func handleTap(_ file: FileNode) {
        if file.isDirectory {
            pathHistory.append(currentPath)
            currentPath = file.path
            Task {
                await loadFiles()
            }
        } else {
            withAnimation {
                selectedFile = file
            }
        }
    }
    
    private func goBack() {
        guard let previous = pathHistory.popLast() else { return }
        currentPath = previous
        Task {
            await loadFiles()
        }
    }
    
    private func loadFiles() async {
        isLoading = true
        // API call to load files
        // Mock data for now
        files = [
            FileNode(name: "src", path: "./src", isDirectory: true, size: nil, modifiedDate: Date(), children: nil),
            FileNode(name: "README.md", path: "./README.md", isDirectory: false, size: 1024, modifiedDate: Date(), children: nil),
            FileNode(name: "package.json", path: "./package.json", isDirectory: false, size: 512, modifiedDate: Date(), children: nil),
        ]
        isLoading = false
    }
    
    private func deleteFile(_ file: FileNode) {
        // Delete logic
    }
    
    private func createNewFile() {
        // Create file logic
    }
    
    private func createNewFolder() {
        // Create folder logic
    }
}

struct FileRow: View {
    let file: FileNode
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: file.icon)
                .font(.title3)
                .foregroundStyle(file.isDirectory ? .violet : .secondary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.subheadline.weight(.medium))
                
                HStack(spacing: 8) {
                    if !file.isDirectory {
                        Text(file.formattedSize)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(formattedDate(file.modifiedDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if file.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct FileEditorView: View {
    let file: FileNode
    @State private var content: String = ""
    @State private var isEditing = false
    @State private var hasChanges = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor
            TextEditor(text: $content)
                .font(.system(.body, design: isCodeFile ? .monospaced : .default))
                .padding()
                .background(.ultraThinMaterial)
            
            // Status bar
            HStack {
                Text("\(content.count) characters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if hasChanges {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                }
                
                Text(hasChanges ? "Modified" : "Saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .glassBackground(.thick, in: Rectangle())
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if hasChanges {
                    Button("Save") {
                        saveFile()
                    }
                    .foregroundStyle(.violet)
                }
            }
        }
        .task {
            await loadContent()
        }
    }
    
    private var isCodeFile: Bool {
        let codeExtensions = ["swift", "js", "ts", "json", "py", "rb", "go", "rs", "cpp", "c", "h"]
        return codeExtensions.contains(file.name.fileExtension.lowercased())
    }
    
    private func loadContent() async {
        // Load from API
        content = "// Sample content for \(file.name)\n\nimport SwiftUI\n\nstruct Example: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n    }\n}"
    }
    
    private func saveFile() {
        // Save to API
        hasChanges = false
    }
}

struct NoFileSelectedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Select a File")
                .font(.title3.weight(.semibold))
            
            Text("Choose a file from the browser to view or edit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
