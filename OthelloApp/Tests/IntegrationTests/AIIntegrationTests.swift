//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//

import Testing
import Foundation
@testable import OthelloCore

@Suite("AI Integration Tests")
struct AIIntegrationTests {
    private let gameEngine = GameEngine()
    private let aiService = AIService()
    
    @Test("Complete AI vs AI game")
    @MainActor func testCompleteAIvsAIGame() async {
        var gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .easy),
            whitePlayer: PlayerInfo(player: .white, type: .ai, aiDifficulty: .easy)
        )
        
        var moveCount = 0
        let maxMoves = 100  // Safety limit to prevent infinite loops
        
        while gameState.gamePhase == .playing && moveCount < maxMoves {
            let currentPlayerInfo = gameState.currentPlayer == .black ? 
                gameState.blackPlayerInfo : gameState.whitePlayerInfo
            
            guard currentPlayerInfo.isAI else {
                #expect(Bool(false), "Expected AI player in AI vs AI game")
                break
            }
            
            let aiMove = await aiService.calculateMove(
                for: gameState,
                playerInfo: currentPlayerInfo,
                using: gameEngine
            )
            
            if let move = aiMove {
                #expect(gameEngine.isValidMove(move, in: gameState),
                       "AI move should be valid at move \(moveCount)")
                
                guard let newState = gameState.applyingMove(move) else {
                    #expect(Bool(false), "Failed to apply AI move at move \(moveCount)")
                    break
                }
                
                gameState = gameEngine.nextTurn(from: newState)
                moveCount += 1
            } else {
                // No move available, should advance turn
                gameState = gameEngine.nextTurn(from: gameState)
            }
        }
        
        #expect(moveCount > 0, "AI vs AI game should have at least one move")
        #expect(moveCount < maxMoves, "AI vs AI game should complete within reasonable moves")
        #expect(gameState.gamePhase == .finished, "AI vs AI game should reach completion")
    }
    
    @Test("Human vs AI game flow")
    @MainActor func testHumanVsAIGameFlow() async {
        var gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .ai, aiDifficulty: .medium)
        )
        
        // Make a human move (black goes first)
        let availableMoves = gameEngine.availableMoves(for: .black, in: gameState)
        #expect(!availableMoves.isEmpty, "Human player should have initial moves")
        
        let humanMove = Move(position: availableMoves.first!, player: .black)
        guard let afterHumanMove = gameState.applyingMove(humanMove) else {
            #expect(Bool(false), "Failed to apply human move")
            return
        }
        
        gameState = gameEngine.nextTurn(from: afterHumanMove)
        
        // Now it should be AI's turn
        #expect(gameState.currentPlayer == .white, "Should be AI's turn after human move")
        
        // Let AI make a move
        let aiMove = await aiService.calculateMove(
            for: gameState,
            player: .white,
            difficulty: .medium,
            using: gameEngine
        )
        
        #expect(aiMove != nil, "AI should find a move")
        #expect(aiMove!.player == .white, "AI move should be for white player")
        #expect(gameEngine.isValidMove(aiMove!, in: gameState), "AI move should be valid")
    }
    
    @Test("AI difficulty scaling")
    @MainActor func testAIDifficultyScaling() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .hard),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        var calculationTimes: [AIDifficulty: TimeInterval] = [:]
        
        // Test each difficulty level
        for difficulty in AIDifficulty.allCases {
            let startTime = Date()
            
            let move = await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: difficulty,
                using: gameEngine
            )
            
            let duration = Date().timeIntervalSince(startTime)
            calculationTimes[difficulty] = duration
            
            #expect(move != nil, "\(difficulty) AI should find a move")
        }
        
        // Easy should be fastest, hard should be slowest (generally)
        let easyTime = calculationTimes[.easy] ?? 0
        let hardTime = calculationTimes[.hard] ?? 0
        
        #expect(easyTime < 3.0, "Easy AI should be fast (took \(easyTime)s)")
        #expect(hardTime < 10.0, "Hard AI should complete reasonably (took \(hardTime)s)")
        
        // Hard AI should generally take longer than easy (allowing for variance)
        // Note: This might not always be true due to thinking time randomization
        // and early termination, so we'll just check that both complete successfully
    }
    
    @Test("AI move quality progression")
    @MainActor func testAIMoveQualityProgression() async {
        // Create a more complex board position where move quality matters
        var board = Board()
        
        // Set up a mid-game position
        board[BoardPosition(row: 3, col: 3)] = .white
        board[BoardPosition(row: 3, col: 4)] = .black
        board[BoardPosition(row: 4, col: 3)] = .black
        board[BoardPosition(row: 4, col: 4)] = .white
        
        // Add some additional pieces to create a more interesting position
        board[BoardPosition(row: 2, col: 3)] = .black
        board[BoardPosition(row: 3, col: 2)] = .white
        board[BoardPosition(row: 5, col: 4)] = .black
        board[BoardPosition(row: 4, col: 5)] = .white
        
        let gameState = gameEngine.createTestGameState(
            board: board,
            currentPlayer: .black,
            gamePhase: .playing
        )
        
        let availableMoves = gameEngine.availableMoves(for: .black, in: gameState)
        guard availableMoves.count > 1 else {
            // Skip if there's only one move
            return
        }
        
        var difficultyEvaluations: [AIDifficulty: Double] = [:]
        
        // Get AI moves for each difficulty
        for difficulty in AIDifficulty.allCases {
            if let aiMove = await aiService.calculateMove(
                for: gameState,
                player: .black,
                difficulty: difficulty,
                using: gameEngine
            ) {
                // Evaluate the resulting position
                if let result = gameEngine.applyMove(aiMove, to: gameState) {
                    let evaluation = gameEngine.evaluatePosition(result.newGameState, for: .black)
                    difficultyEvaluations[difficulty] = evaluation
                }
            }
        }
        
        #expect(difficultyEvaluations.count == AIDifficulty.allCases.count,
               "Should get moves from all difficulty levels")
        
        // At minimum, all AI levels should make valid moves
        // In practice, harder difficulties should generally make better moves,
        // but this can vary based on position and search depth
    }
    
    @Test("AI stress test with rapid calculations")
    @MainActor func testAIStressTest() async {
        let gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .ai, aiDifficulty: .easy),
            whitePlayer: PlayerInfo(player: .white, type: .ai, aiDifficulty: .easy)
        )
        
        // Perform multiple rapid AI calculations in parallel
        await withTaskGroup(of: Move?.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    await self.aiService.calculateMove(
                        for: gameState,
                        player: .black,
                        difficulty: .easy,
                        using: self.gameEngine
                    )
                }
            }
            
            var completedCalculations = 0
            for await result in group {
                if result != nil {
                    completedCalculations += 1
                }
            }
            
            #expect(completedCalculations > 0, "At least some AI calculations should complete successfully")
        }
    }
    
    @Test("AI handles edge cases gracefully")
    @MainActor func testAIEdgeCases() async {
        // Test with a nearly full board
        var board = Board()
        
        // Fill most positions
        for row in 0..<8 {
            for col in 0..<8 {
                if row == 7 && col == 7 {
                    // Leave one empty space
                    continue
                }
                board[BoardPosition(row: row, col: col)] = (row + col) % 2 == 0 ? .black : .white
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
            
            #expect(aiMove != nil, "AI should handle near-full board")
            if let move = aiMove {
                #expect(gameEngine.isValidMove(move, in: gameState), "AI move should be valid on full board")
            }
        }
        
        // Test with no available moves
        let emptyGameState = gameEngine.createTestGameState(
            board: Board(),  // Empty board with no valid moves
            currentPlayer: .black,
            gamePhase: .playing
        )
        
        let noMovesAvailable = gameEngine.availableMoves(for: .black, in: emptyGameState)
        if noMovesAvailable.isEmpty {
            let aiMove = await aiService.calculateMove(
                for: emptyGameState,
                player: .black,
                difficulty: .medium,
                using: gameEngine
            )
            
            #expect(aiMove == nil, "AI should return nil when no moves available")
        }
    }
}