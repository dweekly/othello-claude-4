//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import OthelloCore
@testable import OthelloUI

@Suite("Game Flow Integration Tests")
struct GameFlowIntegrationTests {
    
    @Test("Complete game flow from ViewModel to Engine")
    func testCompleteGameFlow() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let engine = GameEngine()
            
            // Track game progression
            var moveCount = 0
            let maxMoves = 10 // Limit to prevent infinite loops
            
            // Play several moves
            while viewModel.gameState.gamePhase == .playing && moveCount < maxMoves {
                let validMoves = viewModel.validMoves
                guard let movePosition = validMoves.first else { break }
                
                let initialScore = viewModel.gameState.score
                let initialPlayer = viewModel.gameState.currentPlayer
                
                // Make the move
                viewModel.makeMove(at: movePosition)
                
                // Verify the move was applied correctly
                let newScore = viewModel.gameState.score
                #expect(newScore.black + newScore.white >= initialScore.black + initialScore.white)
                
                // Verify player switched (unless game ended)
                if viewModel.gameState.gamePhase == .playing {
                    #expect(viewModel.gameState.currentPlayer != initialPlayer)
                }
                
                moveCount += 1
            }
            
            // Verify we made progress
            #expect(moveCount > 0)
            #expect(viewModel.gameState.score.black + viewModel.gameState.score.white > 4)
        }
    }
    
    @Test("ViewModel-Engine state consistency")
    func testViewModelEngineConsistency() async {
        await MainActor.run {
            let engine = GameEngine()
            let viewModel = GameViewModel(gameEngine: engine)
            
            // Verify ViewModel's valid moves match Engine's calculation
            let viewModelMoves = Set(viewModel.validMoves)
            let engineMoves = Set(engine.availableMoves(for: viewModel.gameState))
            
            #expect(viewModelMoves == engineMoves)
            
            // Make a move and verify consistency is maintained
            if let movePosition = viewModelMoves.first {
                viewModel.makeMove(at: movePosition)
                
                let newViewModelMoves = Set(viewModel.validMoves)
                let newEngineMoves = Set(engine.availableMoves(for: viewModel.gameState))
                
                #expect(newViewModelMoves == newEngineMoves)
            }
        }
    }
    
    @Test("Error handling in complete game flow")
    func testErrorHandlingInGameFlow() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Attempt invalid moves and verify state remains consistent
            let invalidPositions = [
                BoardPosition(row: 0, col: 0), // Corner
                BoardPosition(row: 3, col: 3), // Occupied center
                BoardPosition(row: 4, col: 4), // Occupied center
                BoardPosition(row: 8, col: 8)  // Out of bounds (should be caught by BoardPosition validation)
            ]
            
            let initialState = viewModel.gameState
            let initialValidMoves = viewModel.validMoves
            
            for invalidPosition in invalidPositions {
                if invalidPosition.isValid { // Only test valid positions that are invalid moves
                    viewModel.makeMove(at: invalidPosition)
                }
            }
            
            // Verify state unchanged after invalid attempts
            #expect(viewModel.gameState.currentPlayer == initialState.currentPlayer)
            #expect(viewModel.gameState.score.black == initialState.score.black)
            #expect(viewModel.gameState.score.white == initialState.score.white)
            #expect(Set(viewModel.validMoves) == Set(initialValidMoves))
        }
    }
    
    @Test("Game reset preserves engine functionality")
    func testGameResetEngineConsistency() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Play some moves
            for _ in 0..<3 {
                if let validMove = viewModel.validMoves.first {
                    viewModel.makeMove(at: validMove)
                }
            }
            
            // Reset the game
            viewModel.confirmNewGame()
            
            // Verify we're back to a valid initial state
            #expect(viewModel.gameState.currentPlayer == .black)
            #expect(viewModel.gameState.gamePhase == .playing)
            #expect(viewModel.validMoves.count == 4) // Standard Othello opening
            
            // Verify we can still make moves
            let validMove = viewModel.validMoves.first!
            let initialScore = viewModel.gameState.score
            viewModel.makeMove(at: validMove)
            
            #expect(viewModel.gameState.score.black + viewModel.gameState.score.white > 
                   initialScore.black + initialScore.white)
        }
    }
    
    @Test("Concurrent move attempts are handled safely")
    func testConcurrentMoveAttempts() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let validMove = viewModel.validMoves.first!
            
            // Simulate rapid multiple taps on the same cell
            let initialState = viewModel.gameState
            
            viewModel.makeMove(at: validMove)
            viewModel.makeMove(at: validMove) // Second attempt should be ignored
            viewModel.makeMove(at: validMove) // Third attempt should be ignored
            
            // Should only have processed one move
            #expect(viewModel.gameState.currentPlayer != initialState.currentPlayer)
            
            // The position should no longer be valid for any player
            #expect(!viewModel.validMoves.contains(validMove))
        }
    }
    
    @Test("Game state transitions follow Othello rules")
    func testGameStateTransitions() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Track score progression to ensure it follows Othello rules
            var previousTotal = viewModel.gameState.score.black + viewModel.gameState.score.white
            
            for _ in 0..<5 {
                guard let validMove = viewModel.validMoves.first else { break }
                
                viewModel.makeMove(at: validMove)
                
                let currentTotal = viewModel.gameState.score.black + viewModel.gameState.score.white
                
                // Total pieces should increase by at least 1 (the placed piece)
                #expect(currentTotal >= previousTotal + 1)
                
                previousTotal = currentTotal
            }
            
            // Verify no invalid board states were created
            let finalState = viewModel.gameState
            #expect(finalState.score.black >= 0)
            #expect(finalState.score.white >= 0)
            #expect(finalState.score.black + finalState.score.white <= 64)
        }
    }
    
    @Test("ViewModel handles edge cases gracefully")
    func testViewModelEdgeCases() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Test with empty valid moves scenario (shouldn't happen in normal gameplay)
            let reflection = Mirror(reflecting: viewModel)
            
            // Verify ViewModel doesn't crash with edge cases
            let statusMessage = viewModel.gameStatusMessage
            #expect(!statusMessage.isEmpty)
            
            let playerName = viewModel.currentPlayerName
            #expect(playerName == "Black" || playerName == "White")
            
            // Test reset multiple times
            for _ in 0..<3 {
                viewModel.confirmNewGame()
                #expect(viewModel.gameState.currentPlayer == .black)
                #expect(!viewModel.isProcessingMove)
            }
        }
    }
    
    @Test("Valid moves calculation performance")
    func testValidMovesPerformance() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Measure time for valid moves calculation
            let startTime = Date()
            
            for _ in 0..<100 {
                _ = viewModel.validMoves
            }
            
            let duration = Date().timeIntervalSince(startTime)
            
            // Valid moves calculation should be fast (under 1 second for 100 calls)
            #expect(duration < 1.0)
        }
    }
}