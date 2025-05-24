//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Production implementation of the AI service for Othello
///
/// This class implements various AI algorithms for different difficulty levels,
/// from random moves to advanced minimax with alpha-beta pruning.
final class AIService: AIServiceProtocol {
    
    // MARK: - Properties
    
    private var calculationTask: Task<Move?, Never>?
    private let random = SystemRandomNumberGenerator()
    
    var isCalculating: Bool {
        calculationTask != nil && !calculationTask!.isCancelled
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Move Calculation
    
    func calculateMove(
        for gameState: GameState,
        player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> Move? {
        
        // Cancel any existing calculation
        cancelCalculation()
        
        // Start new calculation
        calculationTask = Task {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Add realistic thinking time based on difficulty
            let thinkingTime = Double.random(in: difficulty.thinkingTimeRange)
            try? await Task.sleep(nanoseconds: UInt64(thinkingTime * 1_000_000_000))
            
            // Check if cancelled
            guard !Task.isCancelled else { return nil }
            
            // Get available moves
            let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
            guard !availableMoves.isEmpty else { return nil }
            
            // Calculate best move based on difficulty
            let bestPosition: BoardPosition
            
            switch difficulty {
            case .easy:
                bestPosition = await calculateEasyMove(
                    availableMoves: availableMoves,
                    gameState: gameState,
                    player: player,
                    gameEngine: gameEngine
                )
                
            case .medium:
                bestPosition = await calculateMediumMove(
                    availableMoves: availableMoves,
                    gameState: gameState,
                    player: player,
                    gameEngine: gameEngine
                )
                
            case .hard:
                bestPosition = await calculateHardMove(
                    availableMoves: availableMoves,
                    gameState: gameState,
                    player: player,
                    gameEngine: gameEngine
                )
            }
            
            return Move(position: bestPosition, player: player)
        }
        
        return await calculationTask?.value
    }
    
    // MARK: - AI Analysis
    
    func analyzePosition(
        _ gameState: GameState,
        for player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> AIAnalysis {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let baseAnalysis = gameEngine.analyzePosition(gameState)
        
        // Get available moves
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        
        var bestMove: BoardPosition?
        var confidence: Double = 0.0
        var nodesEvaluated = 0
        var principalVariation: [Move] = []
        
        if !availableMoves.isEmpty {
            switch difficulty {
            case .easy:
                // Random selection with low confidence
                bestMove = availableMoves.randomElement()
                confidence = 0.3
                nodesEvaluated = availableMoves.count
                
            case .medium:
                // Basic minimax evaluation
                let (move, _, nodes) = await minimaxSearch(
                    gameState: gameState,
                    player: player,
                    depth: difficulty.searchDepth,
                    gameEngine: gameEngine
                )
                bestMove = move
                confidence = 0.7
                nodesEvaluated = nodes
                
            case .hard:
                // Advanced minimax with alpha-beta pruning
                let (move, _, nodes) = await alphaBetaSearch(
                    gameState: gameState,
                    player: player,
                    depth: difficulty.searchDepth,
                    alpha: -Double.infinity,
                    beta: Double.infinity,
                    gameEngine: gameEngine
                )
                bestMove = move
                confidence = 0.9
                nodesEvaluated = nodes
            }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let calculationTimeMs = Int((endTime - startTime) * 1000)
        
        return AIAnalysis(
            position: baseAnalysis,
            bestMove: bestMove,
            confidence: confidence,
            searchDepth: difficulty.searchDepth,
            nodesEvaluated: nodesEvaluated,
            calculationTimeMs: calculationTimeMs,
            principalVariation: principalVariation
        )
    }
    
    func getMoveRecommendations(
        for gameState: GameState,
        player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> [MoveRecommendation] {
        
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        guard !availableMoves.isEmpty else { return [] }
        
        var recommendations: [MoveRecommendation] = []
        
        for position in availableMoves {
            let move = Move(position: position, player: player)
            
            // Simulate the move to evaluate its quality
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }
            
            let evaluation = gameEngine.evaluatePosition(result.newGameState, for: player)
            let confidence = min(1.0, max(0.0, (evaluation + 100) / 200)) // Normalize to 0-1
            
            let reasoning = generateMoveReasoning(
                move: move,
                result: result,
                gameState: gameState,
                gameEngine: gameEngine
            )
            
            recommendations.append(MoveRecommendation(
                move: position,
                evaluation: evaluation,
                confidence: confidence,
                reasoning: reasoning
            ))
        }
        
        // Sort by evaluation score (best first)
        recommendations.sort { $0.evaluation > $1.evaluation }
        
        return recommendations
    }
    
    // MARK: - Performance
    
    func cancelCalculation() {
        calculationTask?.cancel()
        calculationTask = nil
    }
    
    // MARK: - Private AI Algorithms
    
    private func calculateEasyMove(
        availableMoves: [BoardPosition],
        gameState: GameState,
        player: Player,
        gameEngine: GameEngineProtocol
    ) async -> BoardPosition {
        // Easy AI: Random move selection with slight preference for corners
        var weightedMoves: [BoardPosition] = []
        
        for position in availableMoves {
            // Add corner positions multiple times to increase their chance
            if isCorner(position) {
                weightedMoves.append(contentsOf: Array(repeating: position, count: 3))
            } else {
                weightedMoves.append(position)
            }
        }
        
        return weightedMoves.randomElement() ?? availableMoves.first!
    }
    
    private func calculateMediumMove(
        availableMoves: [BoardPosition],
        gameState: GameState,
        player: Player,
        gameEngine: GameEngineProtocol
    ) async -> BoardPosition {
        // Medium AI: Basic minimax search
        let (bestMove, _, _) = await minimaxSearch(
            gameState: gameState,
            player: player,
            depth: AIDifficulty.medium.searchDepth,
            gameEngine: gameEngine
        )
        
        return bestMove ?? availableMoves.first!
    }
    
    private func calculateHardMove(
        availableMoves: [BoardPosition],
        gameState: GameState,
        player: Player,
        gameEngine: GameEngineProtocol
    ) async -> BoardPosition {
        // Hard AI: Minimax with alpha-beta pruning
        let (bestMove, _, _) = await alphaBetaSearch(
            gameState: gameState,
            player: player,
            depth: AIDifficulty.hard.searchDepth,
            alpha: -Double.infinity,
            beta: Double.infinity,
            gameEngine: gameEngine
        )
        
        return bestMove ?? availableMoves.first!
    }
    
    // MARK: - Minimax Algorithm
    
    private func minimaxSearch(
        gameState: GameState,
        player: Player,
        depth: Int,
        gameEngine: GameEngineProtocol
    ) async -> (move: BoardPosition?, score: Double, nodesEvaluated: Int) {
        
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        guard !availableMoves.isEmpty else { return (nil, -Double.infinity, 1) }
        
        var bestMove: BoardPosition?
        var bestScore = -Double.infinity
        var totalNodes = 0
        
        for position in availableMoves {
            guard !Task.isCancelled else { break }
            
            let move = Move(position: position, player: player)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }
            
            let (_, score, nodes) = await minimaxRecursive(
                gameState: result.newGameState,
                depth: depth - 1,
                maximizingPlayer: false,
                targetPlayer: player,
                gameEngine: gameEngine
            )
            
            totalNodes += nodes + 1
            
            if score > bestScore {
                bestScore = score
                bestMove = position
            }
        }
        
        return (bestMove, bestScore, totalNodes)
    }
    
    private func minimaxRecursive(
        gameState: GameState,
        depth: Int,
        maximizingPlayer: Bool,
        targetPlayer: Player,
        gameEngine: GameEngineProtocol
    ) async -> (move: BoardPosition?, score: Double, nodesEvaluated: Int) {
        
        // Base case: depth reached or game over
        if depth == 0 || gameEngine.isGameOver(gameState) {
            let score = gameEngine.evaluatePosition(gameState, for: targetPlayer)
            return (nil, score, 1)
        }
        
        let currentPlayer = gameState.currentPlayer
        let availableMoves = gameEngine.availableMoves(for: currentPlayer, in: gameState)
        
        // If no moves available, pass turn or end game
        if availableMoves.isEmpty {
            let nextState = gameEngine.nextTurn(from: gameState)
            
            // If game ended after turn pass, evaluate final position
            if nextState.gamePhase == .finished {
                let score = gameEngine.evaluatePosition(nextState, for: targetPlayer)
                return (nil, score, 1)
            }
            
            // Continue with reduced depth
            return await minimaxRecursive(
                gameState: nextState,
                depth: depth - 1,
                maximizingPlayer: !maximizingPlayer,
                targetPlayer: targetPlayer,
                gameEngine: gameEngine
            )
        }
        
        var bestScore = maximizingPlayer ? -Double.infinity : Double.infinity
        var bestMove: BoardPosition?
        var totalNodes = 0
        
        for position in availableMoves {
            guard !Task.isCancelled else { break }
            
            let move = Move(position: position, player: currentPlayer)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }
            
            let nextState = gameEngine.nextTurn(from: result.newGameState)
            let (_, score, nodes) = await minimaxRecursive(
                gameState: nextState,
                depth: depth - 1,
                maximizingPlayer: !maximizingPlayer,
                targetPlayer: targetPlayer,
                gameEngine: gameEngine
            )
            
            totalNodes += nodes + 1
            
            if maximizingPlayer {
                if score > bestScore {
                    bestScore = score
                    bestMove = position
                }
            } else {
                if score < bestScore {
                    bestScore = score
                    bestMove = position
                }
            }
        }
        
        return (bestMove, bestScore, totalNodes)
    }
    
    // MARK: - Alpha-Beta Pruning Algorithm
    
    private func alphaBetaSearch(
        gameState: GameState,
        player: Player,
        depth: Int,
        alpha: Double,
        beta: Double,
        gameEngine: GameEngineProtocol
    ) async -> (move: BoardPosition?, score: Double, nodesEvaluated: Int) {
        
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        guard !availableMoves.isEmpty else { return (nil, -Double.infinity, 1) }
        
        var bestMove: BoardPosition?
        var bestScore = -Double.infinity
        var currentAlpha = alpha
        var totalNodes = 0
        
        for position in availableMoves {
            guard !Task.isCancelled else { break }
            
            let move = Move(position: position, player: player)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }
            
            let (_, score, nodes) = await alphaBetaRecursive(
                gameState: result.newGameState,
                depth: depth - 1,
                alpha: currentAlpha,
                beta: beta,
                maximizingPlayer: false,
                targetPlayer: player,
                gameEngine: gameEngine
            )
            
            totalNodes += nodes + 1
            
            if score > bestScore {
                bestScore = score
                bestMove = position
            }
            
            currentAlpha = max(currentAlpha, score)
            if beta <= currentAlpha {
                break // Beta cutoff
            }
        }
        
        return (bestMove, bestScore, totalNodes)
    }
    
    private func alphaBetaRecursive(
        gameState: GameState,
        depth: Int,
        alpha: Double,
        beta: Double,
        maximizingPlayer: Bool,
        targetPlayer: Player,
        gameEngine: GameEngineProtocol
    ) async -> (move: BoardPosition?, score: Double, nodesEvaluated: Int) {
        
        // Base case: depth reached or game over
        if depth == 0 || gameEngine.isGameOver(gameState) {
            let score = gameEngine.evaluatePosition(gameState, for: targetPlayer)
            return (nil, score, 1)
        }
        
        let currentPlayer = gameState.currentPlayer
        let availableMoves = gameEngine.availableMoves(for: currentPlayer, in: gameState)
        
        // If no moves available, pass turn or end game
        if availableMoves.isEmpty {
            let nextState = gameEngine.nextTurn(from: gameState)
            
            // If game ended after turn pass, evaluate final position
            if nextState.gamePhase == .finished {
                let score = gameEngine.evaluatePosition(nextState, for: targetPlayer)
                return (nil, score, 1)
            }
            
            // Continue with reduced depth
            return await alphaBetaRecursive(
                gameState: nextState,
                depth: depth - 1,
                alpha: alpha,
                beta: beta,
                maximizingPlayer: !maximizingPlayer,
                targetPlayer: targetPlayer,
                gameEngine: gameEngine
            )
        }
        
        var bestScore = maximizingPlayer ? -Double.infinity : Double.infinity
        var bestMove: BoardPosition?
        var currentAlpha = alpha
        var currentBeta = beta
        var totalNodes = 0
        
        for position in availableMoves {
            guard !Task.isCancelled else { break }
            
            let move = Move(position: position, player: currentPlayer)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }
            
            let nextState = gameEngine.nextTurn(from: result.newGameState)
            let (_, score, nodes) = await alphaBetaRecursive(
                gameState: nextState,
                depth: depth - 1,
                alpha: currentAlpha,
                beta: currentBeta,
                maximizingPlayer: !maximizingPlayer,
                targetPlayer: targetPlayer,
                gameEngine: gameEngine
            )
            
            totalNodes += nodes + 1
            
            if maximizingPlayer {
                if score > bestScore {
                    bestScore = score
                    bestMove = position
                }
                currentAlpha = max(currentAlpha, score)
                if currentBeta <= currentAlpha {
                    break // Beta cutoff
                }
            } else {
                if score < bestScore {
                    bestScore = score
                    bestMove = position
                }
                currentBeta = min(currentBeta, score)
                if currentBeta <= currentAlpha {
                    break // Alpha cutoff
                }
            }
        }
        
        return (bestMove, bestScore, totalNodes)
    }
    
    // MARK: - Helper Methods
    
    private func isCorner(_ position: BoardPosition) -> Bool {
        return (position.row == 0 || position.row == 7) &&
               (position.col == 0 || position.col == 7)
    }
    
    private func generateMoveReasoning(
        move: Move,
        result: MoveResult,
        gameState: GameState,
        gameEngine: GameEngineProtocol
    ) -> String {
        let capturedCount = result.capturedPositions.count
        
        if isCorner(move.position) {
            return "Corner move - excellent strategic position"
        } else if capturedCount > 6 {
            return "High-capture move (\(capturedCount) pieces)"
        } else if capturedCount > 3 {
            return "Good capture (\(capturedCount) pieces)"
        } else if move.position.row == 0 || move.position.row == 7 ||
                  move.position.col == 0 || move.position.col == 7 {
            return "Edge move - good positional play"
        } else {
            return "Solid tactical move"
        }
    }
}