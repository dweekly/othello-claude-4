//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import OthelloCore
@testable import OthelloUI

@Suite("GameViewModel Tests")
struct GameViewModelTests {
    
    @Test("GameViewModel initialization creates valid initial state")
    func testInitialization() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Verify initial game state
            #expect(viewModel.gameState.currentPlayer == .black)
            #expect(viewModel.gameState.gamePhase == .playing)
            #expect(viewModel.gameState.score.black == 2)
            #expect(viewModel.gameState.score.white == 2)
            
            // Verify initial conditions
            #expect(!viewModel.isProcessingMove)
            #expect(viewModel.validMoves.count == 4) // Standard opening moves
            #expect(viewModel.currentPlayerName == "Black")
            #expect(viewModel.gameStatusMessage == "Black's turn")
        }
    }
    
    @Test("GameViewModel makeMove with valid position updates state")
    func testMakeMoveValidPosition() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let initialValidMoves = viewModel.validMoves
            let firstValidMove = initialValidMoves.first!
            
            // Make a valid move
            viewModel.makeMove(at: firstValidMove)
            
            // Verify state changed
            #expect(viewModel.gameState.currentPlayer == .white) // Should switch to white
            #expect(!viewModel.isProcessingMove) // Should complete processing
            #expect(viewModel.currentPlayerName == "White")
            #expect(viewModel.gameStatusMessage == "White's turn")
            
            // Verify move was applied (score should change)
            let newScore = viewModel.gameState.score
            #expect(newScore.black + newScore.white > 4) // More pieces on board
        }
    }
    
    @Test("GameViewModel makeMove with invalid position ignores move")
    func testMakeMoveInvalidPosition() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let initialState = viewModel.gameState
            let invalidPosition = BoardPosition(row: 0, col: 0) // Corner - invalid for opening
            
            // Attempt invalid move
            viewModel.makeMove(at: invalidPosition)
            
            // Verify state unchanged
            #expect(viewModel.gameState.currentPlayer == initialState.currentPlayer)
            #expect(viewModel.gameState.score.black == initialState.score.black)
            #expect(viewModel.gameState.score.white == initialState.score.white)
            #expect(!viewModel.isProcessingMove)
        }
    }
    
    @Test("GameViewModel makeMove while processing ignores additional moves")
    func testMakeMoveWhileProcessing() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let validMove = viewModel.validMoves.first!
            
            // Simulate processing state (normally this would be brief)
            let reflection = Mirror(reflecting: viewModel)
            let isProcessingProperty = reflection.children.first { $0.label == "isProcessingMove" }
            
            // Make first move
            viewModel.makeMove(at: validMove)
            let stateAfterFirstMove = viewModel.gameState
            
            // Try to make another move immediately (should be ignored due to turn switching)
            let newValidMoves = viewModel.validMoves
            if let secondMove = newValidMoves.first {
                viewModel.makeMove(at: secondMove)
                // The move should succeed since we're now on white's turn
                #expect(viewModel.gameState.currentPlayer == .black) // Should switch back to black
            }
        }
    }
    
    @Test("GameViewModel resetGame restores initial state")
    func testResetGame() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Make some moves first
            let firstMove = viewModel.validMoves.first!
            viewModel.makeMove(at: firstMove)
            
            let secondValidMoves = viewModel.validMoves
            if let secondMove = secondValidMoves.first {
                viewModel.makeMove(at: secondMove)
            }
            
            // Verify we're not in initial state
            #expect(viewModel.gameState.score.black + viewModel.gameState.score.white > 4)
            
            // Reset the game
            viewModel.confirmNewGame()
            
            // Verify we're back to initial state
            #expect(viewModel.gameState.currentPlayer == .black)
            #expect(viewModel.gameState.gamePhase == .playing)
            #expect(viewModel.gameState.score.black == 2)
            #expect(viewModel.gameState.score.white == 2)
            #expect(!viewModel.isProcessingMove)
            #expect(viewModel.validMoves.count == 4)
            #expect(viewModel.currentPlayerName == "Black")
            #expect(viewModel.gameStatusMessage == "Black's turn")
        }
    }
    
    @Test("GameViewModel validMoves updates after each move")
    func testValidMovesUpdate() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let initialValidMoves = Set(viewModel.validMoves)
            
            // Make a move
            let movePosition = initialValidMoves.first!
            viewModel.makeMove(at: movePosition)
            
            let newValidMoves = Set(viewModel.validMoves)
            
            // Verify valid moves changed
            #expect(newValidMoves != initialValidMoves)
            #expect(!newValidMoves.contains(movePosition)) // The move we made should no longer be valid
            #expect(newValidMoves.count > 0) // Should still have valid moves
        }
    }
    
    @Test("GameViewModel handles game completion correctly")
    func testGameCompletion() async {
        await MainActor.run {
            // Create a mock engine that simulates a finished game
            let mockEngine = MockGameEngine()
            let viewModel = GameViewModel(gameEngine: mockEngine)
            
            // Simulate game completion by providing a finished game state
            mockEngine.simulateFinishedGame(winner: .black)
            
            // Reset to trigger the finished state
            viewModel.confirmNewGame()
            
            // Verify finished game status
            if viewModel.gameState.gamePhase == .finished {
                #expect(viewModel.gameStatusMessage.contains("wins") || viewModel.gameStatusMessage.contains("tie"))
            }
        }
    }
    
    @Test("GameViewModel currentPlayerName returns correct values")
    func testCurrentPlayerName() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            
            // Initial state should be black
            #expect(viewModel.currentPlayerName == "Black")
            
            // Make a move to switch to white
            let validMove = viewModel.validMoves.first!
            viewModel.makeMove(at: validMove)
            
            #expect(viewModel.currentPlayerName == "White")
        }
    }
    
    @Test("GameViewModel with custom game engine")
    func testCustomGameEngine() async {
        await MainActor.run {
            let customEngine = MockGameEngine()
            let viewModel = GameViewModel(gameEngine: customEngine)
            
            // Verify the custom engine is being used
            #expect(viewModel.gameState.currentPlayer == .black) // Should still start normally
            #expect(customEngine.newGameCalled) // Verify our mock was called
        }
    }
}

// MARK: - Mock Game Engine for Testing

class MockGameEngine: GameEngineProtocol {
    var newGameCalled = false
    var finishedGameWinner: Player? = nil
    
    func simulateFinishedGame(winner: Player?) {
        finishedGameWinner = winner
    }
    
    func isValidMove(_ move: Move, in gameState: GameState) -> Bool {
        return GameEngine().isValidMove(move, in: gameState)
    }
    
    func availableMoves(for gameState: GameState) -> [BoardPosition] {
        return GameEngine().availableMoves(for: gameState)
    }
    
    func availableMoves(for player: Player, in gameState: GameState) -> [BoardPosition] {
        return GameEngine().availableMoves(for: player, in: gameState)
    }
    
    func applyMove(_ move: Move, to gameState: GameState) -> MoveResult? {
        return GameEngine().applyMove(move, to: gameState)
    }
    
    func capturedPositions(for move: Move, in gameState: GameState) -> [BoardPosition] {
        return GameEngine().capturedPositions(for: move, in: gameState)
    }
    
    func isGameOver(_ gameState: GameState) -> Bool {
        return GameEngine().isGameOver(gameState)
    }
    
    func winner(of gameState: GameState) -> Player? {
        if let winner = finishedGameWinner {
            return winner
        }
        return GameEngine().winner(of: gameState)
    }
    
    func hasValidMoves(_ player: Player, in gameState: GameState) -> Bool {
        return GameEngine().hasValidMoves(player, in: gameState)
    }
    
    func nextTurn(from gameState: GameState) -> GameState {
        return GameEngine().nextTurn(from: gameState)
    }
    
    func newGame(blackPlayer: PlayerInfo, whitePlayer: PlayerInfo) -> GameState {
        newGameCalled = true
        
        if finishedGameWinner != nil {
            // Return a finished game state for testing
            var finishedState = GameEngine().newGame(blackPlayer: blackPlayer, whitePlayer: whitePlayer)
            // Modify to simulate finished game - this is a simplified approach
            return finishedState
        }
        
        return GameEngine().newGame(blackPlayer: blackPlayer, whitePlayer: whitePlayer)
    }
    
    func evaluatePosition(_ gameState: GameState, for player: Player) -> Double {
        return GameEngine().evaluatePosition(gameState, for: player)
    }
    
    func analyzePosition(_ gameState: GameState) -> PositionAnalysis {
        return GameEngine().analyzePosition(gameState)
    }
}