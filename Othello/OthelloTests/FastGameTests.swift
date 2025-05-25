//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation
import Testing
@testable import Othello

/// Fast, focused tests for core game functionality
struct FastGameTests {
    let gameEngine = GameEngine()

    @Test("Complete human vs human game")
    func testCompleteHumanGame() {
        var gameState = GameState.newHumanVsHuman()
        var moveCount = 0

        // Play a complete game
        while gameState.gamePhase == .playing && moveCount < 100 {
            let availableMoves = gameEngine.availableMoves(for: gameState)
            guard let move = availableMoves.first else { break }

            let moveToMake = Move(position: move, player: gameState.currentPlayer)
            guard let result = gameEngine.applyMove(moveToMake, to: gameState) else { break }

            gameState = result.newGameState
            moveCount += 1
        }

        #expect(moveCount > 10, "Should complete a reasonable number of moves")
        #expect(gameState.score.total <= 64, "Score should be valid")
    }

    @Test("AI makes valid moves")
    func testAIValidMoves() async {
        let aiService = AIService()
        let gameState = GameState.newHumanVsAI(humanPlayer: .white, aiDifficulty: .easy)

        let availableMoves = gameEngine.availableMoves(for: .black, in: gameState)
        guard !availableMoves.isEmpty else { return }

        let aiMove = await aiService.calculateMove(
            for: gameState,
            player: .black,
            difficulty: .easy,
            using: gameEngine
        )

        #expect(aiMove != nil, "AI should calculate a move")

        if let aiMove = aiMove {
            #expect(gameEngine.isValidMove(aiMove, in: gameState), "AI move should be valid")
            #expect(availableMoves.contains(aiMove.position), "AI move should be in available moves")
        }
    }

    @Test("AI vs AI quick game")
    func testAIvsAIGame() async {
        let aiService = AIService()
        var gameState = GameState.newAIVsAI(blackDifficulty: .easy, whiteDifficulty: .easy)
        var moveCount = 0

        // Play only a few moves to keep test fast
        while gameState.gamePhase == .playing && moveCount < 10 {
            let currentPlayer = gameState.currentPlayer
            let playerInfo = gameState.playerInfo(for: currentPlayer)

            let aiMove = await aiService.calculateMove(
                for: gameState,
                player: currentPlayer,
                difficulty: playerInfo.aiDifficulty ?? .easy,
                using: gameEngine
            )

            guard let move = aiMove,
                  let result = gameEngine.applyMove(move, to: gameState) else { break }

            gameState = result.newGameState
            moveCount += 1
        }

        #expect(moveCount > 3, "AI vs AI should play at least a few moves")
        #expect(gameState.score.total > 4, "Should have valid final score")
    }

    @Test("Game engine performance")
    func testPerformance() {
        let gameState = GameState.newHumanVsHuman()

        // Measure move calculation performance
        let startTime = Date()

        for _ in 0..<1_000 {
            _ = gameEngine.availableMoves(for: gameState)
            _ = gameEngine.evaluatePosition(gameState, for: .black)
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        #expect(duration < 2.0, "1_000 calculations should complete in under 2 seconds")
    }

    @Test("Board state integrity")
    func testBoardIntegrity() {
        let board = Board.initial

        // Test initial state
        #expect(board.score.black == 2, "Initial black score should be 2")
        #expect(board.score.white == 2, "Initial white score should be 2")
        #expect(board.score.total == 4, "Initial total should be 4")

        // Test all positions are within bounds
        for row in 0..<8 {
            for col in 0..<8 {
                let position = BoardPosition(row: row, col: col)
                #expect(position.isValid, "All board positions should be valid")

                let cellState = board[position]
                #expect([CellState.empty, .black, .white].contains(cellState),
                       "Cell should have valid state")
            }
        }
    }

    @Test("Move validation logic")
    func testMoveValidation() {
        let gameState = GameState.newHumanVsHuman()

        // Test valid starting moves
        let validMoves = gameEngine.availableMoves(for: gameState)
        #expect(validMoves.count == 4, "Should have exactly 4 valid opening moves")

        // Expected opening moves for black
        let expectedMoves = [
            BoardPosition(row: 2, col: 3),
            BoardPosition(row: 3, col: 2),
            BoardPosition(row: 4, col: 5),
            BoardPosition(row: 5, col: 4)
        ]

        for move in expectedMoves {
            #expect(validMoves.contains(move), "Should contain expected opening move: \(move)")
        }

        // Test invalid moves
        let invalidMove = Move(position: BoardPosition(row: 0, col: 0), player: .black)
        #expect(!gameEngine.isValidMove(invalidMove, in: gameState),
               "Corner move should be invalid in opening")
    }
}
