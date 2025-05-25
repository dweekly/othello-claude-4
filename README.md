# Othello

A modern, accessible implementation of the classic Othello (Reversi) board game built with SwiftUI and Swift Testing. Currently available for macOS with iOS adaptation ready.

## Features

- **Human vs Human**: Local multiplayer with clear turn indicators
- **AI Opponents**: Three difficulty levels (Easy, Medium, Hard)
- **Accessibility First**: Full VoiceOver support, Dynamic Type, high contrast
- **Modern iOS**: Built for iOS 18 with SwiftUI and Swift Testing
- **Future Ready**: Prepared for Game Center and multiplayer sharing

## Requirements

- macOS 14.0+ (current implementation)
- iOS 18.0+ (planned)
- Xcode 16.0+
- Swift 6.0+

## Getting Started

1. Clone the repository
2. Open `Othello/Othello.xcodeproj` in Xcode
3. Build and run on macOS

## Game Rules

Othello is played on an 8x8 board with black and white discs. Players take turns placing discs to capture opponent pieces by flanking them. The player with the most discs when no more moves are possible wins.

## Architecture

This app follows MVVM + Clean Architecture principles:

- **Models**: Game state, board representation, player management
- **ViewModels**: Business logic and state management  
- **Views**: SwiftUI components with built-in accessibility
- **Services**: AI engine, game rules, persistence

## Testing

Run tests with `⌘+U` in Xcode or:

```bash
xcodebuild test -project Othello/Othello.xcodeproj -scheme Othello -destination 'platform=macOS'
```

## Current Status

✅ **Phase 5 Complete**: Advanced AI implementation with 3-tier difficulty system  
🎯 **Next**: iOS adaptation and App Store deployment  
📋 **Future**: Full Apple ecosystem expansion (iPadOS, tvOS, watchOS)

## Project Documentation

### Core Documentation (Root)
- **[AGENTS.md](AGENTS.md)** - AI agent development guidelines and coding standards
- **[TODO.md](TODO.md)** - Current development roadmap and task tracking  
- **[PLATFORM-STRATEGY.md](PLATFORM-STRATEGY.md)** - Multi-platform expansion strategy

### Extended Documentation (docs/)
- **[QUALITY-EXCELLENCE.md](docs/QUALITY-EXCELLENCE.md)** - Quality framework and standards
- **[SECURITY.md](docs/SECURITY.md)** - Security implementation and best practices
- **[OBSERVABILITY.md](docs/OBSERVABILITY.md)** - Logging, monitoring, and performance tracking
- **[LOCALIZATION.md](docs/LOCALIZATION.md)** - Internationalization and localization guide
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** - Contribution guidelines and setup
- **[GITHUB-SETUP.md](docs/GITHUB-SETUP.md)** - GitHub configuration and CI/CD
- **[SERVER-TODO.md](docs/SERVER-TODO.md)** - Server-side features and multiplayer roadmap

## Contributing

Please read the development guidelines in [AGENTS.md](AGENTS.md) and ensure all quality gates are met.

## License

MIT License - see LICENSE file for details.