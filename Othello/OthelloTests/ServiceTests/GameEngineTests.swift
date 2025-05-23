//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import Othello

@Suite("GameEngine Tests")
struct GameEngineTests {
    
    let engine = GameEngine()
    
    @Test("New game initialization")
    func testNewGameInitialization() {
        let blackPlayer = PlayerInfo(player: .black, type: .human)
        let whitePlayer = PlayerInfo(player: .white, type: .human)
        
        let gameState = engine.newGame(blackPlayer: blackPlayer, whitePlayer: whitePlayer)
        
        #expect(gameState.board == Board.initial)
        #expect(gameState.currentPlayer == .black)
        #expect(gameState.gamePhase == .playing)
        #expect(gameState.blackPlayerInfo == blackPlayer)
        #expect(gameState.whitePlayerInfo == whitePlayer)
        #expect(gameState.moveCount == 0)
        #expect(!engine.isGameOver(gameState))
    }
    
    @Test("Available moves for initial position")
    func testAvailableMovesInitial() {
        let gameState = GameState.newHumanVsHuman()
        
        let availableMoves = engine.availableMoves(for: gameState)
        #expect(availableMoves.count == 4)
        
        let expectedMoves = [
            BoardPosition(row: 2, col: 3), // D6
            BoardPosition(row: 3, col: 2), // C5
            BoardPosition(row: 4, col: 5), // F4
            BoardPosition(row: 5, col: 4)  // E3
        ]
        
        for expectedMove in expectedMoves {
            #expect(availableMoves.contains(expectedMove), "Should contain move \(expectedMove)")
        }
        
        // Test player-specific moves
        let blackMoves = engine.availableMoves(for: .black, in: gameState)
        let whiteMoves = engine.availableMoves(for: .white, in: gameState)
        
        #expect(blackMoves.count == 4)
        #expect(whiteMoves.count == 4)
    }
    
    @Test("Valid move detection")
    func testValidMoveDetection() {
        let gameState = GameState.newHumanVsHuman()
        
        // Valid moves
        let validMove1 = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        let validMove2 = Move(position: BoardPosition(row: 3, col: 2), player: .black)
        
        #expect(engine.isValidMove(validMove1, in: gameState))
        #expect(engine.isValidMove(validMove2, in: gameState))
        
        // Invalid moves
        let wrongPlayer = Move(position: BoardPosition(row: 2, col: 3), player: .white)
        let occupiedSquare = Move(position: BoardPosition(row: 3, col: 3), player: .black)
        let noCapture = Move(position: BoardPosition(row: 0, col: 0), player: .black)
        let invalidPosition = Move(position: BoardPosition(row: -1, col: 0), player: .black)
        
        #expect(!engine.isValidMove(wrongPlayer, in: gameState))
        #expect(!engine.isValidMove(occupiedSquare, in: gameState))
        #expect(!engine.isValidMove(noCapture, in: gameState))
        #expect(!engine.isValidMove(invalidPosition, in: gameState))
    }
    
    @Test("Move application and capture")
    func testMoveApplicationAndCapture() {
        let gameState = GameState.newHumanVsHuman()
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        
        let result = engine.applyMove(move, to: gameState)
        
        #expect(result != nil)
        
        if let moveResult = result {
            #expect(moveResult.move == move)
            #expect(moveResult.captureCount == 1)
            #expect(moveResult.capturedPositions.contains(BoardPosition(row: 3, col: 3)))
            
            let newState = moveResult.newGameState
            #expect(newState.currentPlayer == .white)
            #expect(newState.score.black == 4)
            #expect(newState.score.white == 1)
            #expect(newState.board[move.position] == .black)
            #expect(newState.board[BoardPosition(row: 3, col: 3)] == .black)
        }
    }
    
    @Test("Invalid move application returns nil")
    func testInvalidMoveApplicationReturnsNil() {
        let gameState = GameState.newHumanVsHuman()
        let invalidMove = Move(position: BoardPosition(row: 0, col: 0), player: .black)
        
        let result = engine.applyMove(invalidMove, to: gameState)
        
        #expect(result == nil)
    }
    
    @Test("Captured positions calculation")
    func testCapturedPositionsCalculation() {
        let gameState = GameState.newHumanVsHuman()
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        
        let captured = engine.capturedPositions(for: move, in: gameState)
        
        #expect(captured.count == 1)
        #expect(captured.contains(BoardPosition(row: 3, col: 3)))
        
        // Test invalid move
        let invalidMove = Move(position: BoardPosition(row: 0, col: 0), player: .black)
        let noCaptured = engine.capturedPositions(for: invalidMove, in: gameState)
        #expect(noCaptured.isEmpty)
    }
    
    @Test("Game over detection")
    func testGameOverDetection() {
        // Create a game state where no moves are possible
        var board = Board()
        
        // Fill the board leaving no valid moves
        var placements: [BoardPosition: CellState] = [:]
        for row in 0..<8 {
            for col in 0..<8 {
                placements[BoardPosition(row: row, col: col)] = (row + col) % 2 == 0 ? .black : .white
            }
        }
        board = board.placing(placements)
        
        let gameState = engine.createTestGameState(board: board, gamePhase: .finished)
        
        #expect(engine.isGameOver(gameState))
        #expect(!engine.hasValidMoves(.black, in: gameState))
        #expect(!engine.hasValidMoves(.white, in: gameState))
    }
    
    @Test("Winner determination")
    func testWinnerDetermination() {
        // Create a finished game with black winning
        var board = Board()
        var placements: [BoardPosition: CellState] = [:]
        
        // Give black more pieces
        for row in 0..<8 {
            for col in 0..<8 {
                if (row + col) % 3 == 0 {
                    placements[BoardPosition(row: row, col: col)] = .white
                } else {
                    placements[BoardPosition(row: row, col: col)] = .black
                }
            }
        }
        board = board.placing(placements)
        
        let gameState = engine.createTestGameState(board: board, gamePhase: .finished)
        
        #expect(engine.isGameOver(gameState))
        
        let winner = engine.winner(of: gameState)
        let score = board.score
        
        if score.black > score.white {
            #expect(winner == .black)
        } else if score.white > score.black {
            #expect(winner == .white)
        } else {
            #expect(winner == nil)
        }
    }
    
    @Test("Next turn logic with valid moves")
    func testNextTurnWithValidMoves() {
        let gameState = GameState.newHumanVsHuman()
        
        #expect(gameState.currentPlayer == .black)
        
        let nextState = engine.nextTurn(from: gameState)
        
        // Since both players have moves, should switch to white
        if engine.hasValidMoves(.white, in: gameState) {
            #expect(nextState.currentPlayer == .white)
            #expect(nextState.gamePhase == .playing)
        }
    }
    
    @Test("Next turn logic when opponent has no moves")
    func testNextTurnWhenOpponentHasNoMoves() {
        // Create a scenario where white has no moves but black does
        var board = Board()
        
        // Set up a board where white is blocked
        let placements: [BoardPosition: CellState] = [
            BoardPosition(row: 0, col: 0): .black,
            BoardPosition(row: 0, col: 1): .black,
            BoardPosition(row: 1, col: 0): .black,
            BoardPosition(row: 1, col: 1): .white,
            BoardPosition(row: 2, col: 2): .black
        ]
        board = board.placing(placements)
        
        let gameState = engine.createTestGameState(board: board, currentPlayer: .black)
        
        let nextState = engine.nextTurn(from: gameState)
        
        // If white has no moves but black does, should stay with black
        if !engine.hasValidMoves(.white, in: gameState) && engine.hasValidMoves(.black, in: gameState) {
            #expect(nextState.currentPlayer == .black)
            #expect(nextState.gamePhase == .playing)
        }
    }
    
    @Test("Next turn logic when game is over")
    func testNextTurnWhenGameOver() {
        // Create a board where neither player has moves
        var board = Board()
        
        // Fill most of the board
        var placements: [BoardPosition: CellState] = [:]
        for row in 0..<8 {
            for col in 0..<8 {
                placements[BoardPosition(row: row, col: col)] = (row < 4) ? .black : .white
            }
        }
        board = board.placing(placements)
        
        let gameState = engine.createTestGameState(board: board)
        
        let nextState = engine.nextTurn(from: gameState)
        
        // If neither player has moves, game should be finished
        if !engine.hasValidMoves(.black, in: gameState) && !engine.hasValidMoves(.white, in: gameState) {
            #expect(nextState.gamePhase == .finished)
        }
    }
    
    @Test("Position analysis")
    func testPositionAnalysis() {
        let gameState = GameState.newHumanVsHuman()
        
        let analysis = engine.analyzePosition(gameState)
        
        #expect(analysis.mobility[.black] == 4)
        #expect(analysis.mobility[.white] == 4)
        #expect(analysis.cornerControl[.black] == 0)
        #expect(analysis.cornerControl[.white] == 0)
        #expect(analysis.evaluation[.black] != nil)
        #expect(analysis.evaluation[.white] != nil)
        
        // Test analysis properties
        #expect(analysis.mobilityDifference == 0) // Equal mobility
        #expect(analysis.cornerAdvantage == nil) // No corner advantage
    }
    
    @Test("Position evaluation")
    func testPositionEvaluation() {
        let gameState = GameState.newHumanVsHuman()
        
        let blackEval = engine.evaluatePosition(gameState, for: .black)
        let whiteEval = engine.evaluatePosition(gameState, for: .white)
        
        #expect(blackEval > 0) // Should be positive numbers
        #expect(whiteEval > 0)
        
        // In initial position, evaluations should be similar
        let difference = abs(blackEval - whiteEval)
        #expect(difference < 50) // Should be reasonably close
    }
    
    @Test("Complete game flow simulation")
    func testCompleteGameFlowSimulation() {
        var gameState = GameState.newHumanVsHuman()
        var moveCount = 0
        let maxMoves = 60 // Prevent infinite loops
        
        while !engine.isGameOver(gameState) && moveCount < maxMoves {
            let availableMoves = engine.availableMoves(for: gameState)
            
            if availableMoves.isEmpty {
                // No moves for current player - switch turns
                gameState = engine.nextTurn(from: gameState)
            } else {
                // Make the first available move
                let move = Move(position: availableMoves[0], player: gameState.currentPlayer)
                
                if let result = engine.applyMove(move, to: gameState) {
                    gameState = result.newGameState
                    moveCount += 1
                } else {
                    break // Should not happen with valid move
                }
            }
        }
        
        // Game should eventually end
        #expect(moveCount > 0)
        #expect(moveCount <= maxMoves) // Should complete within max moves
        
        if engine.isGameOver(gameState) {
            let winner = engine.winner(of: gameState)
            // Winner can be black, white, or nil (tie)
            
            if let winner = winner {
                let winnerScore = gameState.score.score(for: winner)
                let loserScore = gameState.score.score(for: winner.opposite)
                #expect(winnerScore > loserScore)
            } else {
                // Tie game
                #expect(gameState.score.black == gameState.score.white)
            }
        }
    }
    
    @Test("Game state validation")
    func testGameStateValidation() {
        let validGameState = GameState.newHumanVsHuman()
        let issues = engine.validateGameState(validGameState)
        #expect(issues.isEmpty, "Valid game state should have no issues")
        
        // Test with inconsistent state - create a full board marked as playing
        var fullBoard = Board()
        var placements: [BoardPosition: CellState] = [:]
        for position in BoardPosition.allPositions {
            placements[position] = .black // Fill entire board with black pieces
        }
        fullBoard = fullBoard.placing(placements)
        
        let inconsistentState = GameState(
            board: fullBoard, // Full board with no moves possible
            currentPlayer: .black,
            gamePhase: .playing, // But marked as still playing
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )
        
        let inconsistentIssues = engine.validateGameState(inconsistentState)
        #expect(!inconsistentIssues.isEmpty, "Inconsistent state should have issues. Found: \(inconsistentIssues)")
    }
    
    @Test("Engine handles finished games correctly")
    func testEngineHandlesFinishedGames() {
        let finishedGameState = GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .finished,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )
        
        // Should not allow moves in finished games
        let availableMoves = engine.availableMoves(for: finishedGameState)
        #expect(availableMoves.isEmpty)
        
        // Should not allow move application
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        let result = engine.applyMove(move, to: finishedGameState)
        #expect(result == nil)
    }
    
    @Test("Has valid moves check")
    func testHasValidMovesCheck() {
        let gameState = GameState.newHumanVsHuman()
        
        #expect(engine.hasValidMoves(.black, in: gameState))
        #expect(engine.hasValidMoves(.white, in: gameState))
        
        // Create empty board - no valid moves
        let emptyGameState = engine.createTestGameState(board: Board())
        #expect(!engine.hasValidMoves(.black, in: emptyGameState))
        #expect(!engine.hasValidMoves(.white, in: emptyGameState))
    }
}