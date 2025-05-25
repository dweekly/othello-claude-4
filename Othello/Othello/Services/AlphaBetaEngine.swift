//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Parameters for alpha-beta recursive function
private struct AlphaBetaParams {
    let depth: Int
    let alpha: Double
    let beta: Double
    let maximizingPlayer: Bool
    let targetPlayer: Player
}

/// Alpha-beta pruning minimax algorithm implementation
final class AlphaBetaEngine {
    func calculateBestMove(
        gameState: GameState,
        player: Player,
        depth: Int,
        gameEngine: GameEngineProtocol
    ) async -> MoveEvaluation {
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        guard !availableMoves.isEmpty else {
            return MoveEvaluation(
                move: nil,
                score: gameEngine.evaluatePosition(gameState, for: player),
                nodesEvaluated: 1
            )
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

            let evaluation = await alphaBetaRecursive(
                gameState: result.newGameState,
                params: AlphaBetaParams(
                    depth: depth - 1,
                    alpha: currentAlpha,
                    beta: beta,
                    maximizingPlayer: false,
                    targetPlayer: player
                ),
                gameEngine: gameEngine
            )

            totalNodes += evaluation.nodesEvaluated + 1
            let score = evaluation.score

            if score > bestScore {
                bestScore = score
                bestMove = position
            }

            currentAlpha = max(currentAlpha, score)
            if beta <= currentAlpha {
                break // Beta cutoff
            }
        }

        return MoveEvaluation(move: bestMove, score: bestScore, nodesEvaluated: totalNodes)
    }

    private func alphaBetaRecursive(
        gameState: GameState,
        params: AlphaBetaParams,
        gameEngine: GameEngineProtocol
    ) async -> MoveEvaluation {
        // Base case: depth reached or game over
        if params.depth == 0 || gameEngine.isGameOver(gameState) {
            let score = gameEngine.evaluatePosition(gameState, for: params.targetPlayer)
            return MoveEvaluation(move: nil, score: score, nodesEvaluated: 1)
        }

        let currentPlayer = gameState.currentPlayer
        let availableMoves = gameEngine.availableMoves(for: currentPlayer, in: gameState)

        // If no moves available, switch player or end game
        if availableMoves.isEmpty {
            let switchedState = gameState.switchingPlayer()
            if switchedState.gamePhase == .finished {
                let score = gameEngine.evaluatePosition(switchedState, for: params.targetPlayer)
                return MoveEvaluation(move: nil, score: score, nodesEvaluated: 1)
            }

            return await alphaBetaRecursive(
                gameState: switchedState,
                params: AlphaBetaParams(
                    depth: params.depth - 1,
                    alpha: params.alpha,
                    beta: params.beta,
                    maximizingPlayer: !params.maximizingPlayer,
                    targetPlayer: params.targetPlayer
                ),
                gameEngine: gameEngine
            )
        }

        var currentAlpha = params.alpha
        var currentBeta = params.beta
        var totalNodes = 0
        var bestScore = params.maximizingPlayer ? -Double.infinity : Double.infinity
        var bestMove: BoardPosition?

        for position in availableMoves {
            guard !Task.isCancelled else { break }

            let move = Move(position: position, player: currentPlayer)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }

            let evaluation = await alphaBetaRecursive(
                gameState: result.newGameState,
                params: AlphaBetaParams(
                    depth: params.depth - 1,
                    alpha: currentAlpha,
                    beta: currentBeta,
                    maximizingPlayer: !params.maximizingPlayer,
                    targetPlayer: params.targetPlayer
                ),
                gameEngine: gameEngine
            )

            totalNodes += evaluation.nodesEvaluated + 1
            let score = evaluation.score

            if params.maximizingPlayer {
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

        return MoveEvaluation(move: bestMove, score: bestScore, nodesEvaluated: totalNodes)
    }
}
