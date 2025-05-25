//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Result of AI move calculation with performance metrics
struct MoveEvaluation {
    let move: BoardPosition?
    let score: Double
    let nodesEvaluated: Int
}

/// Production implementation of the AI service for Othello
final class AIService: AIServiceProtocol {

    // MARK: - Properties

    private var calculationTask: Task<Move?, Never>?
    private let random = SystemRandomNumberGenerator()
    private let alphaBetaEngine = AlphaBetaEngine()

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
        calculationTask = Task<Move?, Never> {
            _ = CFAbsoluteTimeGetCurrent()

            // Add realistic thinking time based on difficulty
            let thinkingTime = Double.random(in: difficulty.thinkingTimeRange)
            try? await Task.sleep(nanoseconds: UInt64(thinkingTime * 1_000_000_000))

            // Check if cancelled
            guard !Task.isCancelled else { return nil }

            // Get available moves
            let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
            guard !availableMoves.isEmpty else { return nil }

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
                let evaluation = await alphaBetaEngine.calculateBestMove(
                    gameState: gameState,
                    player: player,
                    depth: 4,
                    gameEngine: gameEngine
                )
                bestPosition = evaluation.move ?? availableMoves.randomElement() ?? availableMoves[0]
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

        var bestMove: BoardPosition?
        var confidence: Double = 0.5
        var nodesEvaluated = 1

        switch difficulty {
        case .easy:
            let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
            bestMove = availableMoves.randomElement()
            confidence = 0.3

        case .medium:
            let evaluation = await minimaxSearch(
                gameState: gameState,
                player: player,
                depth: difficulty.searchDepth,
                gameEngine: gameEngine
            )
            bestMove = evaluation.move
            confidence = 0.7
            nodesEvaluated = evaluation.nodesEvaluated

        case .hard:
            let evaluation = await alphaBetaEngine.calculateBestMove(
                gameState: gameState,
                player: player,
                depth: difficulty.searchDepth,
                gameEngine: gameEngine
            )
            bestMove = evaluation.move
            confidence = 0.9
            nodesEvaluated = evaluation.nodesEvaluated
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
            principalVariation: []
        )
    }

    func getMoveRecommendations(
        for gameState: GameState,
        player: Player,
        difficulty: AIDifficulty,
        using gameEngine: GameEngineProtocol
    ) async -> [MoveRecommendation] {
        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)

        var recommendations: [MoveRecommendation] = []

        for position in availableMoves {
            let move = Move(position: position, player: player)
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

        return recommendations.sorted { $0.evaluation > $1.evaluation }
    }

    func cancelCalculation() {
        calculationTask?.cancel()
        calculationTask = nil
    }

    // MARK: - Easy AI Implementation

    private func calculateEasyMove(
        availableMoves: [BoardPosition],
        gameState: GameState,
        player: Player,
        gameEngine: GameEngineProtocol
    ) async -> BoardPosition {
        // Easy AI: Random with slight corner preference
        let cornerMoves = availableMoves.filter { isCorner($0) }

        if !cornerMoves.isEmpty && Bool.random() {
            return cornerMoves.randomElement()!
        } else {
            return availableMoves.randomElement()!
        }
    }

    // MARK: - Medium AI Implementation

    private func calculateMediumMove(
        availableMoves: [BoardPosition],
        gameState: GameState,
        player: Player,
        gameEngine: GameEngineProtocol
    ) async -> BoardPosition {
        // Medium AI: Basic minimax algorithm
        let evaluation = await minimaxSearch(
            gameState: gameState,
            player: player,
            depth: AIDifficulty.medium.searchDepth,
            gameEngine: gameEngine
        )

        return evaluation.move ?? availableMoves.first!
    }

    // MARK: - Minimax Algorithm

    private func minimaxSearch(
        gameState: GameState,
        player: Player,
        depth: Int,
        gameEngine: GameEngineProtocol
    ) async -> MoveEvaluation {

        let availableMoves = gameEngine.availableMoves(for: player, in: gameState)
        guard !availableMoves.isEmpty else {
            return MoveEvaluation(move: nil, score: -Double.infinity, nodesEvaluated: 1)
        }

        var bestMove: BoardPosition?
        var bestScore = -Double.infinity
        var totalNodes = 0

        for position in availableMoves {
            guard !Task.isCancelled else { break }

            let move = Move(position: position, player: player)
            guard let result = gameEngine.applyMove(move, to: gameState) else { continue }

            let evaluation = await minimaxRecursive(
                gameState: result.newGameState,
                depth: depth - 1,
                maximizingPlayer: false,
                targetPlayer: player,
                gameEngine: gameEngine
            )

            totalNodes += evaluation.nodesEvaluated + 1
            let score = evaluation.score

            if score > bestScore {
                bestScore = score
                bestMove = position
            }
        }

        return MoveEvaluation(move: bestMove, score: bestScore, nodesEvaluated: totalNodes)
    }

    private func minimaxRecursive(
        gameState: GameState,
        depth: Int,
        maximizingPlayer: Bool,
        targetPlayer: Player,
        gameEngine: GameEngineProtocol
    ) async -> MoveEvaluation {

        // Base case
        if depth == 0 || gameEngine.isGameOver(gameState) {
            let score = gameEngine.evaluatePosition(gameState, for: targetPlayer)
            return MoveEvaluation(move: nil, score: score, nodesEvaluated: 1)
        }

        let currentPlayer = gameState.currentPlayer
        let availableMoves = gameEngine.availableMoves(for: currentPlayer, in: gameState)

        if availableMoves.isEmpty {
            let nextState = gameEngine.nextTurn(from: gameState)
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
            let evaluation = await minimaxRecursive(
                gameState: nextState,
                depth: depth - 1,
                maximizingPlayer: !maximizingPlayer,
                targetPlayer: targetPlayer,
                gameEngine: gameEngine
            )

            totalNodes += evaluation.nodesEvaluated + 1
            let score = evaluation.score

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

        return MoveEvaluation(move: bestMove, score: bestScore, nodesEvaluated: totalNodes)
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
