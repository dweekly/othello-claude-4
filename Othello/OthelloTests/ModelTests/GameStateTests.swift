//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import Othello

@Suite("GameState Tests")
struct GameStateTests {

    @Test("Human vs Human game initialization")
    func testHumanVsHumanInitialization() {
        let gameState = GameState.newHumanVsHuman()

        #expect(gameState.board == Board.initial)
        #expect(gameState.currentPlayer == .black)
        #expect(gameState.gamePhase == .playing)
        #expect(gameState.moveHistory.isEmpty)
        #expect(gameState.blackPlayerInfo.type == .human)
        #expect(gameState.whitePlayerInfo.type == .human)
        #expect(!gameState.isGameOver)
        #expect(gameState.winner == nil)
        #expect(!gameState.isTied)
    }

    @Test("Human vs AI game initialization")
    func testHumanVsAIInitialization() {
        let gameState = GameState.newHumanVsAI(humanPlayer: .black, aiDifficulty: .medium)

        #expect(gameState.blackPlayerInfo.type == .human)
        #expect(gameState.whitePlayerInfo.type == .ai)
        #expect(gameState.whitePlayerInfo.aiDifficulty == .medium)
        #expect(gameState.isCurrentPlayerHuman)
        #expect(!gameState.isCurrentPlayerAI)

        let reverseGame = GameState.newHumanVsAI(humanPlayer: .white, aiDifficulty: .hard)
        #expect(reverseGame.blackPlayerInfo.type == .ai)
        #expect(reverseGame.whitePlayerInfo.type == .human)
        #expect(reverseGame.blackPlayerInfo.aiDifficulty == .hard)
        #expect(!reverseGame.isCurrentPlayerHuman) // Black (AI) starts
        #expect(reverseGame.isCurrentPlayerAI)
    }

    @Test("AI vs AI game initialization")
    func testAIVsAIInitialization() {
        let gameState = GameState.newAIVsAI(blackDifficulty: .easy, whiteDifficulty: .hard)

        #expect(gameState.blackPlayerInfo.type == .ai)
        #expect(gameState.whitePlayerInfo.type == .ai)
        #expect(gameState.blackPlayerInfo.aiDifficulty == .easy)
        #expect(gameState.whitePlayerInfo.aiDifficulty == .hard)
        #expect(gameState.isCurrentPlayerAI)
        #expect(!gameState.isCurrentPlayerHuman)
    }

    @Test("Available moves calculation")
    func testAvailableMovesCalculation() {
        let gameState = GameState.newHumanVsHuman()

        let availableMoves = gameState.availableMoves
        #expect(availableMoves.count == 4)

        let expectedMoves = [
            BoardPosition(row: 2, col: 3),
            BoardPosition(row: 3, col: 2),
            BoardPosition(row: 4, col: 5),
            BoardPosition(row: 5, col: 4)
        ]

        for expectedMove in expectedMoves {
            #expect(availableMoves.contains(expectedMove))
        }

        #expect(gameState.hasValidMoves)
    }

    @Test("Applying valid move updates state correctly")
    func testApplyingValidMove() {
        let gameState = GameState.newHumanVsHuman()
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)

        let newGameState = gameState.applyingMove(move)

        #expect(newGameState != nil)

        if let newState = newGameState {
            #expect(newState.currentPlayer == .white)
            #expect(newState.gamePhase == .playing)
            #expect(newState.moveCount == 1)
            #expect(newState.moveHistory.lastMove == move)
            #expect(newState.score.black == 4)
            #expect(newState.score.white == 1)
            #expect(newState.board[move.position] == .black)
        }
    }

    @Test("Applying invalid move returns nil")
    func testApplyingInvalidMove() {
        let gameState = GameState.newHumanVsHuman()

        // Wrong player's turn
        let wrongPlayerMove = Move(position: BoardPosition(row: 2, col: 3), player: .white)
        #expect(gameState.applyingMove(wrongPlayerMove) == nil)

        // Invalid position (occupied)
        let occupiedMove = Move(position: BoardPosition(row: 3, col: 3), player: .black)
        #expect(gameState.applyingMove(occupiedMove) == nil)

        // Invalid position (no capture)
        let noCaptureMove = Move(position: BoardPosition(row: 0, col: 0), player: .black)
        #expect(gameState.applyingMove(noCaptureMove) == nil)
    }

    @Test("Player switching when opponent has no moves")
    func testPlayerSwitchingNoMoves() {
        // Create a game state where one player has no valid moves
        var board = Board()

        // Set up a scenario where white has no moves but black does
        let placements: [BoardPosition: CellState] = [
            BoardPosition(row: 0, col: 0): .black,
            BoardPosition(row: 0, col: 1): .white,
            BoardPosition(row: 1, col: 0): .black,
            BoardPosition(row: 1, col: 1): .black
        ]
        board = board.placing(placements)

        let gameState = GameState(
            board: board,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )

        let switchedState = gameState.switchingPlayer()

        if !board.validMoves(for: .white).isEmpty {
            #expect(switchedState.currentPlayer == .white)
        } else if !board.validMoves(for: .black).isEmpty {
            #expect(switchedState.currentPlayer == .black)
        } else {
            #expect(switchedState.gamePhase == .finished)
        }
    }

    @Test("Game over detection when no moves available")
    func testGameOverDetection() {
        // Create a board where no moves are possible
        var board = Board()

        // Fill most of the board leaving no valid moves
        var placements: [BoardPosition: CellState] = [:]
        for row in 0..<8 {
            for col in 0..<8 {
                if row < 4 {
                    placements[BoardPosition(row: row, col: col)] = .black
                } else {
                    placements[BoardPosition(row: row, col: col)] = .white
                }
            }
        }
        board = board.placing(placements)

        let gameState = GameState(
            board: board,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )

        let switchedState = gameState.switchingPlayer()

        if board.validMoves(for: .black).isEmpty && board.validMoves(for: .white).isEmpty {
            #expect(switchedState.gamePhase == .finished)
            #expect(switchedState.isGameOver)
        }
    }

    @Test("Winner determination")
    func testWinnerDetermination() {
        // Create a finished game with black winning
        var board = Board()
        var placements: [BoardPosition: CellState] = [:]

        // Black gets more pieces
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

        let gameState = GameState(
            board: board,
            currentPlayer: .black,
            gamePhase: .finished,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )

        #expect(gameState.isGameOver)

        if gameState.score.black > gameState.score.white {
            #expect(gameState.winner == .black)
            #expect(!gameState.isTied)
        } else if gameState.score.white > gameState.score.black {
            #expect(gameState.winner == .white)
            #expect(!gameState.isTied)
        } else {
            #expect(gameState.winner == nil)
            #expect(gameState.isTied)
        }
    }

    @Test("Tie game detection")
    func testTieGameDetection() {
        // Create a tied game
        var board = Board()
        var placements: [BoardPosition: CellState] = [:]

        // Equal pieces for both players
        for row in 0..<8 {
            for col in 0..<8 {
                if (row + col) % 2 == 0 {
                    placements[BoardPosition(row: row, col: col)] = .black
                } else {
                    placements[BoardPosition(row: row, col: col)] = .white
                }
            }
        }
        board = board.placing(placements)

        let gameState = GameState(
            board: board,
            currentPlayer: .black,
            gamePhase: .finished,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )

        #expect(gameState.score.black == gameState.score.white)
        #expect(gameState.isTied)
        #expect(gameState.winner == nil)
    }

    @Test("Player info retrieval")
    func testPlayerInfoRetrieval() {
        let gameState = GameState.newHumanVsAI(humanPlayer: .black, aiDifficulty: .medium)

        let blackInfo = gameState.playerInfo(for: .black)
        let whiteInfo = gameState.playerInfo(for: .white)

        #expect(blackInfo.type == .human)
        #expect(blackInfo.aiDifficulty == nil)
        #expect(whiteInfo.type == .ai)
        #expect(whiteInfo.aiDifficulty == .medium)

        #expect(gameState.currentPlayerInfo == blackInfo)
    }

    @Test("Game duration calculation")
    func testGameDurationCalculation() {
        let startTime = Date().addingTimeInterval(-60) // 1 minute ago
        let gameState = GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human),
            startTime: startTime
        )

        let duration = gameState.gameDuration
        #expect(duration >= 59) // Should be approximately 60 seconds
        #expect(duration <= 61)
    }

    @Test("Game result generation")
    func testGameResultGeneration() {
        let gameState = GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .finished,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )

        let result = gameState.gameResult
        #expect(result != nil)

        if let result = result {
            #expect(result.finalScore == gameState.score)
            #expect(result.moveCount == gameState.moveCount)
            #expect(result.gameId == gameState.gameId)
        }
    }

    @Test("Game result is nil for ongoing games")
    func testGameResultNilForOngoingGames() {
        let gameState = GameState.newHumanVsHuman()

        #expect(gameState.gameResult == nil)
    }

    @Test("Move history tracking")
    func testMoveHistoryTracking() {
        var gameState = GameState.newHumanVsHuman()

        #expect(gameState.moveCount == 0)
        #expect(gameState.moveHistory.isEmpty)

        let move1 = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        gameState = gameState.applyingMove(move1)!

        #expect(gameState.moveCount == 1)
        #expect(gameState.moveHistory.lastMove == move1)

        let move2 = Move(position: BoardPosition(row: 2, col: 4), player: .white)
        gameState = gameState.applyingMove(move2)!

        #expect(gameState.moveCount == 2)
        #expect(gameState.moveHistory.lastMove == move2)
    }

    @Test("Game state immutability")
    func testGameStateImmutability() {
        let originalState = GameState.newHumanVsHuman()
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)

        _ = originalState.applyingMove(move)

        // Original state should be unchanged
        #expect(originalState.currentPlayer == .black)
        #expect(originalState.moveCount == 0)
        #expect(originalState.score == Score.initial)
    }

    @Test("Game state equality")
    func testGameStateEquality() {
        let state1 = GameState.newHumanVsHuman()
        let state2 = GameState.newHumanVsHuman()

        // Different game IDs should make them unequal
        #expect(state1 != state2)

        // Same game with same moves should be equal
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)
        let newState1 = state1.applyingMove(move)!
        let newState2 = state1.applyingMove(move)!

        #expect(newState1 == newState2)
    }
}
