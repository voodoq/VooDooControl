# VooDoo Mission Control

A Liquid Glass iOS app for managing OpenClaw — built with SwiftUI for iOS 26.

![Liquid Glass](https://img.shields.io/badge/iOS-26+-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Liquid%20Glass-green)

## Project Structure

```
VooDooControl/
├── App/
│   ├── VooDooControlApp.swift      # App entry + global state
│   ├── ContentView.swift           # Tab container + Dashboard
│   └── generate_xcode_project.sh   # Project generator
├── DesignSystem/
│   ├── Glass.swift                 # Liquid Glass materials (thick/thin/ultraThin)
│   └── Animations.swift            # Spring transitions, pulse, shimmer, shake
├── Features/
│   ├── Sessions/
│   │   └── SessionsView.swift      # Session list + chat interface
│   ├── Files/
│   │   └── FilesView.swift         # File browser + code editor
│   ├── Terminal/
│   │   ├── TerminalView.swift      # Command execution
│   │   └── CommandActivity.swift   # Live Activity for running commands
│   ├── Status/
│   │   └── StatusView.swift        # Health monitoring + Swift Charts
│   ├── Tools/
│   │   └── ToolsView.swift         # Quick actions + web search
│   └── Settings/
│       └── SettingsView.swift      # App configuration
├── Services/
│   ├── OpenClawAPI.swift           # REST client for Gateway
│   ├── WebSocketManager.swift      # Real-time WebSocket connection
│   └── WidgetDataManager.swift     # App Groups data sharing
├── Models/
│   └── Models.swift                # SwiftData models
├── Widgets/
│   └── VooDooWidgets.swift         # Home Screen + Lock Screen widgets
├── Info.plist                      # App configuration
├── VooDooControl.entitlements      # App Groups for widgets
├── README.md
└── .gitignore
```

## Features

### Dashboard
- Real-time gateway connection status with pulse animation
- Memory usage with mini progress bar
- Recent sessions preview with unread badges
- Quick action shortcuts

### Sessions
- Browse active sessions with swipe actions (pin/kill)
- Real-time messaging with glass chat bubbles
- Sub-agent spawning
- Message history with search

### Files
- Navigate workspace directory
- Syntax-highlighted code editor (Swift, JS, JSON, MD)
- File creation and deletion
- Git integration ready

### Terminal
- Command execution with history
- Live Activity showing progress on Lock Screen/Dynamic Island
- Quick command shortcuts (openclaw status, git status, etc.)
- Copy output to clipboard
- Favorite commands

### Tools
- Web search integration
- URL content fetching
- Git operations (status, pull, commit, push)
- Gateway management (clear memory, restart)
- Recent actions history

### Status
- Gateway health monitoring with charts
- 24-hour memory usage (Swift Charts)
- Channel toggles (Telegram, Discord, WhatsApp)
- Cron job management with scheduling
- Live system logs

### Settings
- Gateway connection configuration
- Theme selection (Auto/Light/Dark)
- Haptic intensity (Light/Medium/Heavy)
- Notification preferences per event type
- Test connection button

## Design System

### Liquid Glass Materials
```swift
.glassBackground(.thick)      // Main containers
.glassBackground(.thin)       // Cards and lists
.glassBackground(.ultraThin)  // Subtle backgrounds
.glassCard()                   // Pre-styled glass cards
.glassCapsule()                // Button and toggle backgrounds
```

### Animations
```swift
.glassSpring    // UI interactions (0.4s, damping: 0.8)
.glassQuick     // Micro-interactions (0.2s)
.glassBounce    // Playful elements (0.5s, damping: 0.6)
.glassSmooth    // Transitions (0.3s ease)
.pulse()        // Status indicators
.shimmer()      // Loading states
.shake()        // Error feedback
```

### Colors
- Primary: Violet `#7B61FF`
- Success: Green `#30D158`
- Warning: Yellow `#FFD60A`
- Error: Red `#FF453A`
- Text uses `.primary`/`.secondary` for vibrancy

## Requirements

- iOS 26+
- Xcode 16+
- Swift 6
- OpenClaw Gateway running locally or remotely

## Setup

### 1. Create Xcode Project

```bash
cd VooDooControl
bash App/generate_xcode_project.sh
```

Or manually:
1. Open Xcode 16
2. File → New → Project
3. Select iOS App template
4. Name: "VooDooControl"
5. Interface: SwiftUI
6. Language: Swift
7. Enable SwiftData

### 2. Configure App Groups (Required for Widgets)

1. Select project → VooDooControl target
2. Signing & Capabilities → + Capability
3. Add "App Groups"
4. Create group: `group.com.voodoo.control`
5. Repeat for widget extension target

### 3. Add Files to Project

Drag all files from the `VooDooControl` folder into your Xcode project:
- Preserve folder structure
- Check "Create groups"
- Add to target: VooDooControl

### 4. Build and Run

1. Select iPhone 16 Pro simulator or your device
2. Press ⌘+R to build and run

## Configuration

On first launch, go to **Settings** tab and configure:

| Setting | Default | Description |
|---------|---------|-------------|
| Server URL | `ws://127.0.0.1:18789` | OpenClaw Gateway URL |
| Auth Token | (empty) | Your gateway auth token |
| Theme | Auto | Follows system or manual override |
| Haptics | Medium | Feedback intensity |

## Architecture

### Data Flow
```
UI (SwiftUI) 
    ↕
AppState (@MainActor) 
    ↕
Services (API + WebSocket)
    ↕
OpenClaw Gateway
```

### Real-time Updates
- WebSocket connection for live data
- Combine publishers for reactive UI
- SwiftData for persistence
- App Groups for widget data sharing

### Key Components

**AppState** — Central state management
- Connection status
- Memory/session counts
- Error handling

**OpenClawAPI** — REST client
- Status, sessions, files, commands
- Async/await pattern

**WebSocketManager** — Real-time connection
- Automatic reconnection with backoff
- Push notification handling

## Widgets

### Home Screen
- **Small**: Connection status + session count
- **Medium**: Full status + memory chart + quick actions

### Lock Screen
- **Circular**: Connection dot + session count
- **Rectangular**: Status + last sync time
- **Inline**: Compact session count

### Live Activity
- Shows when commands are running
- Appears on Lock Screen and Dynamic Island
- Progress bar + elapsed time + output preview

## Shortcuts & Siri

Siri phrases supported:
- "Check my OpenClaw status"
- "Send message to my main session"
- "Run git status in VooDoo"
- "What's my session count?"

## Security

- Auth token stored in Keychain
- App Groups for secure data sharing
- Local network access for gateway connection
- HTTPS support for remote gateways

## Troubleshooting

### Can't connect to gateway
1. Verify gateway is running: `openclaw status`
2. Check URL in Settings (default: `ws://127.0.0.1:18789`)
3. Test connection button in Settings
4. Check firewall settings for port 18789

### Widgets not updating
1. Verify App Groups capability is enabled
2. Check group ID matches: `group.com.voodoo.control`
3. Background refresh must be enabled

### Live Activity not showing
1. Requires iOS 16.1+
2. Enable in Settings → Notifications → VooDoo Control
3. Check "Live Activities" toggle

## License

MIT License — built with 💜 by VooDoo

## Contributing

This is a personal project, but feel free to fork and customize for your own OpenClaw setup.

---

**Total Code:** ~3,500 lines of Swift
**SwiftUI Views:** 14
**Services:** 3
**Models:** 3 SwiftData entities
**Widgets:** 2 (Home + Lock Screen)
**Live Activities:** 1 (Command progress)
