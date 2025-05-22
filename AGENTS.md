# AI Agent Development Guidelines

This document provides guidelines for AI agents working on the Othello iOS project to ensure consistent, high-quality code.

## Code Style and Standards

### Swift Style Guide
- Follow Apple's Swift API Design Guidelines
- Use SwiftLint with strict settings (see `.swiftlint.yml`)
- Prefer explicit types over inference in public APIs
- Use meaningful variable and function names
- Maximum line length: 120 characters

### SwiftUI Best Practices
- Use iOS 18+ native features (no backwards compatibility required)
- Prefer `@State` and `@StateObject` over `@ObservedObject` when appropriate
- Use `@Environment` for dependency injection
- Implement proper accessibility modifiers on all interactive elements
- Use `Preview` macros for all views

### Architecture Enforcement
- Strict MVVM separation: Views should not contain business logic
- Models should be immutable value types where possible
- ViewModels should be `@MainActor` classes conforming to `ObservableObject`
- Services should be protocol-based for testability

## Testing Requirements

### Mandatory Coverage
- **Minimum 90% code coverage** for all new code
- All public functions must have corresponding tests
- All ViewModels must have comprehensive test suites
- Critical game logic (move validation, AI decisions) requires 100% coverage

### Testing Patterns
- Use Swift Testing framework (not XCTest)
- Test file naming: `[SourceFile]Tests.swift`
- Use `@Test` macro for all test functions
- Prefer parameterized tests with `@Test(arguments:)` when testing multiple scenarios
- Mock external dependencies using protocols

### Test Organization
```swift
// Example test structure
@Suite("GameEngine Tests")
struct GameEngineTests {
    @Test("Valid moves are calculated correctly")
    func testValidMoveCalculation() { /* ... */ }
    
    @Test("Move validation", arguments: [
        (BoardPosition(row: 0, col: 0), true),
        (BoardPosition(row: 4, col: 4), false)
    ])
    func testMoveValidation(position: BoardPosition, expected: Bool) { /* ... */ }
}
```

## Pre-Commit Requirements

### Automated Checks
All commits must pass:
1. **SwiftLint**: No warnings or errors
2. **Swift Testing**: All tests must pass
3. **Build**: Project must compile without warnings
4. **Code Coverage**: Must meet minimum thresholds

### Manual Verification
- Accessibility: Test with VoiceOver enabled
- Performance: No dropped frames during animations
- Memory: No retain cycles or memory leaks

## Code Review Checklist

### Functionality
- [ ] Feature works as specified
- [ ] Edge cases are handled
- [ ] Error states are managed gracefully
- [ ] Performance is acceptable

### Code Quality
- [ ] Follows established patterns
- [ ] No code duplication
- [ ] Proper separation of concerns
- [ ] Meaningful naming conventions

### Testing
- [ ] New tests cover all new functionality
- [ ] Tests are readable and maintainable
- [ ] Mock objects are used appropriately
- [ ] Test coverage meets requirements

### Accessibility
- [ ] All interactive elements have accessibility labels
- [ ] VoiceOver navigation is logical
- [ ] Dynamic Type is supported
- [ ] High contrast mode is supported

## AI-Specific Guidelines

### Project Planning and Execution
- **Primary Scratchpad**: Use [TODO.md](TODO.md) as the primary planning document
- **Task Tracking**: Check TODO.md before starting any work to understand current priorities
- **Plan Updates**: Update TODO.md whenever priorities change or new tasks are identified
- **Progress Tracking**: Mark tasks as complete and update phase status regularly
- **Context Awareness**: Always understand where current work fits in the overall project roadmap

### Phase Transition Requirements
Before proposing to move to the next development phase, **ALL** of the following must be verified:

1. **🧹 Clean Repository State**
   ```bash
   git status  # Should show "working tree clean"
   ```
   - No untracked files
   - No uncommitted changes
   - All work properly committed and documented

2. **🎨 Linting Standards**
   ```bash
   swiftlint  # Should show "Done linting! Found 0 violations"
   ```
   - Zero SwiftLint violations
   - Zero SwiftLint warnings
   - All code follows project style guidelines

3. **✅ Test Quality Gate**
   ```bash
   swift test  # All tests must pass
   ```
   - 100% test suite passing
   - No failing tests
   - No flaky or skipped tests
   - Performance tests within acceptable bounds

4. **📋 Phase Completion Verification**
   - All tasks for current phase marked complete in TODO.md
   - Phase objectives fully achieved
   - Documentation updated to reflect current state
   - Any architectural decisions properly documented

**🚫 Phase transitions are BLOCKED until ALL criteria are met.**

This ensures we maintain the highest quality standards and never advance with technical debt or incomplete work.

### When Making Changes
1. **Check TODO.md first**: Understand current phase and priority tasks
2. **Read existing code**: Understand current patterns and conventions
3. **Check dependencies**: Verify required frameworks/packages are already included
4. **Follow existing patterns**: Don't introduce new architectural patterns without discussion
5. **Test thoroughly**: Run full test suite before considering work complete
6. **Update documentation**: Keep TODO.md and other docs current with changes

### File Modifications
- Always read the full file before making changes
- Preserve existing code style and formatting
- Add appropriate documentation comments
- Update related tests when modifying functionality

### Error Handling
- Use proper Swift error handling (`throws`, `Result`, etc.)
- Provide meaningful error messages
- Log errors appropriately for debugging
- Handle all possible failure cases

## Accessibility Requirements

Every new UI component must include:
- `accessibilityLabel` for all interactive elements
- `accessibilityHint` when actions aren't obvious
- `accessibilityValue` for dynamic content (scores, turn indicators)
- `accessibilityActions` for custom gestures
- Support for Dynamic Type sizing
- Proper focus management for VoiceOver

## Common Patterns

### ViewModels
```swift
@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var gameState: GameState
    
    private let gameEngine: GameEngineProtocol
    
    init(gameEngine: GameEngineProtocol = GameEngine()) {
        self.gameEngine = gameEngine
        self.gameState = GameState.initial
    }
}
```

### Service Injection
```swift
struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    
    init(gameEngine: GameEngineProtocol = GameEngine()) {
        self._viewModel = StateObject(wrappedValue: GameViewModel(gameEngine: gameEngine))
    }
}
```

## Performance Guidelines
- Use `@State` and `@StateObject` judiciously
- Avoid unnecessary view updates with proper state management
- Profile animations for 60fps target
- Use lazy loading for complex calculations
- Implement proper image caching if needed

## Documentation Standards
- All public APIs must have documentation comments
- Use Swift DocC format for documentation
- Include usage examples in documentation
- Update documentation when changing APIs