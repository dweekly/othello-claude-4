# Testing Strategy and Conventions

## Overview

This project uses Swift Testing framework and follows a comprehensive testing strategy to ensure code quality, reliability, and maintainability.

## Testing Philosophy

### Principles
- **Test-Driven Development**: Write tests before implementation when possible
- **90% Coverage Minimum**: All new code must meet coverage requirements
- **Fast Feedback**: Tests should run quickly to enable rapid iteration
- **Reliable**: Tests should be deterministic and not flaky
- **Readable**: Tests serve as documentation of expected behavior

### Testing Pyramid
1. **Unit Tests (70%)**: Fast, isolated tests of individual components
2. **Integration Tests (20%)**: Tests of component interactions
3. **UI Tests (10%)**: End-to-end user flow validation

## Framework Usage

### Swift Testing Syntax
```swift
@Suite("Game Engine Tests")
struct GameEngineTests {
    
    @Test("Calculate valid moves for initial board state")
    func testInitialValidMoves() {
        let board = Board.initial
        let gameState = GameState(board: board, currentPlayer: .black)
        let engine = GameEngine()
        
        let validMoves = engine.availableMoves(for: gameState)
        
        #expect(validMoves.count == 4)
        #expect(validMoves.contains(Move(position: BoardPosition(row: 2, col: 3))))
    }
    
    @Test("Move validation", arguments: [
        (BoardPosition(row: 2, col: 3), true),
        (BoardPosition(row: 0, col: 0), false),
        (BoardPosition(row: 3, col: 3), false) // Occupied
    ])
    func testMoveValidation(position: BoardPosition, expectedValid: Bool) {
        let gameState = GameState.initial
        let engine = GameEngine()
        let move = Move(position: position)
        
        let isValid = engine.isValidMove(move, in: gameState)
        
        #expect(isValid == expectedValid)
    }
}
```

## Testing Structure

### Test Organization
```
Tests/
├── ModelTests/
│   ├── BoardTests.swift
│   ├── GameStateTests.swift
│   └── PlayerTests.swift
├── ViewModelTests/
│   ├── GameViewModelTests.swift
│   └── SettingsViewModelTests.swift
├── ServiceTests/
│   ├── GameEngineTests.swift
│   ├── AIServiceTests.swift
│   └── PersistenceServiceTests.swift
└── IntegrationTests/
    ├── GameFlowTests.swift
    └── AIIntegrationTests.swift
```

### Naming Conventions
- Test files: `[ComponentName]Tests.swift`
- Test suites: `@Suite("[Component] Tests")`
- Test methods: Descriptive names explaining what is being tested
- Use `test` prefix for clarity when needed

## Model Testing

### Value Type Testing
```swift
@Suite("Board Model Tests")
struct BoardTests {
    
    @Test("Board initialization creates correct starting state")
    func testBoardInitialization() {
        let board = Board.initial
        
        #expect(board[BoardPosition(row: 3, col: 3)] == .white)
        #expect(board[BoardPosition(row: 3, col: 4)] == .black)
        #expect(board[BoardPosition(row: 4, col: 3)] == .black)
        #expect(board[BoardPosition(row: 4, col: 4)] == .white)
        
        // All other positions should be empty
        let emptyPositions = board.allPositions.filter { 
            board[$0] == .empty 
        }
        #expect(emptyPositions.count == 60)
    }
    
    @Test("Board copy and modify maintains immutability")
    func testBoardImmutability() {
        let originalBoard = Board.initial
        let position = BoardPosition(row: 2, col: 3)
        
        let newBoard = originalBoard.placing(.black, at: position)
        
        #expect(originalBoard[position] == .empty)
        #expect(newBoard[position] == .black)
    }
}
```

### Computed Property Testing
```swift
@Test("Game state correctly identifies game over conditions")
func testGameOverDetection() {
    // Create board with no valid moves
    let board = Board(/* ... specific state ... */)
    let gameState = GameState(board: board, currentPlayer: .black)
    
    #expect(gameState.isGameOver == true)
    #expect(gameState.winner == .white) // Assuming white has more pieces
}
```

## ViewModel Testing

### State Management Testing
```swift
@Suite("Game ViewModel Tests")
struct GameViewModelTests {
    
    @Test("Making valid move updates game state correctly")
    func testValidMoveUpdatesState() async {
        let mockEngine = MockGameEngine()
        let viewModel = GameViewModel(gameEngine: mockEngine)
        
        await viewModel.makeMove(at: BoardPosition(row: 2, col: 3))
        
        #expect(viewModel.gameState.currentPlayer == .white)
        #expect(mockEngine.applyMoveCalled)
    }
    
    @Test("Invalid move does not change game state")
    func testInvalidMoveRejected() async {
        let mockEngine = MockGameEngine()
        mockEngine.shouldReturnValidMove = false
        let viewModel = GameViewModel(gameEngine: mockEngine)
        let initialState = viewModel.gameState
        
        await viewModel.makeMove(at: BoardPosition(row: 0, col: 0))
        
        #expect(viewModel.gameState.currentPlayer == initialState.currentPlayer)
        #expect(!mockEngine.applyMoveCalled)
    }
}
```

### Async Testing
```swift
@Test("AI move calculation completes within reasonable time")
func testAIMovePerformance() async throws {
    let aiService = AIService()
    let gameState = GameState.initial
    
    let startTime = Date()
    let move = await aiService.selectMove(for: gameState, difficulty: .medium)
    let elapsed = Date().timeIntervalSince(startTime)
    
    #expect(move != nil)
    #expect(elapsed < 2.0) // Should complete within 2 seconds
}
```

## Service Testing

### Protocol-Based Mocking
```swift
class MockGameEngine: GameEngineProtocol {
    var shouldReturnValidMove = true
    var applyMoveCalled = false
    var lastAppliedMove: Move?
    
    func isValidMove(_ move: Move, in gameState: GameState) -> Bool {
        return shouldReturnValidMove
    }
    
    func applyMove(_ move: Move, to gameState: GameState) -> GameState {
        applyMoveCalled = true
        lastAppliedMove = move
        return gameState // Simplified for testing
    }
    
    func availableMoves(for gameState: GameState) -> [Move] {
        if shouldReturnValidMove {
            return [Move(position: BoardPosition(row: 2, col: 3))]
        } else {
            return []
        }
    }
}
```

### AI Algorithm Testing
```swift
@Suite("AI Service Tests")
struct AIServiceTests {
    
    @Test("Easy AI selects random valid moves")
    func testEasyAIRandomness() async {
        let aiService = AIService()
        let gameState = GameState.initial
        var selectedMoves: Set<BoardPosition> = []
        
        // Run multiple times to verify randomness
        for _ in 0..<10 {
            if let move = await aiService.selectMove(for: gameState, difficulty: .easy) {
                selectedMoves.insert(move.position)
            }
        }
        
        // Should select different moves (randomness check)
        #expect(selectedMoves.count > 1)
    }
    
    @Test("Hard AI makes strategically better moves than easy AI")
    func testAIDifficultyProgression() async {
        let aiService = AIService()
        let complexGameState = GameState(/* ... complex board position ... */)
        
        let easyMove = await aiService.selectMove(for: complexGameState, difficulty: .easy)
        let hardMove = await aiService.selectMove(for: complexGameState, difficulty: .hard)
        
        // Verify hard AI makes objectively better move
        // (This would require specific game position and evaluation)
        #expect(easyMove != hardMove)
    }
}
```

## Integration Testing

### Full Game Flow Testing
```swift
@Suite("Game Integration Tests")
struct GameFlowTests {
    
    @Test("Complete game flow from start to finish")
    func testCompleteGameFlow() async {
        let gameEngine = GameEngine()
        let aiService = AIService()
        let viewModel = GameViewModel(gameEngine: gameEngine, aiService: aiService)
        
        // Start game
        viewModel.startGame(mode: .humanVsAI, aiDifficulty: .easy)
        
        // Play several moves
        while !viewModel.gameState.isGameOver && viewModel.moveCount < 20 {
            if viewModel.gameState.currentPlayer == .black {
                // Human move
                let validMoves = viewModel.availableMoves
                if let firstMove = validMoves.first {
                    await viewModel.makeMove(at: firstMove.position)
                }
            } else {
                // AI move happens automatically
                await Task.sleep(for: .milliseconds(100))
            }
        }
        
        // Verify game completed successfully
        #expect(viewModel.gameState.isGameOver || viewModel.moveCount >= 20)
    }
}
```

## Performance Testing

### Memory and Performance
```swift
@Test("Board operations are memory efficient")
func testBoardMemoryEfficiency() {
    let board = Board.initial
    
    // Measure memory usage for large number of operations
    var boards: [Board] = []
    
    for i in 0..<1000 {
        let position = BoardPosition(row: i % 8, col: (i / 8) % 8)
        let newBoard = board.placing(.black, at: position)
        boards.append(newBoard)
    }
    
    // Verify reasonable memory usage (implementation-specific)
    #expect(boards.count == 1000)
}
```

## Accessibility Testing

### VoiceOver Testing
```swift
@Test("Game view provides proper accessibility labels")
func testGameViewAccessibility() {
    let gameState = GameState.initial
    let viewModel = GameViewModel(gameState: gameState)
    
    // Test that all interactive elements have accessibility support
    let board = gameState.board
    for position in board.allPositions {
        let cellView = CellView(
            position: position,
            state: board[position],
            isValidMove: gameState.availableMoves.contains { $0.position == position }
        )
        
        // Verify accessibility properties exist
        #expect(cellView.accessibilityLabel != nil)
        if board[position] == .empty && gameState.availableMoves.contains(where: { $0.position == position }) {
            #expect(cellView.accessibilityHint != nil)
        }
    }
}
```

## Test Data and Utilities

### Test Fixtures
```swift
extension GameState {
    static var almostComplete: GameState {
        // Create specific game state for testing
        var board = Board.empty
        // ... set up specific board configuration
        return GameState(board: board, currentPlayer: .black)
    }
    
    static var tieGame: GameState {
        // Create board state that results in tie
        var board = Board.empty
        // ... set up tie configuration
        return GameState(board: board, currentPlayer: .black)
    }
}
```

### Test Utilities
```swift
struct TestUtilities {
    static func createBoardFromString(_ boardString: String) -> Board {
        // Parse ASCII art board representation for tests
        // Example:
        // """
        // ........
        // ........
        // ...BW...
        // ...WB...
        // ........
        // """
    }
    
    static func assertBoardEquals(_ board1: Board, _ board2: Board, file: StaticString = #file, line: UInt = #line) {
        // Custom assertion for board equality with helpful failure messages
    }
}
```

## Continuous Integration

### Test Execution
```bash
# Run all tests
xcodebuild test -scheme OthelloApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -scheme OthelloApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:OthelloAppTests/GameEngineTests

# Generate code coverage report
xcodebuild test -scheme OthelloApp -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```

### Coverage Requirements
- Minimum 90% line coverage for new code
- 100% coverage for critical game logic (move validation, AI algorithms)
- Exclusions allowed for UI boilerplate and generated code

### Quality Gates
1. All tests must pass
2. Code coverage thresholds met
3. No SwiftLint violations
4. Performance tests within acceptable limits

## Best Practices

### Test Organization
- Group related tests in suites
- Use descriptive test names
- Keep tests focused and atomic
- Avoid test interdependencies

### Assertions
- Use specific assertions (`#expect(value == expected)` vs `#expect(value)`)
- Provide helpful failure messages
- Test both positive and negative cases
- Verify side effects when appropriate

### Mocking Strategy
- Mock external dependencies
- Keep mocks simple and focused
- Verify mock interactions when relevant
- Use protocols for mockable interfaces

### Test Maintenance
- Regular review and cleanup of tests
- Update tests when requirements change
- Remove obsolete tests
- Refactor test code for maintainability