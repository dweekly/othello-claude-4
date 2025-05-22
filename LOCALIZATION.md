# Internationalization and Localization Strategy

## Overview

Comprehensive strategy for creating a globally accessible Othello app with proper internationalization (i18n) architecture and localization (l10n) implementation.

## Supported Locales (Launch)

### Tier 1 Languages (Launch)
- **English (US)** - Primary development language
- **Spanish (ES/MX)** - Large iOS market
- **French (FR)** - European market
- **German (DE)** - European market
- **Japanese (JP)** - Gaming culture significance
- **Chinese Simplified (CN)** - Market size

### Tier 2 Languages (Phase 2)
- Portuguese (BR), Italian (IT), Dutch (NL)
- Korean (KR), Chinese Traditional (TW)
- Russian (RU), Arabic (AR)

## Architecture for Localization

### String Management
```swift
// Localized string keys with context
enum LocalizedString {
    case gameTitle
    case playerTurn(Player)
    case scoreDisplay(black: Int, white: Int)
    case moveResult(captured: Int)
    case gameOver(winner: Player?)
    case accessibilityMove(row: Int, col: Int, state: CellState)
    
    var key: String {
        switch self {
        case .gameTitle: return "game.title"
        case .playerTurn: return "game.player_turn"
        case .scoreDisplay: return "game.score_display"
        case .moveResult: return "game.move_result"
        case .gameOver: return "game.over"
        case .accessibilityMove: return "accessibility.move"
        }
    }
    
    var localizedString: String {
        switch self {
        case .gameTitle:
            return NSLocalizedString(key, comment: "Main game title")
        case .playerTurn(let player):
            return String(format: NSLocalizedString(key, comment: "Whose turn it is"), 
                         player.localizedName)
        case .scoreDisplay(let black, let white):
            return String(format: NSLocalizedString(key, comment: "Current game score"), 
                         black, white)
        case .moveResult(let captured):
            return String(format: NSLocalizedString(key, comment: "Pieces captured in move"), 
                         captured)
        case .gameOver(let winner):
            if let winner = winner {
                return String(format: NSLocalizedString("game.winner", comment: "Game winner"), 
                             winner.localizedName)
            } else {
                return NSLocalizedString("game.tie", comment: "Game ended in tie")
            }
        case .accessibilityMove(let row, let col, let state):
            return String(format: NSLocalizedString(key, comment: "Cell accessibility description"), 
                         row + 1, col + 1, state.localizedDescription)
        }
    }
}
```

### Localization Files Structure
```
Localizations/
├── en.lproj/
│   ├── Localizable.strings
│   ├── InfoPlist.strings
│   └── Accessibility.strings
├── es.lproj/
│   ├── Localizable.strings
│   ├── InfoPlist.strings
│   └── Accessibility.strings
├── fr.lproj/
├── de.lproj/
├── ja.lproj/
└── zh-Hans.lproj/
```

### Strings File Example
```strings
/* Game UI Strings */
"game.title" = "Othello";
"game.new_game" = "New Game";
"game.player_turn" = "%@'s Turn";
"game.score_display" = "Black: %d, White: %d";
"game.move_result" = "%d pieces captured";
"game.winner" = "%@ Wins!";
"game.tie" = "It's a Tie!";

/* Player Names */
"player.black" = "Black";
"player.white" = "White";
"player.human" = "Human";
"player.ai" = "AI";

/* AI Difficulty */
"ai.difficulty.easy" = "Easy";
"ai.difficulty.medium" = "Medium";
"ai.difficulty.hard" = "Hard";

/* Accessibility */
"accessibility.move" = "Row %d, Column %d, %@";
"accessibility.empty_cell" = "Empty";
"accessibility.black_piece" = "Black piece";
"accessibility.white_piece" = "White piece";
"accessibility.valid_move" = "Double tap to place your piece here";
"accessibility.game_board" = "Othello game board";

/* Game States */
"game.state.playing" = "Game in Progress";
"game.state.paused" = "Game Paused";
"game.state.finished" = "Game Finished";

/* Menu Items */
"menu.settings" = "Settings";
"menu.how_to_play" = "How to Play";
"menu.about" = "About";

/* Settings */
"settings.sound_effects" = "Sound Effects";
"settings.haptic_feedback" = "Haptic Feedback";
"settings.show_valid_moves" = "Show Valid Moves";
"settings.animation_speed" = "Animation Speed";
"settings.language" = "Language";
```

## Right-to-Left (RTL) Language Support

### RTL Layout Adaptation
```swift
struct GameView: View {
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        HStack {
            if layoutDirection == .rightToLeft {
                // RTL layout: scores and controls on left
                Spacer()
                GameControlsView()
                BoardView()
                ScoreDisplayView()
            } else {
                // LTR layout: scores and controls on right
                ScoreDisplayView()
                BoardView()
                GameControlsView()
                Spacer()
            }
        }
    }
}
```

### RTL-Aware Components
```swift
struct PlayerIndicatorView: View {
    let player: Player
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        HStack {
            if layoutDirection == .rightToLeft {
                Text(player.localizedName)
                PlayerIconView(player: player)
            } else {
                PlayerIconView(player: player)
                Text(player.localizedName)
            }
        }
    }
}
```

## Cultural Adaptations

### Color Considerations
```swift
extension Color {
    static var culturallyNeutralPrimary: Color {
        // Avoid colors with specific cultural meanings
        // Red = luck in China, danger in Western cultures
        // Green = nature universally, money in US
        return Color.blue // Generally positive across cultures
    }
    
    static var pieceColors: (black: Color, white: Color) {
        // Some cultures prefer different contrast levels
        let locale = Locale.current
        
        switch locale.languageCode {
        case "ja", "ko", "zh":
            // Higher contrast preferred in East Asian markets
            return (.black, Color(white: 0.95))
        default:
            return (.primary, .secondary)
        }
    }
}
```

### Number and Date Formatting
```swift
final class LocalizedFormatters {
    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    static let duration: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    static func formatScore(_ score: Int) -> String {
        return number.string(from: NSNumber(value: score)) ?? "\(score)"
    }
    
    static func formatGameDuration(_ duration: TimeInterval) -> String {
        return duration.string(from: duration) ?? "0:00"
    }
}
```

## Locale-Specific Features

### Japanese Localization
```swift
// Japanese text often requires vertical layout consideration
extension View {
    @ViewBuilder
    func japaneseLayoutAdaptation() -> some View {
        if Locale.current.languageCode == "ja" {
            self
                .font(.system(size: 16, design: .default))
                .lineLimit(2) // Japanese text may need more vertical space
        } else {
            self
        }
    }
}
```

### Arabic Localization
```swift
// Arabic requires special text handling
extension String {
    var arabicLocalizedString: String {
        if Locale.current.languageCode == "ar" {
            // Handle Arabic text directionality
            return self
                .replacingOccurrences(of: "(", with: ")")
                .replacingOccurrences(of: ")", with: "(")
        }
        return self
    }
}
```

## Testing Localization

### Pseudo-Localization for Testing
```swift
#if DEBUG
extension String {
    var pseudoLocalized: String {
        // Add accents and length to test UI layout
        let accented = self
            .replacingOccurrences(of: "a", with: "ä")
            .replacingOccurrences(of: "e", with: "ë")
            .replacingOccurrences(of: "i", with: "ï")
            .replacingOccurrences(of: "o", with: "ö")
            .replacingOccurrences(of: "u", with: "ü")
        
        // Add 30% length to test layout flexibility
        let padding = String(repeating: "x", count: max(1, self.count / 3))
        return "[\(accented)\(padding)]"
    }
}
#endif
```

### Localization Testing Strategy
```swift
@Suite("Localization Tests")
struct LocalizationTests {
    
    @Test("All localized strings have translations", arguments: ["en", "es", "fr", "de", "ja", "zh-Hans"])
    func testAllStringsLocalized(language: String) throws {
        let bundle = Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!)!
        
        // Test all string keys have non-empty translations
        for key in allStringKeys {
            let localized = NSLocalizedString(key, bundle: bundle, comment: "")
            #expect(localized != key, "Missing translation for key: \(key) in \(language)")
            #expect(!localized.isEmpty, "Empty translation for key: \(key) in \(language)")
        }
    }
    
    @Test("UI layout adapts to different text lengths")
    func testUILayoutFlexibility() {
        // Test with artificially long text
        let longText = String(repeating: "Very Long Text ", count: 10)
        
        // Test UI components handle long text gracefully
        let scoreView = ScoreDisplayView(score: Score(black: 32, white: 32))
        // UI testing to verify no text truncation or layout breaks
    }
}
```

## Accessibility Across Languages

### VoiceOver Localization
```swift
extension CellState {
    var localizedAccessibilityDescription: String {
        switch self {
        case .empty:
            return NSLocalizedString("accessibility.empty_cell", comment: "Empty cell description")
        case .black:
            return NSLocalizedString("accessibility.black_piece", comment: "Black piece description")
        case .white:
            return NSLocalizedString("accessibility.white_piece", comment: "White piece description")
        }
    }
    
    var localizedAccessibilityValue: String? {
        // Provide additional context for screen readers
        switch self {
        case .empty:
            return nil
        case .black, .white:
            return NSLocalizedString("accessibility.piece_placed", comment: "Piece is placed here")
        }
    }
}
```

### Dynamic Type Across Languages
```swift
extension Font {
    static func gameFont(for languageCode: String) -> Font {
        switch languageCode {
        case "ja", "ko", "zh-Hans", "zh-Hant":
            // CJK characters need different font treatment
            return .system(size: 17, weight: .medium, design: .default)
        case "ar", "he":
            // RTL languages may need different spacing
            return .system(size: 16, weight: .regular, design: .default)
        default:
            return .system(size: 16, weight: .regular, design: .rounded)
        }
    }
}
```

## Localization Workflow

### Development Process
1. **Development**: Use `NSLocalizedString` with descriptive comments
2. **String Extraction**: Automated extraction of localizable strings
3. **Translation**: Professional translation services
4. **Review**: Native speaker review and cultural adaptation
5. **Testing**: Comprehensive localization testing
6. **Updates**: Continuous localization for new features

### Tools and Integration
```swift
// Swiftgen for type-safe localization
enum L10n {
    enum Game {
        static let title = L10n.tr("Localizable", "game.title")
        static func playerTurn(_ p1: String) -> String {
            return L10n.tr("Localizable", "game.player_turn", p1)
        }
    }
}
```

### Translation Memory
- Maintain translation consistency across updates
- Reuse translations for common gaming terms
- Build glossary of game-specific terminology
- Context screenshots for translators

## Localization Quality Assurance

### Linguistic Testing
- Native speaker verification
- Cultural appropriateness review
- Gaming terminology accuracy
- Consistency across platforms

### Technical Testing
- Character encoding verification
- Text rendering in all supported fonts
- UI layout with longest translations
- Placeholder and formatting validation

### Automated Checks
```swift
// Automated localization validation
func validateLocalization() {
    let supportedLanguages = ["en", "es", "fr", "de", "ja", "zh-Hans"]
    
    for language in supportedLanguages {
        // Check for missing translations
        // Validate string format consistency
        // Verify special character handling
        // Test right-to-left layout if applicable
    }
}
```

## Future Localization Considerations

### Machine Translation Integration
- AI-assisted translation for rapid updates
- Human review for critical user-facing text
- A/B testing of translation variations

### Regional Variations
- Spanish (Spain) vs Spanish (Mexico)
- English (UK) vs English (US)
- Portuguese (Brazil) vs Portuguese (Portugal)
- French (France) vs French (Canada)

### Voice Localization
- Text-to-speech in multiple languages
- Voice command recognition
- Accessibility audio cues culturally appropriate