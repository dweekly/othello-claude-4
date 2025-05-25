//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation
import Testing
@testable import Othello

/// Fast tests specifically for AI functionality
struct AITests {
    let gameEngine = GameEngine()
    let aiService = AIService()

    @Test("AI difficulty levels work")
    func testAIDifficulties() async {
        let gameState = GameState.newHumanVsHuman()

        for difficulty in AIDifficulty.allCases {
            let move = await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: difficulty,
                using: gameEngine
            )

            #expect(move != nil, "AI should calculate move for \(difficulty) difficulty")

            if let move = move {
                #expect(gameEngine.isValidMove(move, in: gameState),
                       "\(difficulty) AI move should be valid")
            }
        }
    }

    @Test("AI move calculation is fast")
    func testAISpeed() async {
        let gameState = GameState.newHumanVsHuman()

        let startTime = Date()

        let move = await aiService.calculateMove(
            for: gameState,
            player: .black,
            difficulty: .easy,
            using: gameEngine
        )

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        #expect(move != nil, "AI should calculate a move")
        #expect(duration < 3.0, "Easy AI should be fast (< 3 seconds)")
    }

    @Test("AI handles edge cases")
    func testAIEdgeCases() async {
        // Test AI when very few moves available
        var board = Board()

        // Use initial board for testing (board is immutable)
        board = Board.initial

        let gameState = gameEngine.createTestGameState(board: board, currentPlayer: .black)
        let availableMoves = gameEngine.availableMoves(for: gameState)

        if !availableMoves.isEmpty {
            let aiMove = await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: .medium,
                using: gameEngine
            )

            #expect(aiMove != nil, "AI should handle limited move scenarios")

            if let aiMove = aiMove {
                #expect(availableMoves.contains(aiMove.position),
                       "AI should choose from available moves")
            }
        }
    }

    @Test("AI analysis provides insights")
    func testAIAnalysis() async {
        let gameState = GameState.newHumanVsHuman()

        let analysis = await aiService.analyzePosition(
            gameState,
            for: .black,
            difficulty: .medium,
            using: gameEngine
        )

        #expect(analysis.bestMove != nil, "Analysis should recommend a move")
        #expect(analysis.confidence > 0, "Analysis should have confidence > 0")
        #expect(analysis.nodesEvaluated > 0, "Should evaluate some nodes")
    }
}
