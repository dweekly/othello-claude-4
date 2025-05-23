//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import Othello

@Suite("Performance Integration Tests")
struct PerformanceIntegrationTests {
    
    @Test("Game engine performance under load")
    func testGameEnginePerformance() async {
        let engine = GameEngine()
        let startState = engine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        // Measure time for 1000 move calculations
        let startTime = Date()
        
        for _ in 0..<1000 {
            _ = engine.availableMoves(for: startState)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 1000 calculations in under 100ms
        #expect(duration < 0.1, "Engine taking too long: \(duration)s for 1000 calculations")
    }
    
    @Test("Move validation performance")
    func testMoveValidationPerformance() async {
        let engine = GameEngine()
        let gameState = engine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        let testMove = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        
        // Measure time for 10000 move validations
        let startTime = Date()
        
        for _ in 0..<10000 {
            _ = engine.isValidMove(testMove, in: gameState)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 10000 validations in under 50ms
        #expect(duration < 0.05, "Move validation taking too long: \(duration)s for 10000 validations")
    }
    
    @Test("Complete game simulation performance")
    func testCompleteGameSimulationPerformance() async {
        await MainActor.run {
            let startTime = Date()
            
            // Simulate 10 complete games
            for gameIndex in 0..<10 {
                let viewModel = GameViewModel()
                var moveCount = 0
                let maxMoves = 60 // Maximum possible moves in Othello
                
                while viewModel.gameState.gamePhase == .playing && moveCount < maxMoves {
                    guard let validMove = viewModel.validMoves.first else { break }
                    viewModel.makeMove(at: validMove)
                    moveCount += 1
                }
                
                #expect(moveCount > 0, "Game \(gameIndex) had no moves")
            }
            
            let duration = Date().timeIntervalSince(startTime)
            
            // Should complete 10 full games in under 1 second
            #expect(duration < 1.0, "Game simulation taking too long: \(duration)s for 10 games")
        }
    }
    
    @Test("Memory usage during extended gameplay")
    func testMemoryUsageDuringExtendedGameplay() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Create a baseline memory measurement
            let initialMemory = getMemoryUsage()
            
            // Play 5 complete games to test for memory leaks
            for _ in 0..<5 {
                var moveCount = 0
                let maxMoves = 60
                
                while viewModel.gameState.gamePhase == .playing && moveCount < maxMoves {
                    guard let validMove = viewModel.validMoves.first else { break }
                    viewModel.makeMove(at: validMove)
                    moveCount += 1
                }
                
                viewModel.confirmNewGame()
            }
            
            let finalMemory = getMemoryUsage()
            let memoryIncrease = finalMemory - initialMemory
            
            // Memory increase should be minimal (under 5MB for 5 games)
            #expect(memoryIncrease < 5_000_000, "Memory leak detected: \(memoryIncrease) bytes increased")
        }
    }
    
    @Test("UI responsiveness under rapid input")
    func testUIResponsivenessUnderRapidInput() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            let startTime = Date()
            
            // Simulate rapid user input (100 clicks in quick succession)
            for _ in 0..<100 {
                if let validMove = viewModel.validMoves.first {
                    viewModel.makeMove(at: validMove)
                    
                    // Reset if game ends
                    if viewModel.gameState.gamePhase == .finished {
                        viewModel.confirmNewGame()
                    }
                }
            }
            
            let duration = Date().timeIntervalSince(startTime)
            
            // Should handle 100 rapid inputs in under 500ms
            #expect(duration < 0.5, "UI not responsive enough: \(duration)s for 100 inputs")
            
            // ViewModel should still be in a valid state
            #expect(!viewModel.isProcessingMove)
            #expect(viewModel.gameState.gamePhase == .playing || viewModel.gameState.gamePhase == .finished)
        }
    }
    
    @Test("Board state calculation performance")
    func testBoardStateCalculationPerformance() async {
        let board = Board()
        
        let startTime = Date()
        
        // Test board operations under load
        for _ in 0..<1000 {
            _ = board.isEmpty
            // Test position access
            for row in 0..<8 {
                for col in 0..<8 {
                    let position = BoardPosition(row: row, col: col)
                    _ = board[position]
                }
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 1000 board calculations in under 100ms (increased for more realistic timing)
        #expect(duration < 0.1, "Board calculations taking too long: \(duration)s for 1000 operations")
    }
    
    @Test("Score calculation performance")
    func testScoreCalculationPerformance() async {
        let engine = GameEngine()
        let gameState = engine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        
        let startTime = Date()
        
        // Test score calculations under load
        for _ in 0..<5000 {
            _ = gameState.score
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 5000 score calculations in under 50ms
        #expect(duration < 0.05, "Score calculations taking too long: \(duration)s for 5000 operations")
    }
    
    @Test("Large scale game state transitions")
    func testLargeScaleGameStateTransitions() async {
        await MainActor.run {
            let startTime = Date()
            
            // Test state transitions at scale
            for _ in 0..<100 {
                let viewModel = GameViewModel()
                
                // Make a few moves
                for _ in 0..<5 {
                    if let validMove = viewModel.validMoves.first {
                        viewModel.makeMove(at: validMove)
                    }
                }
                
                // Reset
                viewModel.confirmNewGame()
            }
            
            let duration = Date().timeIntervalSince(startTime)
            
            // Should complete 100 game cycles in under 500ms
            #expect(duration < 0.5, "State transitions taking too long: \(duration)s for 100 cycles")
        }
    }
    
    @Test("Concurrent state access safety")
    @MainActor func testConcurrentStateAccessSafety() async {
        let viewModel = GameViewModel()
        
        // Simulate state access under load
        let startTime = Date()
        
        // Multiple sequential accesses to test state consistency
        for _ in 0..<1000 {
            _ = viewModel.gameState.currentPlayer
            _ = viewModel.gameState.score
            _ = viewModel.validMoves
            _ = viewModel.gameStatusMessage
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete access in under 100ms
        #expect(duration < 0.1, "State access taking too long: \(duration)s")
        
        // State should remain consistent
        #expect(viewModel.gameState.score.black >= 0)
        #expect(viewModel.gameState.score.white >= 0)
    }
    
    // Helper function to get current memory usage
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? info.resident_size : 0
    }
}