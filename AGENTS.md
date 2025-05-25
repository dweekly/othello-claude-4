# AI Agent Development Guidelines

This document provides guidelines for AI agents working on the Othello iOS project to ensure consistent, high-quality code.

## Session Initialization Checklist

### Environment Verification
At the start of each new development session, AI agents should verify the development environment by running this command:

```bash
echo "=== Development Environment Check ===" && \
for tool in rg fd bat eza jq yq tree watch delta gh htop hyperfine git swiftlint xcodebuild swift; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✅ $tool: $(command -v $tool)"
    else
        echo "❌ $tool: not found - run: brew install $tool"
    fi
done && \
echo "=== Project Status ===" && \
echo "Working directory: $(pwd)" && \
echo "Git status: $(git status --porcelain | wc -l) changes" && \
echo "Swift files: $(fd -e swift | wc -l) files" && \
echo "Test files: $(fd -e swift | rg -i test | wc -l) test files"
```

### Expected Environment State
All tools should show ✅ status:
- **Core search tools**: rg, fd, bat, eza  
- **Development utilities**: jq, yq, tree, watch, delta, gh, htop, hyperfine
- **Swift/iOS tools**: git, swiftlint, xcodebuild, swift
- **Project management**: xcodegen

If any tools are missing, install them immediately:
```bash
brew install [missing-tool-name]
```

### Project Management Workflow
This project uses **XcodeGen** for project file management:

1. **Never edit .xcodeproj files directly** - they are generated and gitignored
2. **Edit project.yml** to modify targets, schemes, settings, or dependencies  
3. **Regenerate project** with `./scripts/generate-project.sh` or `xcodegen generate`
4. **Pre-commit hook** automatically regenerates project if project.yml is newer

### Project Context Verification
Before starting work, agents should also verify:
1. **Current directory**: Confirm working in the correct project root
2. **Git status**: Check for uncommitted changes
3. **Build status**: Verify project compiles successfully
4. **TODO.md status**: Review current phase and priorities

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

### TODO and Workaround Management
When implementing temporary fixes or workarounds:

1. **Never rely on inline comments alone** - Always add items to TODO.md
2. **Document temporary workarounds** with:
   - Clear description of what was temporarily disabled/changed
   - Reason for the workaround
   - Steps needed to properly fix it
   - Priority level for the permanent fix

3. **Add to TODO.md structure**:
   ```markdown
   ## Technical Debt & Workarounds
   
   ### [Priority Level] - [Brief Description]
   - **Status**: [Active Workaround/Needs Fix]
   - **Temporary Fix**: [What was done as workaround]
   - **Proper Solution**: [What needs to be implemented]
   - **Impact**: [What functionality is affected]
   - **Files**: [List of affected files]
   ```

4. **Examples of items requiring TODO.md entries**:
   - Commented out code that should be re-enabled
   - Simplified implementations pending full features
   - Configuration workarounds
   - Disabled tests or checks
   - Manual processes that should be automated

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

### Efficient Development Workflow
**Use modern tools for faster development:**
- **Search code**: Use `rg` instead of `grep` for all text searches
- **Find files**: Use `fd` instead of `find` for file discovery
- **View code**: Use `bat` instead of `cat` for syntax-highlighted file reading
- **Navigate**: Use `eza` instead of `ls` for better directory listings
- **Benchmark**: Use `hyperfine` for reliable performance measurements

**Example workflow:**
```bash
# 1. Find files related to AI
fd AI.*swift

# 2. Search for specific patterns
rg "calculateMove" --type swift -A 5

# 3. View file with syntax highlighting
bat Othello/Othello/Services/AIService.swift

# 4. Check project structure
eza --tree --level=2 Othello/
```

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

## Development Tools Requirements

### Required CLI Tools
The following tools should be installed via Homebrew to support efficient development:

```bash
# Core search and file tools
brew install ripgrep          # Fast text search (rg command)
brew install fd               # Fast file finder (fd command)
brew install bat              # Enhanced cat with syntax highlighting
brew install eza              # Modern ls replacement with Git integration

# Development utilities
brew install jq               # JSON processor for API responses
brew install yq               # YAML processor
brew install tree             # Directory tree visualization
brew install watch            # Execute commands periodically

# Git and version control
brew install git-delta        # Better git diffs
brew install gh               # GitHub CLI for PR/issue management

# Performance and monitoring
brew install htop             # Better process viewer
brew install hyperfine        # Command-line benchmarking
```

### Tool Verification
Run this command to check if all required tools are available:
```bash
for tool in rg fd bat eza jq yq tree watch delta gh htop hyperfine; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✅ $tool: $(command -v $tool)"
    else
        echo "❌ $tool: not found"
    fi
done
```

### Tool Usage Guidelines
- **ripgrep (rg)**: Use instead of grep for all text searches
- **fd**: Use instead of find for file searches  
- **bat**: Use instead of cat for file viewing with syntax highlighting
- **eza**: Use instead of ls for directory listings
- **hyperfine**: Use for performance benchmarking of build/test commands

### Current Environment Status
✅ **All tools are installed and verified working:**

**Core search and file tools:**
- ✅ **ripgrep (rg)**: Fast text search
- ✅ **fd**: Fast file finder  
- ✅ **bat**: Enhanced cat with syntax highlighting
- ✅ **eza**: Modern ls replacement

**Development utilities:**
- ✅ **jq**: JSON processor
- ✅ **yq**: YAML processor
- ✅ **tree**: Directory tree visualization
- ✅ **watch**: Command monitoring
- ✅ **git-delta**: Better git diffs
- ✅ **gh**: GitHub CLI
- ✅ **htop**: Process viewer
- ✅ **hyperfine**: Command benchmarking

**Swift/iOS development:**
- ✅ **git**: Version control
- ✅ **swiftlint**: Code linting
- ✅ **xcodebuild**: Xcode build tools
- ✅ **swift**: Swift compiler

The development environment is fully configured and optimized for AI agent productivity.

### AI Agent Benefits
These tools significantly improve AI agent efficiency:
- **rg**: 10-100x faster than grep for code searches
- **fd**: Much faster than find for file discovery
- **bat**: Syntax highlighting helps with code analysis
- **hyperfine**: Reliable performance benchmarking for optimization tasks

### Practical Tool Examples

**Code searches with ripgrep:**
```bash
# Find all async functions
rg "func.*async" --type swift

# Find protocol implementations
rg "final class.*: .*Protocol" --type swift

# Search for error handling patterns
rg "(throw|catch|Result)" --type swift -A 2
```

**File discovery with fd:**
```bash
# Find all Swift test files
fd -e swift | rg -i test

# Find specific file types
fd -e swift -e md

# Find files matching pattern
fd "AI.*\.swift$"
```

**Project structure with eza:**
```bash
# Show project tree with git status
eza --tree --level=3 --git

# List files with metadata
eza -la --git --header
```

**Performance benchmarking:**
```bash
# Benchmark build times
hyperfine "xcodebuild -project Othello/Othello.xcodeproj -scheme Othello build"

# Compare different commands
hyperfine "rg 'pattern'" "grep -r 'pattern'"
```