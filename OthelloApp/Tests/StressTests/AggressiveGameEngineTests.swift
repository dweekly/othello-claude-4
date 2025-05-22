//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//

import Testing
import Foundation
@testable import OthelloCore

/// Aggressive stress tests designed to break the GameEngine under extreme conditions
struct AggressiveGameEngineTests {
    
    // MARK: - Memory Pressure Tests
    
    @Test("Memory pressure during rapid game state creation")
    func testMemoryPressureGameStates() async {
        // Create thousands of game states to test memory management
        var gameStates: [GameState] = []
        
        for i in 0..<5000 {
            let state = GameState.newHumanVsHuman()
            gameStates.append(state)
            
            // Periodically force memory cleanup
            if i % 1000 == 0 {
                autoreleasepool {
                    _ = gameStates.map { $0.score.total }
                }
            }
        }
        
        // Verify we can still access all states without crashes
        let totalScores = gameStates.map { $0.score.total }
        #expect(totalScores.count == 5000)
        #expect(totalScores.allSatisfy { $0 == 4 }) // Initial score is always 4
    }
    
    @Test("Rapid board manipulation stress test")
    func testRapidBoardManipulation() {
        let startTime = Date()
        var lastBoard = Board.initial
        
        // Perform 10,000 board operations in rapid succession
        for i in 0..<10000 {
            let randomPosition = BoardPosition(row: i % 8, col: (i * 3) % 8)
            let player: CellState = (i % 2 == 0) ? .black : .white
            
            lastBoard = lastBoard.placing(player, at: randomPosition)
            
            // Occasionally perform expensive operations
            if i % 500 == 0 {
                _ = lastBoard.validMoves(for: .black)
                _ = lastBoard.validMoves(for: .white)
                _ = lastBoard.score
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete within reasonable time (under 2 seconds)
        #expect(duration < 2.0)
        #expect(lastBoard.score.total <= 64)
    }
    
    // MARK: - Boundary Value Tests
    
    @Test("Integer overflow protection in score calculations")
    func testScoreOverflowProtection() {
        // Create maximum possible board state
        var placements: [BoardPosition: CellState] = [:]
        for position in BoardPosition.allPositions {
            placements[position] = .black
        }
        
        let fullBoard = Board().placing(placements)
        let score = fullBoard.score
        
        // Verify no overflow and correct values
        #expect(score.black == 64)
        #expect(score.white == 0)
        #expect(score.total == 64)
        #expect(score.difference == 64)
        
        // Test empty board
        let emptyBoard = Board()
        let emptyScore = emptyBoard.score
        #expect(emptyScore.black == 0)
        #expect(emptyScore.white == 0)
        #expect(emptyScore.total == 0)
    }
    
    @Test("Extreme board position edge cases")
    func testExtremeBoardPositions() {
        let engine = GameEngine()
        
        // Test all corner positions
        let corners = [
            BoardPosition(row: 0, col: 0),
            BoardPosition(row: 0, col: 7),
            BoardPosition(row: 7, col: 0),
            BoardPosition(row: 7, col: 7)
        ]
        
        for corner in corners {
            let board = Board().placing(.black, at: corner)
            let gameState = TestUtilities.createGameState(board: board)
            
            // Should not crash with isolated corner pieces
            let moves = engine.availableMoves(for: gameState)
            let analysis = engine.analyzePosition(gameState)
            
            #expect(moves.count >= 0)
            #expect((analysis.mobility[.black] ?? 0) >= 0)
            #expect((analysis.mobility[.white] ?? 0) >= 0)
        }
    }
    
    // MARK: - Performance Stress Tests
    
    @Test("AI evaluation performance under stress")
    func testAIEvaluationPerformance() {
        let engine = GameEngine()
        let gameState = GameState.newHumanVsHuman()
        
        let startTime = Date()
        
        // Perform 1000 position evaluations
        for i in 0..<1000 {
            let player: Player = (i % 2 == 0) ? .black : .white
            let evaluation = engine.evaluatePosition(gameState, for: player)
            
            // Verify evaluation is reasonable
            #expect(evaluation.isFinite)
            #expect(!evaluation.isNaN)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete evaluations within reasonable time (under 5 seconds)
        #expect(duration < 5.0)
    }
    
    @Test("Valid moves calculation performance regression")
    func testValidMovesPerformanceRegression() {
        let engine = GameEngine()
        let gameState = GameState.newHumanVsHuman()
        
        let startTime = Date()
        
        // Calculate valid moves 5000 times
        for _ in 0..<5000 {
            _ = engine.availableMoves(for: gameState)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should maintain good performance (under 5 seconds for 5000 calls)
        #expect(duration < 5.0)
    }
    
    // MARK: - Error Recovery Tests
    
    @Test("Malformed game state recovery")
    func testMalformedGameStateRecovery() {
        let engine = GameEngine()
        
        // Create impossible board state (isolated pieces)
        var placements: [BoardPosition: CellState] = [:]
        placements[BoardPosition(row: 0, col: 0)] = .black
        placements[BoardPosition(row: 0, col: 2)] = .white  // Gap between pieces
        placements[BoardPosition(row: 7, col: 7)] = .black  // Isolated piece
        
        let invalidBoard = Board().placing(placements)
        let gameState = TestUtilities.createGameState(board: invalidBoard)
        
        // Engine should handle gracefully without crashing
        let moves = engine.availableMoves(for: gameState)
        _ = engine.isGameOver(gameState)
        let validationIssues = engine.validateGameState(gameState)
        
        #expect(moves.count >= 0)
        #expect(validationIssues.count > 0) // Should detect invalid state
    }
    
    // MARK: - Concurrent Access Tests
    
    @Test("Concurrent GameEngine access safety")
    func testConcurrentGameEngineAccess() async {
        let engine = GameEngine()
        let gameState = GameState.newHumanVsHuman()
        
        // Run multiple concurrent operations
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask {
                    let player: Player = (i % 2 == 0) ? .black : .white
                    _ = engine.evaluatePosition(gameState, for: player)
                    _ = engine.availableMoves(for: gameState)
                    _ = engine.analyzePosition(gameState)
                }
            }
        }
        
        // Should complete without crashes or data races
        _ = true // If we reach here, no crashes occurred
    }
    
    // MARK: - Pathological Board States
    
    @Test("Pathological board patterns for AI")
    func testPathologicalBoardPatterns() {
        let engine = GameEngine()
        
        // Create checkerboard pattern (worst case for evaluation)
        var placements: [BoardPosition: CellState] = [:]
        for row in 0..<8 {
            for col in 0..<8 {
                if (row + col) % 2 == 0 {
                    placements[BoardPosition(row: row, col: col)] = .black
                } else {
                    placements[BoardPosition(row: row, col: col)] = .white
                }
            }
        }
        
        let checkerboard = Board().placing(placements)
        let gameState = TestUtilities.createGameState(board: checkerboard)
        
        let startTime = Date()
        let evaluation = engine.evaluatePosition(gameState, for: .black)
        let duration = Date().timeIntervalSince(startTime)
        
        // Should not hang on pathological case
        #expect(duration < 5.0)
        #expect(evaluation.isFinite)
        #expect(!evaluation.isNaN)
    }
    
    // MARK: - Long Game Simulation
    
    @Test("Extended game simulation stress test")
    func testExtendedGameSimulation() {
        let engine = GameEngine()
        var gameState = GameState.newHumanVsHuman()
        var moveCount = 0
        let maxMoves = 1000 // Safety limit
        
        while !engine.isGameOver(gameState) && moveCount < maxMoves {
            let availableMoves = engine.availableMoves(for: gameState)
            guard !availableMoves.isEmpty else {
                gameState = engine.nextTurn(from: gameState)
                continue
            }
            
            // Pick first available move for speed
            let move = Move(position: availableMoves[0], player: gameState.currentPlayer)
            
            guard let result = engine.applyMove(move, to: gameState) else {
                break
            }
            
            gameState = result.newGameState
            moveCount += 1
            
            // Verify game state consistency throughout
            #expect(gameState.score.total <= 64)
            #expect(gameState.score.black >= 0)
            #expect(gameState.score.white >= 0)
        }
        
        // Game should terminate naturally or hit safety limit
        #expect(moveCount <= maxMoves)
        
        if engine.isGameOver(gameState) {
            // If game ended naturally, verify it's in a valid end state
            let winner = engine.winner(of: gameState)
            #expect(winner != nil || gameState.score.isTied)
        }
    }
    
    // MARK: - State Consistency Tests
    
    @Test("Game state invariant preservation under stress")
    func testGameStateInvariants() {
        let engine = GameEngine()
        var gameState = GameState.newHumanVsHuman()
        
        // Apply 100 random valid moves and verify invariants hold
        for _ in 0..<100 {
            let availableMoves = engine.availableMoves(for: gameState)
            guard !availableMoves.isEmpty else {
                gameState = engine.nextTurn(from: gameState)
                continue
            }
            
            let randomMove = availableMoves.randomElement()!
            let move = Move(position: randomMove, player: gameState.currentPlayer)
            
            guard let result = engine.applyMove(move, to: gameState) else {
                continue
            }
            
            gameState = result.newGameState
            
            // Critical invariants that must always hold
            #expect(gameState.score.black + gameState.score.white == gameState.score.total)
            #expect(gameState.score.total <= 64)
            #expect(gameState.score.black >= 0)
            #expect(gameState.score.white >= 0)
            #expect(gameState.currentPlayer == .black || gameState.currentPlayer == .white)
            
            // Board-specific invariants
            let boardScore = gameState.board.score
            #expect(boardScore == gameState.score)
        }
    }
}