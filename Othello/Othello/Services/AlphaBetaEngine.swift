//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Alpha-beta pruning minimax algorithm implementation
final class AlphaBetaEngine {
    
    func calculateBestMove(
        gameState: GameState,
        player: Player,
        depth: Int,
        gameEngine: GameEngineProtocol
    ) async -> (move: BoardPosition?, score: Double, nodesEvaluated: Int) {
        
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        guard !availableMoves.isEmpty else {
            return (nil, gameEngine.evaluatePosition(gameState, for: player), 1)
        }
        
        var bestMove: BoardPosition?
        var bestScore = -Double.infinity
        var currentAlpha = -Double.infinity
        let beta = Double.infinity
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
        
        // If no moves available, switch player or end game
        if availableMoves.isEmpty {
            let switchedState = gameState.switchingPlayer()
            if switchedState.gamePhase == .finished {
                let score = gameEngine.evaluatePosition(switchedState, for: targetPlayer)
                return (nil, score, 1)
            }
            
            return await alphaBetaRecursive(
                gameState: switchedState,
                depth: depth - 1,
                alpha: alpha,
                beta: beta,
                maximizingPlayer: !maximizingPlayer,
                targetPlayer: targetPlayer,
                gameEngine: gameEngine
            )
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        var totalNodes = 0
        var bestScore = maximizingPlayer ? -Double.infinity : Double.infinity
        var bestMove: BoardPosition?
        
        for position in availableMoves {
            guard !Task.isCancelled else { break }
            
            let move = Move(position: position, player: currentPlayer)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }
            
            let (_, score, nodes) = await alphaBetaRecursive(
                gameState: result.newGameState,
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
}