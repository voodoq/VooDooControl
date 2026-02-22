# VooDoo Mission Control

**Liquid Glass iOS App for OpenClaw Management**

A premium iOS application built with SwiftUI and Apple's new Liquid Glass design language. VooDoo Mission Control gives you full management capabilities over your OpenClaw gateway from anywhere.

![VooDoo Control](preview.png)

## Features

### 🎨 Liquid Glass Design
- Translucent UI with adaptive materials
- Glass cards with depth and shadow
- Fluid animations and micro-interactions
- Haptic feedback throughout

### 💬 Session Management
- Real-time session list with live status
- Direct messaging interface
- Sub-agent spawning
- Session kill/suspend controls

### 📁 File Browser
- Navigate workspace files
- Syntax-highlighted editor
- Real-time file operations
- Path history navigation

### 💻 Terminal
- Command execution with live output
- Command history with favorites
- Quick action toolbar
- Copy/share output

### 📊 Status Dashboard
- Gateway health monitoring
- Memory usage tracking
- Channel configuration
- Cron job management

## Tech Stack

- **SwiftUI** — Modern declarative UI
- **Swift 6** — Latest concurrency features
- **SwiftData** — Local persistence
- **Combine** — Reactive state management
- **WebSocket** — Real-time updates

## Requirements

- iOS 26+
- Xcode 16+
- OpenClaw Gateway running locally or remotely

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/voodoocontrol.git
cd voodoocontrol
```

2. Open in Xcode
```bash
open VooDooControl.xcodeproj
```

3. Build and run on your device or simulator

## Configuration

On first launch, configure your OpenClaw gateway:

1. Go to **Status** → **Settings**
2. Enter your gateway URL (e.g., `ws://127.0.0.1:18789`)
3. Add your auth token
4. Test the connection

## Architecture

```
VooDooControl/
├── App/
│   ├── VooDooControlApp.swift    # App entry point
│   └── ContentView.swift          # Main container
├── DesignSystem/
│   ├── Glass.swift                # Glass materials & modifiers
│   └── Animations.swift           # Animation presets
├── Features/
│   ├── Sessions/                  # Session management
│   ├── Files/                     # File browser
│   ├── Terminal/                  # Command execution
│   └── Status/                    # Gateway status
├── Services/
│   ├── OpenClawAPI.swift          # REST API client
│   └── WebSocketManager.swift     # Real-time connection
└── Models/
    └── Models.swift               # SwiftData models
```

## Design System

### Glass Materials

```swift
.glassBackground(.thick, in: RoundedRectangle(cornerRadius: 24))
.glassCard(thickness: .regular)
.glassCapsule(thickness: .thin)
```

### Colors

- **Primary**: Violet `#7B61FF`
- **Success**: Green `#30D158`
- **Warning**: Yellow `#FFD60A`
- **Error**: Red `#FF453A`

### Animations

```swift
.animation(.glassSpring, value: state)
.transition(.glassMove(edge: .trailing))
.glassScale()
```

## API Integration

The app connects to OpenClaw Gateway via:

- **REST API** for state operations
- **WebSocket** for real-time updates

Endpoints:
- `GET /status` — Gateway health
- `GET /sessions` — List sessions
- `POST /sessions/{id}/send` — Send message
- `POST /exec` — Execute command
- `GET /files` — List files
- `WS /ws` — Real-time events

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License — See LICENSE file for details

## Credits

Built with ❤️ by VooDoo for qatana

---

*Part of the Cryptc project ecosystem*
