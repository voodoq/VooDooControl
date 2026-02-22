# VooDoo Mission Control

A Liquid Glass iOS app for managing OpenClaw — built with SwiftUI for iOS 26.

![Liquid Glass](https://img.shields.io/badge/iOS-26+-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Liquid%20Glass-green)

## 🚀 Quick Start (For Windows Users)

Since you're on Windows and can't build iOS apps directly, you have **three options**:

### Option 1: GitHub Actions (FREE - Recommended)
Automatic builds on Apple's servers. No Mac needed.

1. Push this repo to GitHub
2. Builds automatically on every push
3. Download the `.ipa` file

**See:** [CI_CD_SETUP.md](CI_CD_SETUP.md)

### Option 2: Cloud Mac (Full Control)
Rent a Mac in the cloud, control it remotely from Windows.

1. Rent Mac from MacStadium/AWS (~$1/hour)
2. Run setup script once
3. Build remotely via SSH

**See:** [CI_CD_SETUP.md](CI_CD_SETUP.md#option-2-cloud-mac-more-control)

### Option 3: Get a Mac
Buy/borrow any Mac (even old Mac Mini works).

---

## Project Structure

```
VooDooControl/
├── App/
│   ├── VooDooControlApp.swift      # App entry + global state
│   ├── ContentView.swift           # Tab container + Dashboard
│   └── generate_xcode_project.sh   # Project generator
├── DesignSystem/
│   ├── Glass.swift                 # Liquid Glass materials
│   └── Animations.swift            # Spring transitions
├── Features/
│   ├── Sessions/
│   │   └── SessionsView.swift      # Session list + chat
│   ├── Files/
│   │   └── FilesView.swift         # File browser + editor
│   ├── Terminal/
│   │   ├── TerminalView.swift      # Command execution
│   │   └── CommandActivity.swift   # Live Activity
│   ├── Status/
│   │   └── StatusView.swift        # Health monitoring
│   ├── Tools/
│   │   └── ToolsView.swift         # Quick actions
│   └── Settings/
│       └── SettingsView.swift      # App configuration
├── Services/
│   ├── OpenClawAPI.swift           # REST client
│   ├── WebSocketManager.swift      # Real-time WebSocket
│   └── WidgetDataManager.swift     # App Groups sharing
├── Models/
│   └── Models.swift                # SwiftData models
├── Widgets/
│   └── VooDooWidgets.swift         # Home/Lock Screen widgets
├── scripts/                        # Build automation
│   ├── setup_cloud_mac.sh
│   ├── build.sh
│   └── remote_build.sh
├── .github/workflows/              # GitHub Actions
│   ├── build.yml
│   └── deploy.yml
├── fastlane/                       # App Store deployment
│   ├── Fastfile
│   ├── Appfile
│   └── Matchfile
├── Info.plist
├── VooDooControl.entitlements
├── README.md
└── CI_CD_SETUP.md                  # ⭐️ Build setup guide
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
- Quick command shortcuts
- Copy output to clipboard

### Tools
- Web search integration
- URL content fetching
- Git operations (status, pull, commit, push)
- Gateway management (clear memory, restart)

### Status
- Gateway health monitoring with Swift Charts
- 24-hour memory usage
- Channel toggles (Telegram, Discord, WhatsApp)
- Cron job management
- Live system logs

### Settings
- Gateway connection configuration
- Theme selection (Auto/Light/Dark)
- Haptic intensity (Light/Medium/Heavy)
- Notification preferences
- Test connection button

## Design System

### Liquid Glass Materials
```swift
.glassBackground(.thick)      // Main containers
.glassBackground(.thin)       // Cards and lists
.glassBackground(.ultraThin)  // Subtle backgrounds
.glassCard()                   // Pre-styled glass cards
.glassCapsule()                // Buttons and toggles
```

### Animations
```swift
.glassSpring    // UI interactions
.glassQuick     // Micro-interactions
.pulse()        // Status indicators
.shimmer()      // Loading states
.shake()        // Error feedback
```

### Colors
- Primary: Violet `#7B61FF`
- Success: Green `#30D158`
- Warning: Yellow `#FFD60A`
- Error: Red `#FF453A`

## Building

### From macOS (Local)

```bash
# Open in Xcode and build
cd VooDooControl
open VooDooControl.xcodeproj

# Or command line
./scripts/build.sh debug
```

### From Windows (Remote)

```bash
# Configure remote_build.sh with your cloud Mac IP
./scripts/remote_build.sh build
./scripts/remote_build.sh download
```

### GitHub Actions (Automatic)

```bash
# Just push to GitHub
git push origin main
# Build starts automatically
```

## Architecture

```
UI (SwiftUI) 
    ↕
AppState (@MainActor) 
    ↕
Services (API + WebSocket)
    ↕
OpenClaw Gateway
```

## Widgets

- **Home Screen**: Small status, Medium with charts
- **Lock Screen**: Circular/rectangular widgets
- **Live Activity**: Command progress in Dynamic Island

## Requirements

- iOS 26+
- Xcode 16+ (on build machine)
- Swift 6
- OpenClaw Gateway

## Stats

- **Total Code:** ~4,500 lines
- **SwiftUI Views:** 14
- **Services:** 3
- **Models:** 3 SwiftData entities
- **Widgets:** 2
- **Live Activities:** 1

## License

MIT License — built with 💜 by VooDoo

---

**Windows users:** See [CI_CD_SETUP.md](CI_CD_SETUP.md) for detailed build instructions!
