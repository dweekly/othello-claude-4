//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation
@testable import OthelloCore

/// Utilities for creating test data and scenarios
public struct TestUtilities {
    
    // MARK: - Board Creation Utilities
    
    /// Creates a board from ASCII art representation
    /// - Parameter boardString: String representation where:
    ///   - '.' = empty
    ///   - 'B' or '●' = black
    ///   - 'W' or '○' = white
    /// - Returns: Board with the specified configuration
    public static func createBoard(from boardString: String) -> Board {
        let lines = boardString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard lines.count == 8 else {
            fatalError("Board string must have exactly 8 lines")
        }
        
        var placements: [BoardPosition: CellState] = [:]
        
        for (row, line) in lines.enumerated() {
            let chars = Array(line.replacingOccurrences(of: " ", with: ""))
            guard chars.count == 8 else {
                fatalError("Each line must have exactly 8 characters (excluding spaces)")
            }
            
            for (col, char) in chars.enumerated() {
                let position = BoardPosition(row: row, col: col)
                
                switch char {
                case ".", "_", "-":
                    placements[position] = .empty
                case "B", "●", "b":
                    placements[position] = .black
                case "W", "○", "w":
                    placements[position] = .white
                default:
                    fatalError("Invalid character '\(char)' in board string. Use '.', 'B', or 'W'")
                }
            }
        }
        
        return Board().placing(placements)
    }
    
    /// Creates a board with random piece placement
    /// - Parameters:
    ///   - blackPieces: Number of black pieces to place
    ///   - whitePieces: Number of white pieces to place
    ///   - seed: Random seed for reproducible results
    /// - Returns: Board with randomly placed pieces
    public static func createRandomBoard(blackPieces: Int, whitePieces: Int, seed: UInt64 = 42) -> Board {
        var generator = SeededRandomNumberGenerator(seed: seed)
        let totalPieces = blackPieces + whitePieces
        
        guard totalPieces <= 64 else {
            fatalError("Total pieces cannot exceed 64")
        }
        
        let allPositions = BoardPosition.allPositions.shuffled(using: &generator)
        var placements: [BoardPosition: CellState] = [:]
        
        for i in 0..<totalPieces {
            let position = allPositions[i]
            placements[position] = i < blackPieces ? .black : .white
        }
        
        return Board().placing(placements)
    }
    
    // MARK: - Game State Creation Utilities
    
    /// Creates a game state from a board configuration
    /// - Parameters:
    ///   - board: The board configuration
    ///   - currentPlayer: Current player (default: .black)
    ///   - gamePhase: Game phase (default: .playing)
    ///   - blackPlayerType: Black player type (default: .human)
    ///   - whitePlayerType: White player type (default: .human)
    /// - Returns: GameState with the specified configuration
    public static func createGameState(
        board: Board,
        currentPlayer: Player = .black,
        gamePhase: GamePhase = .playing,
        blackPlayerType: PlayerType = .human,
        whitePlayerType: PlayerType = .human
    ) -> GameState {
        return GameState(
            board: board,
            currentPlayer: currentPlayer,
            gamePhase: gamePhase,
            blackPlayerInfo: PlayerInfo(player: .black, type: blackPlayerType),
            whitePlayerInfo: PlayerInfo(player: .white, type: whitePlayerType)
        )
    }
    
    /// Creates a near-endgame scenario for testing
    /// - Returns: GameState near the end of the game
    public static func createNearEndgameState() -> GameState {
        let boardString = """
        BBBBBBBB
        BBBBBBBB
        BBBBBBBB
        BBBWWBBB
        BBBWWBBB
        BBBBBBBB
        BBBBB...
        BBBBB...
        """
        
        let board = createBoard(from: boardString)
        return createGameState(board: board, currentPlayer: .white)
    }
    
    /// Creates a corner control scenario
    /// - Returns: GameState where corner control is important
    public static func createCornerControlState() -> GameState {
        let boardString = """
        B.......
        WB......
        WWB.....
        WWWB....
        WWWWB...
        WWWWWB..
        WWWWWWB.
        WWWWWWWB
        """
        
        let board = createBoard(from: boardString)
        return createGameState(board: board, currentPlayer: .white)
    }
    
    /// Creates a mobility test scenario
    /// - Returns: GameState where mobility is critical
    public static func createMobilityTestState() -> GameState {
        let boardString = """
        ........
        .BBBBB..
        .BWWWB..
        .BWWWB..
        .BWWWB..
        .BBBBB..
        ........
        ........
        """
        
        let board = createBoard(from: boardString)
        return createGameState(board: board, currentPlayer: .black)
    }
    
    // MARK: - Performance Test Utilities
    
    /// Measures execution time of a block
    /// - Parameter block: Block to measure
    /// - Returns: Execution time in seconds
    public static func measureTime<T>(_ block: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }
    
    /// Measures execution time of an async block
    /// - Parameter block: Async block to measure
    /// - Returns: Execution time in seconds
    public static func measureTime<T>(_ block: () async throws -> T) async rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }
    
    // MARK: - Assertion Helpers
    
    /// Asserts that two boards are equal with detailed failure message
    /// - Parameters:
    ///   - board1: First board
    ///   - board2: Second board
    ///   - message: Custom failure message
    public static func assertBoardsEqual(
        _ board1: Board,
        _ board2: Board,
        message: String = "Boards should be equal"
    ) {
        guard board1 != board2 else { return }
        
        var differences: [String] = []
        
        for position in BoardPosition.allPositions {
            if board1[position] != board2[position] {
                differences.append("\(position.algebraicNotation): \(board1[position]) != \(board2[position])")
            }
        }
        
        let detailedMessage = """
        \(message)
        Differences:
        \(differences.joined(separator: "\n"))
        
        Board 1:
        \(board1.description)
        
        Board 2:
        \(board2.description)
        """
        
        fatalError(detailedMessage)
    }
    
    /// Asserts that a game state is valid
    /// - Parameters:
    ///   - gameState: Game state to validate
    ///   - engine: Game engine to use for validation
    public static func assertValidGameState(
        _ gameState: GameState,
        using engine: GameEngineProtocol = GameEngine()
    ) {
        let issues = (engine as? GameEngine)?.validateGameState(gameState) ?? []
        
        if !issues.isEmpty {
            fatalError("Invalid game state:\n\(issues.joined(separator: "\n"))")
        }
    }
    
    // MARK: - Test Data Generators
    
    /// Generates a sequence of valid moves for testing AI
    /// - Parameters:
    ///   - gameState: Starting game state
    ///   - maxMoves: Maximum number of moves to generate
    /// - Returns: Array of valid moves
    public static func generateValidMoveSequence(
        from gameState: GameState,
        maxMoves: Int = 10
    ) -> [Move] {
        let engine = GameEngine()
        var currentState = gameState
        var moves: [Move] = []
        
        for _ in 0..<maxMoves {
            let availableMoves = engine.availableMoves(for: currentState)
            guard !availableMoves.isEmpty else { break }
            
            // Take the first available move
            let move = Move(position: availableMoves[0], player: currentState.currentPlayer)
            moves.append(move)
            
            guard let result = engine.applyMove(move, to: currentState) else { break }
            currentState = result.newGameState
            
            if engine.isGameOver(currentState) {
                break
            }
        }
        
        return moves
    }
    
    /// Creates test scenarios for different game phases
    public enum GamePhaseScenario {
        case opening    // First few moves
        case midgame    // Active piece development
        case endgame    // Few empty squares left
        case finished   // Game over
        
        var gameState: GameState {
            switch self {
            case .opening:
                return GameState.newHumanVsHuman()
                
            case .midgame:
                let boardString = """
                ........
                ..BBB...
                .BWWWB..
                .BWWWB..
                .BWWWB..
                ..BBB...
                ........
                ........
                """
                let board = TestUtilities.createBoard(from: boardString)
                return TestUtilities.createGameState(board: board)
                
            case .endgame:
                return TestUtilities.createNearEndgameState()
                
            case .finished:
                let fullBoard = TestUtilities.createRandomBoard(blackPieces: 35, whitePieces: 29)
                return TestUtilities.createGameState(
                    board: fullBoard,
                    gamePhase: .finished
                )
            }
        }
    }
}

// MARK: - Seeded Random Number Generator

/// Random number generator with a seed for reproducible tests
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}

// MARK: - Extensions for Testing

extension Board {
    /// Creates a board from a simple string pattern
    /// - Parameter pattern: 64-character string where each character represents a cell
    /// - Returns: Board with the pattern applied
    public static func from(pattern: String) -> Board {
        let cleanPattern = pattern.replacingOccurrences(of: " ", with: "")
        guard cleanPattern.count == 64 else {
            fatalError("Pattern must have exactly 64 characters")
        }
        
        var placements: [BoardPosition: CellState] = [:]
        
        for (index, char) in cleanPattern.enumerated() {
            let row = index / 8
            let col = index % 8
            let position = BoardPosition(row: row, col: col)
            
            switch char {
            case ".", "-", "_":
                placements[position] = .empty
            case "B", "b", "●":
                placements[position] = .black
            case "W", "w", "○":
                placements[position] = .white
            default:
                fatalError("Invalid character '\(char)' in pattern")
            }
        }
        
        return Board().placing(placements)
    }
}

extension GameState {
    /// Creates a test game state with AI players
    /// - Parameters:
    ///   - blackDifficulty: Black AI difficulty
    ///   - whiteDifficulty: White AI difficulty
    /// - Returns: GameState with AI players
    public static func testAIGame(
        blackDifficulty: AIDifficulty = .medium,
        whiteDifficulty: AIDifficulty = .medium
    ) -> GameState {
        return GameState.newAIVsAI(
            blackDifficulty: blackDifficulty,
            whiteDifficulty: whiteDifficulty
        )
    }
}