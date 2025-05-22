//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import SwiftUI
@testable import OthelloCore
@testable import OthelloUI

@Suite("GameStatusView Tests")
struct GameStatusViewTests {
    
    @Test("GameStatusView displays correct player information")
    func testPlayerInformation() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Verify the view can be created with initial state
            #expect(statusView.viewModel.gameState.currentPlayer == .black)
            #expect(statusView.viewModel.gameState.score.black == 2)
            #expect(statusView.viewModel.gameState.score.white == 2)
            #expect(statusView.viewModel.gameStatusMessage == "Black's turn")
        }
    }
    
    @Test("GameStatusView reflects game state changes")
    func testGameStateChanges() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Make a move to change the game state
            let validMove = viewModel.validMoves.first!
            viewModel.makeMove(at: validMove)
            
            // Verify the status view reflects the new state
            #expect(statusView.viewModel.gameState.currentPlayer == .white)
            #expect(statusView.viewModel.gameStatusMessage == "White's turn")
            
            // Score should have changed
            let newScore = statusView.viewModel.gameState.score
            #expect(newScore.black + newScore.white > 4)
        }
    }
    
    @Test("GameStatusView handles finished game state")
    func testFinishedGameState() async {
        await MainActor.run {
            // Create a mock engine that simulates a finished game
            let mockEngine = MockFinishedGameEngine(winner: .black)
            let viewModel = GameViewModel(gameEngine: mockEngine)
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Verify finished game message
            if statusView.viewModel.gameState.gamePhase == .finished {
                let message = statusView.viewModel.gameStatusMessage
                #expect(message.contains("wins") || message.contains("tie"))
            }
        }
    }
    
    @Test("GameStatusView handles tie game")
    func testTieGameState() async {
        await MainActor.run {
            let mockEngine = MockFinishedGameEngine(winner: nil) // nil = tie
            let viewModel = GameViewModel(gameEngine: mockEngine)
            let statusView = GameStatusView(viewModel: viewModel)
            
            if statusView.viewModel.gameState.gamePhase == .finished {
                let message = statusView.viewModel.gameStatusMessage
                #expect(message.contains("tie"))
            }
        }
    }
    
    @Test("GameStatusView score display accuracy")
    func testScoreDisplayAccuracy() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Track scores through several moves
            var moveCount = 0
            while moveCount < 3 && !viewModel.validMoves.isEmpty {
                let validMove = viewModel.validMoves.first!
                let previousScore = viewModel.gameState.score
                
                viewModel.makeMove(at: validMove)
                
                let currentScore = statusView.viewModel.gameState.score
                
                // Verify scores are non-negative and logical
                #expect(currentScore.black >= 0)
                #expect(currentScore.white >= 0)
                #expect(currentScore.black + currentScore.white > previousScore.black + previousScore.white)
                #expect(currentScore.black + currentScore.white <= 64)
                
                moveCount += 1
            }
        }
    }
    
    @Test("GameStatusView current player indication")
    func testCurrentPlayerIndication() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Initial state - Black should be current player
            #expect(statusView.viewModel.gameState.currentPlayer == .black)
            #expect(statusView.viewModel.currentPlayerName == "Black")
            
            // Make a move to switch to White
            if let validMove = viewModel.validMoves.first {
                viewModel.makeMove(at: validMove)
                
                #expect(statusView.viewModel.gameState.currentPlayer == .white)
                #expect(statusView.viewModel.currentPlayerName == "White")
            }
        }
    }
    
    @Test("GameStatusView message consistency")
    func testMessageConsistency() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Playing game should show turn message
            if statusView.viewModel.gameState.gamePhase == .playing {
                let message = statusView.viewModel.gameStatusMessage
                let playerName = statusView.viewModel.currentPlayerName
                #expect(message.contains(playerName))
                #expect(message.contains("turn"))
            }
            
            // Message should not be empty
            #expect(!statusView.viewModel.gameStatusMessage.isEmpty)
        }
    }
    
    @Test("GameStatusView reset behavior")
    func testResetBehavior() async {
        await MainActor.run {
            let viewModel = GameViewModel()
            let statusView = GameStatusView(viewModel: viewModel)
            
            // Make some moves
            for _ in 0..<2 {
                if let validMove = viewModel.validMoves.first {
                    viewModel.makeMove(at: validMove)
                }
            }
            
            // Reset the game
            viewModel.resetGame()
            
            // Verify status view reflects reset state
            #expect(statusView.viewModel.gameState.currentPlayer == .black)
            #expect(statusView.viewModel.gameState.score.black == 2)
            #expect(statusView.viewModel.gameState.score.white == 2)
            #expect(statusView.viewModel.gameStatusMessage == "Black's turn")
        }
    }
}

// MARK: - Mock Engine for Finished Game Testing

class MockFinishedGameEngine: GameEngineProtocol {
    private let winner: Player?
    
    init(winner: Player?) {
        self.winner = winner
    }
    
    func isValidMove(_ move: Move, in gameState: GameState) -> Bool {
        return false // No valid moves in finished game
    }
    
    func availableMoves(for gameState: GameState) -> [BoardPosition] {
        return [] // No moves available in finished game
    }
    
    func availableMoves(for player: Player, in gameState: GameState) -> [BoardPosition] {
        return []
    }
    
    func applyMove(_ move: Move, to gameState: GameState) -> MoveResult? {
        return nil // Can't make moves in finished game
    }
    
    func capturedPositions(for move: Move, in gameState: GameState) -> [BoardPosition] {
        return []
    }
    
    func isGameOver(_ gameState: GameState) -> Bool {
        return true // Game is always over
    }
    
    func winner(of gameState: GameState) -> Player? {
        return winner
    }
    
    func hasValidMoves(_ player: Player, in gameState: GameState) -> Bool {
        return false
    }
    
    func nextTurn(from gameState: GameState) -> GameState {
        return gameState // No turn changes in finished game
    }
    
    func newGame(blackPlayer: PlayerInfo, whitePlayer: PlayerInfo) -> GameState {
        // Create a finished game state
        var gameState = GameState(
            board: Board(), // Empty board for simplicity
            currentPlayer: .black,
            gamePhase: .finished, // Mark as finished
            moveHistory: MoveHistory(),
            blackPlayerInfo: blackPlayer,
            whitePlayerInfo: whitePlayer,
            gameId: UUID(),
            startTime: Date()
        )
        
        return gameState
    }
    
    func evaluatePosition(_ gameState: GameState, for player: Player) -> Double {
        return 0.0
    }
    
    func analyzePosition(_ gameState: GameState) -> PositionAnalysis {
        return PositionAnalysis(
            mobility: [.black: 0, .white: 0],
            cornerControl: [.black: 0, .white: 0],
            edgeControl: [.black: 0, .white: 0],
            stability: [.black: 0.0, .white: 0.0],
            evaluation: [.black: 0.0, .white: 0.0]
        )
    }
}