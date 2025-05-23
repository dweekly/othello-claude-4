//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import Othello

@Suite("End-to-End Integration Tests")
struct EndToEndIntegrationTests {
    
    @Test("Complete game from start to finish")
    @MainActor func testCompleteGameFromStartToFinish() async {
        let viewModel = GameViewModel()
        
        // Track game progression
        var turnHistory: [(Player, BoardPosition, Score)] = []
        var moveCount = 0
        let maxMoves = 60 // Maximum possible moves in Othello
        
        #expect(viewModel.gameState.currentPlayer == .black)
        #expect(viewModel.gameState.gamePhase == .playing)
        #expect(viewModel.validMoves.count == 4) // Standard opening
        
        // Play until game ends naturally or we hit move limit
        while viewModel.gameState.gamePhase == .playing && moveCount < maxMoves {
            let currentPlayer = viewModel.gameState.currentPlayer
            let validMoves = viewModel.validMoves
            
            guard let movePosition = validMoves.first else {
                // No valid moves - this should trigger a pass or game end
                break
            }
            
            let scoreBefore = viewModel.gameState.score
            
            // Make the move
            viewModel.makeMove(at: movePosition)
            
            let scoreAfter = viewModel.gameState.score
            turnHistory.append((currentPlayer, movePosition, scoreAfter))
            
            // Verify the move was valid and had effect
            let totalBefore = scoreBefore.black + scoreBefore.white
            let totalAfter = scoreAfter.black + scoreAfter.white
            #expect(totalAfter > totalBefore, "Move should increase total pieces")
            
            moveCount += 1
        }
        
        // Verify we made significant progress
        #expect(moveCount >= 4, "Should have made at least 4 moves")
        #expect(turnHistory.count == moveCount)
        
        // Verify final state is valid
        let finalScore = viewModel.gameState.score
        #expect(finalScore.black + finalScore.white >= 8) // More than initial 4 pieces
        #expect(finalScore.black + finalScore.white <= 64) // Can't exceed board size
        
        // If game finished, verify winner calculation makes sense
        if viewModel.gameState.gamePhase == .finished {
            let completionMessage = viewModel.gameCompletionMessage
            #expect(!completionMessage.isEmpty)
            
            if finalScore.black > finalScore.white {
                #expect(completionMessage.contains("Black"))
            } else if finalScore.white > finalScore.black {
                #expect(completionMessage.contains("White"))
            } else {
                #expect(completionMessage.contains("tie"))
            }
        }
    }
    
    @Test("Game reset functionality maintains integrity")
    @MainActor func testGameResetMaintainsIntegrity() async {
        let viewModel = GameViewModel()
        
        // Play several moves to modify state
        for _ in 0..<5 {
            if let validMove = viewModel.validMoves.first {
                viewModel.makeMove(at: validMove)
            }
        }
        
        let modifiedScore = viewModel.gameState.score
        #expect(modifiedScore.black + modifiedScore.white > 4)
        
        // Reset the game
        viewModel.confirmNewGame()
        
        // Verify complete reset to initial state
        #expect(viewModel.gameState.currentPlayer == .black)
        #expect(viewModel.gameState.gamePhase == .playing)
        #expect(viewModel.gameState.score.black == 2)
        #expect(viewModel.gameState.score.white == 2)
        #expect(viewModel.validMoves.count == 4)
        #expect(!viewModel.isProcessingMove)
        #expect(!viewModel.showingGameCompletionAlert)
        #expect(!viewModel.showingNewGameConfirmation)
        
        // Verify we can play normally after reset
        let validMove = viewModel.validMoves.first!
        let initialTotal = viewModel.gameState.score.black + viewModel.gameState.score.white
        
        viewModel.makeMove(at: validMove)
        
        let newTotal = viewModel.gameState.score.black + viewModel.gameState.score.white
        #expect(newTotal > initialTotal)
        #expect(viewModel.gameState.currentPlayer == .white)
    }
    
    @Test("Invalid move handling across entire system")
    @MainActor func testInvalidMoveHandlingAcrossSystem() async {
        let viewModel = GameViewModel()
        
        // Collect all invalid positions
        let allPositions = (0..<8).flatMap { row in
            (0..<8).map { col in BoardPosition(row: row, col: col) }
        }
        let validMoves = Set(viewModel.validMoves)
        let invalidPositions = allPositions.filter { !validMoves.contains($0) }
        
        let stateBefore = viewModel.gameState
        let validMovesBefore = Set(viewModel.validMoves)
        
        // Attempt all invalid moves
        for invalidPosition in invalidPositions {
            viewModel.makeMove(at: invalidPosition)
        }
        
        // Verify no state changes occurred
        #expect(viewModel.gameState.currentPlayer == stateBefore.currentPlayer)
        #expect(viewModel.gameState.score.black == stateBefore.score.black)
        #expect(viewModel.gameState.score.white == stateBefore.score.white)
        #expect(viewModel.gameState.gamePhase == stateBefore.gamePhase)
        #expect(Set(viewModel.validMoves) == validMovesBefore)
        #expect(!viewModel.isProcessingMove)
    }
    
    @Test("Score tracking accuracy throughout game")
    @MainActor func testScoreTrackingAccuracy() async {
        let viewModel = GameViewModel()
        
        var scoreHistory: [Score] = [viewModel.gameState.score]
        var moveCount = 0
        let maxMoves = 20
        
        while viewModel.gameState.gamePhase == .playing && moveCount < maxMoves {
            guard let validMove = viewModel.validMoves.first else { break }
            
            let scoreBefore = viewModel.gameState.score
            viewModel.makeMove(at: validMove)
            let scoreAfter = viewModel.gameState.score
            
            scoreHistory.append(scoreAfter)
            
            // Verify score consistency rules
            let totalBefore = scoreBefore.black + scoreBefore.white
            let totalAfter = scoreAfter.black + scoreAfter.white
            
            // Total should increase by at least 1 (the placed piece)
            #expect(totalAfter >= totalBefore + 1)
            
            // No player should lose all pieces
            #expect(scoreAfter.black > 0)
            #expect(scoreAfter.white > 0)
            
            // Total should never exceed board size
            #expect(totalAfter <= 64)
            
            moveCount += 1
        }
        
        // Verify score progression makes sense
        let firstScore = scoreHistory.first!
        let lastScore = scoreHistory.last!
        
        #expect(lastScore.black + lastScore.white > firstScore.black + firstScore.white)
        #expect(scoreHistory.count == moveCount + 1) // +1 for initial score
    }
    
    @Test("Player turn alternation integrity")
    @MainActor func testPlayerTurnAlternationIntegrity() async {
        let viewModel = GameViewModel()
        
        var playerSequence: [Player] = [viewModel.gameState.currentPlayer]
        var moveCount = 0
        let maxMoves = 10
        
        while viewModel.gameState.gamePhase == .playing && moveCount < maxMoves {
            guard let validMove = viewModel.validMoves.first else { break }
            
            let playerBefore = viewModel.gameState.currentPlayer
            viewModel.makeMove(at: validMove)
            
            if viewModel.gameState.gamePhase == .playing {
                let playerAfter = viewModel.gameState.currentPlayer
                playerSequence.append(playerAfter)
                
                // Players should alternate
                #expect(playerAfter != playerBefore)
            }
            
            moveCount += 1
        }
        
        // Verify alternation pattern
        for i in 1..<playerSequence.count {
            #expect(playerSequence[i] != playerSequence[i-1])
        }
        
        // Should start with black
        #expect(playerSequence.first == .black)
    }
    
    @Test("Valid moves calculation correctness")
    @MainActor func testValidMovesCalculationCorrectness() async {
        let viewModel = GameViewModel()
        let engine = GameEngine()
        
        for _ in 0..<8 {
            guard viewModel.gameState.gamePhase == .playing else { break }
            
            let vmValidMoves = Set(viewModel.validMoves)
            let engineValidMoves = Set(engine.availableMoves(for: viewModel.gameState))
            
            // ViewModel and engine should agree on valid moves
            #expect(vmValidMoves == engineValidMoves)
            
            // All valid moves should actually be valid when tested
            for move in vmValidMoves {
                let testMove = Move(position: move, player: viewModel.gameState.currentPlayer)
                #expect(engine.isValidMove(testMove, in: viewModel.gameState))
            }
            
            // Make a move to change state
            if let validMove = vmValidMoves.first {
                viewModel.makeMove(at: validMove)
            }
        }
    }
    
    @Test("Game completion detection accuracy")
    @MainActor func testGameCompletionDetectionAccuracy() async {
        let viewModel = GameViewModel()
        let engine = GameEngine()
        
        var moveCount = 0
        let maxMoves = 60
        
        while moveCount < maxMoves {
            let gameState = viewModel.gameState
            let vmPhase = gameState.gamePhase
            // Check if engine considers game finished based on available moves
            let availableMoves = engine.availableMoves(for: gameState)
            let enginePhase: GamePhase = availableMoves.isEmpty ? .finished : .playing
            
            // ViewModel and engine should agree on game phase
            #expect(vmPhase == enginePhase)
            
            if vmPhase == .finished {
                // Game is finished - verify completion logic
                let validMoves = engine.availableMoves(for: gameState)
                #expect(validMoves.isEmpty, "Game marked finished but valid moves exist")
                
                // Verify winner calculation
                let winner = engine.winner(of: gameState)
                let score = gameState.score
                
                if score.black > score.white {
                    #expect(winner == .black)
                } else if score.white > score.black {
                    #expect(winner == .white)
                } else {
                    #expect(winner == nil)
                }
                
                break
            }
            
            // Game is still playing - should have valid moves
            guard let validMove = viewModel.validMoves.first else {
                #expect(false, "Game marked as playing but no valid moves available")
                break
            }
            
            viewModel.makeMove(at: validMove)
            moveCount += 1
        }
    }
    
    @Test("Rapid sequential operations stress test")
    @MainActor func testRapidSequentialOperationsStressTest() async {
        let viewModel = GameViewModel()
        
        // Perform rapid operations to test robustness
        for _ in 0..<50 {
            // Random operation
            let operation = Int.random(in: 0..<4)
            
            switch operation {
            case 0:
                if let validMove = viewModel.validMoves.first {
                    viewModel.makeMove(at: validMove)
                }
            case 1:
                viewModel.requestNewGame()
            case 2:
                viewModel.confirmNewGame()
            case 3:
                viewModel.dismissGameCompletionAlert()
            default:
                break
            }
            
            // Verify state remains valid after each operation
            let state = viewModel.gameState
            #expect(state.score.black >= 0)
            #expect(state.score.white >= 0)
            #expect(state.score.black + state.score.white <= 64)
            #expect(!viewModel.isProcessingMove)
        }
    }
}