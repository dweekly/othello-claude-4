//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//

import Testing
import Foundation
@testable import OthelloCore

@Suite("AI Service Tests")
struct AIServiceTests {
    private let gameEngine = GameEngine()
    private let aiService = AIService()
    
    @Test("AI service calculates moves for all difficulty levels")
    @MainActor func testCalculateMovesAllDifficulties() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .ai, aiDifficulty: .medium)
        )
        
        for difficulty in AIDifficulty.allCases {
            let move = await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: difficulty,
                using: gameEngine
            )
            
            #expect(move != nil, "AI should calculate a move for \(difficulty) difficulty")
            
            if let move = move {
                #expect(gameEngine.isValidMove(move, in: gameState), 
                       "AI move should be valid for \(difficulty) difficulty")
            }
        }
    }
    
    @Test("AI service performance benchmarks")
    @MainActor func testAIPerformanceBenchmarks() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .hard),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        // Easy AI should be very fast
        let easyStartTime = Date()
        let easyMove = await aiService.calculateMove(
            for: gameState,
            player: .black,
            difficulty: .easy,
            using: gameEngine
        )
        let easyDuration = Date().timeIntervalSince(easyStartTime)
        
        #expect(easyMove != nil, "Easy AI should find a move")
        #expect(easyDuration < 2.0, "Easy AI should complete within 2 seconds, took \(easyDuration)s")
        
        // Medium AI should be reasonably fast
        let mediumStartTime = Date()
        let mediumMove = await aiService.calculateMove(
            for: gameState,
            player: .black,
            difficulty: .medium,
            using: gameEngine
        )
        let mediumDuration = Date().timeIntervalSince(mediumStartTime)
        
        #expect(mediumMove != nil, "Medium AI should find a move")
        #expect(mediumDuration < 5.0, "Medium AI should complete within 5 seconds, took \(mediumDuration)s")
        
        // Hard AI can take longer but should still be reasonable
        let hardStartTime = Date()
        let hardMove = await aiService.calculateMove(
            for: gameState,
            player: .black,
            difficulty: .hard,
            using: gameEngine
        )
        let hardDuration = Date().timeIntervalSince(hardStartTime)
        
        #expect(hardMove != nil, "Hard AI should find a move")
        #expect(hardDuration < 10.0, "Hard AI should complete within 10 seconds, took \(hardDuration)s")
    }
    
    @Test("AI analyzes positions correctly")
    @MainActor func testAIPositionAnalysis() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .hard),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        let analysis = await aiService.analyzePosition(
            gameState,
            for: .black,
            difficulty: .hard,
            using: gameEngine
        )
        
        #expect(analysis.searchDepth == AIDifficulty.hard.searchDepth,
               "Analysis should use correct search depth")
        #expect(analysis.confidence >= 0.0 && analysis.confidence <= 1.0,
               "Confidence should be between 0 and 1")
        #expect(analysis.nodesEvaluated > 0,
               "Should evaluate at least one node")
        #expect(analysis.calculationTimeMs >= 0,
               "Calculation time should be non-negative")
    }
    
    @Test("AI provides move recommendations")
    @MainActor func testAIMoveRecommendations() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .medium),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        let recommendations = await aiService.getMoveRecommendations(
            for: gameState,
            player: .black,
            difficulty: .medium,
            using: gameEngine
        )
        
        #expect(!recommendations.isEmpty, "Should provide move recommendations")
        
        let availableMoves = gameEngine.availableMoves(for: .black, in: gameState)
        #expect(recommendations.count == availableMoves.count,
               "Should have one recommendation per available move")
        
        for recommendation in recommendations {
            #expect(recommendation.confidence >= 0.0 && recommendation.confidence <= 1.0,
                   "Recommendation confidence should be between 0 and 1")
            #expect(!recommendation.reasoning.isEmpty,
                   "Recommendation should include reasoning")
        }
        
        // Recommendations should be sorted by evaluation (best first)
        for i in 0..<(recommendations.count - 1) {
            #expect(recommendations[i].evaluation >= recommendations[i + 1].evaluation,
                   "Recommendations should be sorted by evaluation score")
        }
    }
    
    @Test("AI cancellation works correctly")
    @MainActor func testAICancellation() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .hard),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        // Start a calculation
        let calculationTask = Task {
            await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: .hard,
                using: gameEngine
            )
        }
        
        // Cancel it immediately
        aiService.cancelCalculation()
        
        let result = await calculationTask.value
        
        // The result might be nil due to cancellation, which is acceptable
        #expect(!aiService.isCalculating, "AI should not be calculating after cancellation")
    }
    
    @Test("AI makes sensible moves compared to random")
    @MainActor func testAIMoveQuality() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .hard),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        let availableMoves = gameEngine.availableMoves(for: .black, in: gameState)
        guard availableMoves.count > 1 else {
            // Skip this test if there's only one move available
            return
        }
        
        // Get AI move
        let aiMove = await aiService.calculateMove(
            for: gameState,
            player: .black,
            difficulty: .hard,
            using: gameEngine
        )
        
        #expect(aiMove != nil, "Hard AI should find a move")
        
        if let aiMove = aiMove {
            // Apply AI move and evaluate position
            guard let aiResult = gameEngine.applyMove(aiMove, to: gameState) else {
                #expect(Bool(false), "AI move should be applicable")
                return
            }
            
            let aiEvaluation = gameEngine.evaluatePosition(aiResult.newGameState, for: .black)
            
            // Compare with a few random moves
            var randomEvaluations: [Double] = []
            
            for _ in 0..<3 {
                let randomPosition = availableMoves.randomElement()!
                let randomMove = Move(position: randomPosition, player: .black)
                
                if let randomResult = gameEngine.applyMove(randomMove, to: gameState) {
                    let randomEval = gameEngine.evaluatePosition(randomResult.newGameState, for: .black)
                    randomEvaluations.append(randomEval)
                }
            }
            
            let averageRandomEval = randomEvaluations.reduce(0, +) / Double(randomEvaluations.count)
            
            // AI should generally perform better than random (allowing some variance)
            #expect(aiEvaluation >= averageRandomEval - 20,
                   "Hard AI move should be competitive with random moves. AI: \(aiEvaluation), Random avg: \(averageRandomEval)")
        }
    }
    
    @Test("AI handles end-game scenarios")
    @MainActor func testAIEndGameScenarios() async {
        // Create a near-end-game scenario with limited moves
        var board = Board()
        
        // Fill most of the board with a pattern that leaves few moves
        for row in 0..<8 {
            for col in 0..<8 {
                if (row + col) % 2 == 0 {
                    board[BoardPosition(row: row, col: col)] = .black
                } else if row < 6 {  // Leave some empty spaces
                    board[BoardPosition(row: row, col: col)] = .white
                }
            }
        }
        
        let gameState = gameEngine.createTestGameState(
            board: board,
            currentPlayer: .black,
            gamePhase: .playing
        )
        
        let availableMoves = gameEngine.availableMoves(for: .black, in: gameState)
        
        if !availableMoves.isEmpty {
            let aiMove = await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: .medium,
                using: gameEngine
            )
            
            #expect(aiMove != nil, "AI should handle end-game scenarios")
            
            if let aiMove = aiMove {
                #expect(gameEngine.isValidMove(aiMove, in: gameState),
                       "AI end-game move should be valid")
            }
        }
    }
}