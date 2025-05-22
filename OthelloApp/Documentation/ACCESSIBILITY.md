# Accessibility Implementation Guide

## Overview

This app is designed with accessibility as a core requirement, not an afterthought. All features must be fully usable with VoiceOver, Dynamic Type, and other accessibility technologies.

## VoiceOver Support

### Board Navigation
- Each cell announces its position (e.g., "Row 3, Column 5")
- Cell state is clearly communicated ("Empty", "Black piece", "White piece")
- Available moves are marked as buttons with appropriate hints
- Occupied cells are marked as static text

### Game State Announcements
```swift
// Example accessibility announcements
"Black's turn. 15 black pieces, 12 white pieces."
"Move placed at Row 4, Column 6. 3 pieces captured."
"Game over. Black wins with 35 pieces."
```

### Implementation Pattern
```swift
struct CellView: View {
    let position: BoardPosition
    let state: CellState
    let isValidMove: Bool
    
    var body: some View {
        Circle()
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
            .accessibilityAddTraits(accessibilityTraits)
            .accessibilityAction(.default) {
                if isValidMove {
                    viewModel.makeMove(at: position)
                }
            }
    }
    
    private var accessibilityLabel: String {
        let positionDescription = "Row \(position.row + 1), Column \(position.column + 1)"
        let stateDescription = state.accessibilityDescription
        return "\(positionDescription), \(stateDescription)"
    }
    
    private var accessibilityHint: String {
        if isValidMove {
            return "Double tap to place your piece here"
        } else {
            return ""
        }
    }
    
    private var accessibilityTraits: AccessibilityTraits {
        if isValidMove {
            return .isButton
        } else {
            return .isStaticText
        }
    }
}
```

## Dynamic Type Support

### Text Scaling
- All text elements support Dynamic Type
- UI layouts adapt to larger text sizes
- Minimum touch target sizes maintained (44x44 points)

### Implementation
```swift
struct ScoreDisplayView: View {
    let score: Score
    
    var body: some View {
        HStack {
            Text("Black: \(score.black)")
                .font(.headline)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            Text("White: \(score.white)")
                .font(.headline)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Score: Black \(score.black), White \(score.white)")
    }
}
```

## Color and Contrast

### High Contrast Support
- Respect system high contrast settings
- Provide alternative visual indicators beyond color
- Ensure minimum contrast ratios (4.5:1 for normal text, 3:1 for large text)

### Color Implementation
```swift
extension Color {
    static var pieceBlack: Color {
        Color.primary // Adapts to light/dark mode and high contrast
    }
    
    static var pieceWhite: Color {
        Color.secondary
    }
    
    static var boardBackground: Color {
        Color(.systemBackground)
    }
    
    static var validMoveIndicator: Color {
        Color.accentColor
    }
}
```

### Visual Indicators
- Shape differences in addition to color
- Border styles for piece differentiation
- Animation patterns for state changes

## Reduced Motion

### Motion Sensitivity
- Respect `UIAccessibility.isReduceMotionEnabled`
- Provide instant transitions when motion is reduced
- Maintain essential animations for state understanding

### Implementation
```swift
struct PieceAppearanceModifier: ViewModifier {
    let isAnimated: Bool
    
    func body(content: Content) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            content
                .transition(.opacity)
        } else {
            content
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimated)
        }
    }
}
```

## Keyboard Navigation

### Focus Management
- Logical tab order through game elements
- Custom focus handling for board navigation
- Escape key to return to main menu

### Implementation
```swift
struct GameView: View {
    @FocusState private var focusedCell: BoardPosition?
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(board.allPositions, id: \.self) { position in
                CellView(position: position, state: board[position])
                    .focused($focusedCell, equals: position)
            }
        }
        .onKeyPress(.return) {
            if let focused = focusedCell {
                viewModel.makeMove(at: focused)
                return .handled
            }
            return .ignored
        }
    }
}
```

## Audio Feedback

### Sound Effects
- Piece placement sounds
- Capture confirmation sounds
- Game completion audio cues
- Respect silent mode settings

### Haptic Feedback
```swift
func provideMoveConfirmation() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.impactOccurred()
}

func provideErrorFeedback() {
    let notificationFeedback = UINotificationFeedbackGenerator()
    notificationFeedback.notificationOccurred(.error)
}
```

## Screen Reader Announcements

### Custom Announcements
```swift
func announceGameStateChange() {
    let announcement = """
    \(gameState.currentPlayer.name)'s turn. 
    \(gameState.score.black) black pieces, 
    \(gameState.score.white) white pieces. 
    \(gameState.availableMoves.count) moves available.
    """
    
    UIAccessibility.post(notification: .announcement, argument: announcement)
}

func announceMoveResult(capturedCount: Int) {
    let announcement = capturedCount > 0 
        ? "Move placed. \(capturedCount) pieces captured."
        : "Move placed."
    
    UIAccessibility.post(notification: .announcement, argument: announcement)
}
```

## Testing Accessibility

### Manual Testing Checklist
- [ ] Navigate entire app using only VoiceOver
- [ ] Test with largest Dynamic Type size
- [ ] Verify high contrast mode compatibility
- [ ] Test with reduced motion enabled
- [ ] Confirm keyboard navigation works
- [ ] Validate haptic feedback appropriateness

### Automated Testing
```swift
@Test("Board cells have proper accessibility labels")
func testBoardAccessibility() {
    let board = Board.initial
    let position = BoardPosition(row: 3, col: 4)
    
    let cellView = CellView(
        position: position,
        state: .black,
        isValidMove: false
    )
    
    // Test accessibility properties
    #expect(cellView.accessibilityLabel == "Row 4, Column 5, Black piece")
    #expect(cellView.accessibilityTraits.contains(.isStaticText))
}
```

### Accessibility Audit Tools
- Use Xcode's Accessibility Inspector
- Regular testing with actual screen readers
- Automated accessibility tests in CI/CD

## Documentation for Developers

### Accessibility Requirements
1. Every interactive element must have an accessibility label
2. State changes must be announced appropriately
3. Focus management must be logical and predictable
4. Visual information must have non-visual alternatives
5. Touch targets must meet minimum size requirements

### Common Patterns
```swift
// Pattern for interactive game elements
.accessibilityLabel(descriptiveLabel)
.accessibilityHint(actionHint)
.accessibilityAddTraits(.isButton)
.accessibilityAction(.default) { performAction() }

// Pattern for informational elements
.accessibilityElement(children: .combine)
.accessibilityLabel(combinedInformation)
.accessibilityAddTraits(.isStaticText)

// Pattern for complex layouts
.accessibilityElement(children: .ignore)
.accessibilityLabel(summarizedContent)
.accessibilityChildren {
    // Custom accessibility hierarchy
}
```

## Localization Considerations

### RTL Language Support
- Layout adaptation for right-to-left languages
- Proper text alignment and reading order
- Mirror appropriate UI elements

### Cultural Adaptations
- Number formatting based on locale
- Color meanings in different cultures
- Audio cue appropriateness across regions

## Performance and Accessibility

### Efficient Updates
- Minimize unnecessary accessibility notifications
- Batch related announcements
- Respect user's notification preferences

### Battery Conservation
- Optimize haptic feedback usage
- Efficient VoiceOver integration
- Reduce unnecessary screen reader queries