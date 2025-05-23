//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Protocol defining the AI service interface for Othello
///
/// This protocol abstracts AI move calculation, making it easy to test
/// and potentially swap AI implementations.
public protocol AIServiceProtocol {
    // MARK: - Move Calculation
    
    /// Calculates the best move for an AI player asynchronously
    /// - Parameters:
    ///   - gameState: Current game state
    ///   - playerInfo: AI player information including difficulty
    ///   - gameEngine: Game engine for move validation and evaluation
    /// - Returns: The selected move, or nil if no valid moves available
    func calculateMove(
        for gameState: GameState,
        playerInfo: PlayerInfo,
        using gameEngine: GameEngineProtocol
    ) async -> Move?
    
    /// Calculates the best move for a specific difficulty level
    /// - Parameters:
    ///   - gameState: Current game state
    ///   - player: The AI player making the move
    ///   - difficulty: AI difficulty level
    ///   - gameEngine: Game engine for move validation and evaluation
    /// - Returns: The selected move, or nil if no valid moves available
    func calculateMove(
        for gameState: GameState,
        player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> Move?
    
    // MARK: - AI Analysis
    
    /// Evaluates a position and returns detailed analysis
    /// - Parameters:
    ///   - gameState: Current game state
    ///   - player: Player perspective for evaluation
    ///   - difficulty: AI difficulty level affecting analysis depth
    ///   - gameEngine: Game engine for position evaluation
    /// - Returns: Detailed position analysis
    func analyzePosition(
        _ gameState: GameState,
        for player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> AIAnalysis
    
    /// Gets move recommendations with confidence scores
    /// - Parameters:
    ///   - gameState: Current game state
    ///   - player: Player to get recommendations for
    ///   - difficulty: AI difficulty level
    ///   - gameEngine: Game engine for evaluation
    /// - Returns: Array of moves ranked by preference
    func getMoveRecommendations(
        for gameState: GameState,
        player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> [MoveRecommendation]
    
    // MARK: - Performance
    
    /// Cancels any ongoing AI calculation
    func cancelCalculation()
    
    /// Whether the AI is currently calculating a move
    var isCalculating: Bool { get }
}

// MARK: - Supporting Types

/// Detailed AI analysis of a position
public struct AIAnalysis: Codable {
    public let position: PositionAnalysis
    public let bestMove: BoardPosition?
    public let confidence: Double // 0.0 to 1.0
    public let searchDepth: Int
    public let nodesEvaluated: Int
    public let calculationTimeMs: Int
    public let principalVariation: [Move] // Best line of play
    
    public init(
        position: PositionAnalysis,
        bestMove: BoardPosition?,
        confidence: Double,
        searchDepth: Int,
        nodesEvaluated: Int,
        calculationTimeMs: Int,
        principalVariation: [Move]
    ) {
        self.position = position
        self.bestMove = bestMove
        self.confidence = confidence
        self.searchDepth = searchDepth
        self.nodesEvaluated = nodesEvaluated
        self.calculationTimeMs = calculationTimeMs
        self.principalVariation = principalVariation
    }
}

/// Move recommendation with confidence score
public struct MoveRecommendation: Codable {
    public let move: BoardPosition
    public let evaluation: Double
    public let confidence: Double
    public let reasoning: String
    
    public init(move: BoardPosition, evaluation: Double, confidence: Double, reasoning: String) {
        self.move = move
        self.evaluation = evaluation
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

// MARK: - Default Implementation Extensions

public extension AIServiceProtocol {
    /// Convenience method for calculating moves with PlayerInfo
    func calculateMove(
        for gameState: GameState,
        playerInfo: PlayerInfo,
        using gameEngine: GameEngineProtocol
    ) async -> Move? {
        guard playerInfo.isAI,
              let difficulty = playerInfo.aiDifficulty else {
            return nil
        }
        
        return await calculateMove(
            for: gameState,
            player: playerInfo.player,
            difficulty: difficulty,
            using: gameEngine
        )
    }
}