# Othello iOS

A modern, accessible implementation of the classic Othello (Reversi) board game for iOS 18, built with SwiftUI and Swift Testing.

## Features

- **Human vs Human**: Local multiplayer with clear turn indicators
- **AI Opponents**: Three difficulty levels (Easy, Medium, Hard)
- **Accessibility First**: Full VoiceOver support, Dynamic Type, high contrast
- **Modern iOS**: Built for iOS 18 with SwiftUI and Swift Testing
- **Future Ready**: Prepared for Game Center and multiplayer sharing

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Getting Started

1. Clone the repository
2. Open `OthelloApp.xcodeproj` in Xcode
3. Build and run on simulator or device

## Game Rules

Othello is played on an 8x8 board with black and white discs. Players take turns placing discs to capture opponent pieces by flanking them. The player with the most discs when no more moves are possible wins.

## Architecture

This app follows MVVM + Clean Architecture principles:

- **Models**: Game state, board representation, player management
- **ViewModels**: Business logic and state management  
- **Views**: SwiftUI components with built-in accessibility
- **Services**: AI engine, game rules, persistence

See [ARCHITECTURE.md](Documentation/ARCHITECTURE.md) for detailed technical information.

## Testing

Run tests with `⌘+U` in Xcode or:

```bash
xcodebuild test -scheme OthelloApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Accessibility

This app is designed to be fully accessible:

- VoiceOver announcements for all game actions
- Dynamic Type support for all text
- High contrast mode compatibility
- Reduced motion respect

See [ACCESSIBILITY.md](Documentation/ACCESSIBILITY.md) for implementation details.

## Project Documentation

### Development Guidelines
- **[AGENTS.md](AGENTS.md)** - AI agent development guidelines and coding standards
- **[ARCHITECTURE.md](Documentation/ARCHITECTURE.md)** - Technical architecture and design decisions
- **[TESTING.md](Documentation/TESTING.md)** - Testing strategies and conventions
- **[ACCESSIBILITY.md](Documentation/ACCESSIBILITY.md)** - Accessibility implementation guide

### Quality and Excellence
- **[QUALITY-EXCELLENCE.md](QUALITY-EXCELLENCE.md)** - Quality framework and standards
- **[SECURITY.md](SECURITY.md)** - Security implementation and best practices
- **[OBSERVABILITY.md](OBSERVABILITY.md)** - Logging, monitoring, and performance tracking

### Platform and Localization
- **[PLATFORM-STRATEGY.md](PLATFORM-STRATEGY.md)** - Multi-platform expansion strategy
- **[LOCALIZATION.md](LOCALIZATION.md)** - Internationalization and localization guide

### Project Management
- **[TODO.md](TODO.md)** - Current development roadmap and task tracking
- **[SERVER-TODO.md](SERVER-TODO.md)** - Server-side features and multiplayer roadmap

## Contributing

Please read the development guidelines in [AGENTS.md](AGENTS.md) and ensure all quality gates in [QUALITY-EXCELLENCE.md](QUALITY-EXCELLENCE.md) are met.

## License

MIT License - see LICENSE file for details.