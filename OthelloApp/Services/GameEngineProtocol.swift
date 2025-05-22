import Foundation

/// Protocol defining the core game engine interface for Othello
///
/// This protocol abstracts the game rules and logic, making it easy to test
/// and potentially swap implementations in the future.
public protocol GameEngineProtocol {
    // MARK: - Move Validation

    /// Checks if a move is valid for the given game state
    /// - Parameters:
    ///   - move: The move to validate
    ///   - gameState: Current game state
    /// - Returns: True if the move is valid
    func isValidMove(_ move: Move, in gameState: GameState) -> Bool

    /// Gets all valid moves for the current player in the given game state
    /// - Parameter gameState: Current game state
    /// - Returns: Array of valid positions for moves
    func availableMoves(for gameState: GameState) -> [BoardPosition]

    /// Gets all valid moves for a specific player
    /// - Parameters:
    ///   - player: The player to get moves for
    ///   - gameState: Current game state
    /// - Returns: Array of valid positions for moves
    func availableMoves(for player: Player, in gameState: GameState) -> [BoardPosition]

    // MARK: - Move Application

    /// Applies a move to the game state, returning the updated state
    /// - Parameters:
    ///   - move: The move to apply
    ///   - gameState: Current game state
    /// - Returns: Result containing new game state and captured positions, or nil if invalid
    func applyMove(_ move: Move, to gameState: GameState) -> MoveResult?

    /// Calculates what pieces would be captured by a move without applying it
    /// - Parameters:
    ///   - move: The move to analyze
    ///   - gameState: Current game state
    /// - Returns: Array of positions that would be captured
    func capturedPositions(for move: Move, in gameState: GameState) -> [BoardPosition]

    // MARK: - Game State Analysis

    /// Determines if the game is over (no valid moves for either player)
    /// - Parameter gameState: Current game state
    /// - Returns: True if the game is over
    func isGameOver(_ gameState: GameState) -> Bool

    /// Determines the winner of a finished game
    /// - Parameter gameState: Current game state (should be finished)
    /// - Returns: The winning player, or nil if tied
    func winner(of gameState: GameState) -> Player?

    /// Checks if a player has any valid moves
    /// - Parameters:
    ///   - player: The player to check
    ///   - gameState: Current game state
    /// - Returns: True if the player has valid moves
    func hasValidMoves(_ player: Player, in gameState: GameState) -> Bool

    // MARK: - Game Flow

    /// Determines the next game state after a player's turn
    /// Handles cases where the next player has no moves
    /// - Parameter gameState: Current game state
    /// - Returns: Updated game state with correct current player and phase
    func nextTurn(from gameState: GameState) -> GameState

    /// Creates a new game with the specified configuration
    /// - Parameters:
    ///   - blackPlayerInfo: Information about the black player
    ///   - whitePlayerInfo: Information about the white player
    /// - Returns: New game state ready to play
    func newGame(blackPlayer: PlayerInfo, whitePlayer: PlayerInfo) -> GameState

    // MARK: - Board Analysis

    /// Evaluates the board position for AI purposes
    /// - Parameters:
    ///   - gameState: Current game state
    ///   - player: Player perspective for evaluation
    /// - Returns: Numeric evaluation (positive is good for player)
    func evaluatePosition(_ gameState: GameState, for player: Player) -> Double

    /// Gets strategic information about a board position
    /// - Parameter gameState: Current game state
    /// - Returns: Strategic analysis of the position
    func analyzePosition(_ gameState: GameState) -> PositionAnalysis
}

// MARK: - Supporting Types

/// Strategic analysis of a board position
public struct PositionAnalysis: Codable {
    public let mobility: [Player: Int]          // Number of moves for each player
    public let cornerControl: [Player: Int]     // Number of corners controlled
    public let edgeControl: [Player: Int]       // Number of edge pieces
    public let stability: [Player: Double]      // Piece stability score
    public let evaluation: [Player: Double]     // Overall position evaluation

    public init(mobility: [Player: Int],
                cornerControl: [Player: Int],
                edgeControl: [Player: Int],
                stability: [Player: Double],
                evaluation: [Player: Double]) {
        self.mobility = mobility
        self.cornerControl = cornerControl
        self.edgeControl = edgeControl
        self.stability = stability
        self.evaluation = evaluation
    }

    /// Difference in mobility between players (positive means black has more moves)
    public var mobilityDifference: Int {
        return (mobility[.black] ?? 0) - (mobility[.white] ?? 0)
    }

    /// Which player has better corner control
    public var cornerAdvantage: Player? {
        let blackCorners = cornerControl[.black] ?? 0
        let whiteCorners = cornerControl[.white] ?? 0

        if blackCorners > whiteCorners {
            return .black
        } else if whiteCorners > blackCorners {
            return .white
        } else {
            return nil
        }
    }

    /// Overall assessment of who is winning
    public var advantage: Player? {
        let blackEval = evaluation[.black] ?? 0.0
        let whiteEval = evaluation[.white] ?? 0.0

        if blackEval > whiteEval {
            return .black
        } else if whiteEval > blackEval {
            return .white
        } else {
            return nil
        }
    }
}
