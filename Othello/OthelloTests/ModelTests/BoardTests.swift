//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import Othello

@Suite("Board Tests")
struct BoardTests {
    @Test("Empty board initialization")
    func testEmptyBoardInitialization() {
        let board = Board()

        #expect(board.isEmpty)
        #expect(!board.isFull)
        #expect(board.score == Score.zero)
        #expect(board.emptyPositions.count == 64)

        for position in BoardPosition.allPositions {
            #expect(board[position] == .empty)
        }
    }

    @Test("Initial board setup")
    func testInitialBoardSetup() {
        let board = Board.initial

        #expect(!board.isEmpty)
        #expect(!board.isFull)
        #expect(board.score == Score.initial)
        #expect(board.emptyPositions.count == 60)

        // Check initial piece placement
        #expect(board[BoardPosition(row: 3, col: 3)] == .white)
        #expect(board[BoardPosition(row: 3, col: 4)] == .black)
        #expect(board[BoardPosition(row: 4, col: 3)] == .black)
        #expect(board[BoardPosition(row: 4, col: 4)] == .white)

        // Check that other positions are empty
        let occupiedPositions = Set([
            BoardPosition(row: 3, col: 3),
            BoardPosition(row: 3, col: 4),
            BoardPosition(row: 4, col: 3),
            BoardPosition(row: 4, col: 4)
        ])

        for position in BoardPosition.allPositions where !occupiedPositions.contains(position) {
            #expect(board[position] == .empty, "Position \(position) should be empty")
        }
    }

    @Test("Placing pieces creates new board")
    func testPlacingPieces() {
        let originalBoard = Board()
        let position = BoardPosition(row: 2, col: 3)

        let newBoard = originalBoard.placing(.black, at: position)

        // Original board should be unchanged
        #expect(originalBoard[position] == .empty)

        // New board should have the piece
        #expect(newBoard[position] == .black)

        // Other positions should remain the same
        for otherPosition in BoardPosition.allPositions where otherPosition != position {
            #expect(newBoard[otherPosition] == originalBoard[otherPosition])
        }
    }

    @Test("Placing multiple pieces")
    func testPlacingMultiplePieces() {
        let board = Board()
        let placements: [BoardPosition: CellState] = [
            BoardPosition(row: 0, col: 0): .black,
            BoardPosition(row: 1, col: 1): .white,
            BoardPosition(row: 2, col: 2): .black,
            BoardPosition(row: 7, col: 7): .white
        ]

        let newBoard = board.placing(placements)

        for (position, expectedState) in placements {
            #expect(newBoard[position] == expectedState)
        }

        // Other positions should remain empty
        let placedPositions = Set(placements.keys)
        for position in BoardPosition.allPositions where !placedPositions.contains(position) {
            #expect(newBoard[position] == .empty)
        }
    }

    @Test("Invalid position placement is ignored")
    func testInvalidPositionPlacement() {
        let board = Board()
        let invalidPosition = BoardPosition(row: -1, col: 0)

        let newBoard = board.placing(.black, at: invalidPosition)

        // Board should be unchanged
        #expect(newBoard == board)
    }

    @Test("Positions with specific state")
    func testPositionsWithState() {
        let board = Board.initial

        let blackPositions = board.positions(with: .black)
        let whitePositions = board.positions(with: .white)
        let emptyPositions = board.positions(with: .empty)

        #expect(blackPositions.count == 2)
        #expect(whitePositions.count == 2)
        #expect(emptyPositions.count == 60)

        #expect(blackPositions.contains(BoardPosition(row: 3, col: 4)))
        #expect(blackPositions.contains(BoardPosition(row: 4, col: 3)))
        #expect(whitePositions.contains(BoardPosition(row: 3, col: 3)))
        #expect(whitePositions.contains(BoardPosition(row: 4, col: 4)))
    }

    @Test("Board score calculation")
    func testBoardScore() {
        let board = Board.initial
        let score = board.score

        #expect(score.black == 2)
        #expect(score.white == 2)
        #expect(score.total == 4)
    }

    @Test("Board full detection")
    func testBoardFullDetection() {
        var board = Board()

        // Fill the entire board
        var placements: [BoardPosition: CellState] = [:]
        for (index, position) in BoardPosition.allPositions.enumerated() {
            placements[position] = (index % 2 == 0) ? .black : .white
        }

        board = board.placing(placements)

        #expect(board.isFull)
        #expect(!board.isEmpty)
        #expect(board.emptyPositions.isEmpty)
        #expect(board.score.total == 64)
    }

    @Test("Positions in direction calculation")
    func testPositionsInDirection() {
        let board = Board()
        let start = BoardPosition(row: 3, col: 3)

        // Test moving right (east)
        let rightPositions = board.positions(from: start, rowDirection: 0, colDirection: 1)
        let expectedRight = [
            BoardPosition(row: 3, col: 4),
            BoardPosition(row: 3, col: 5),
            BoardPosition(row: 3, col: 6),
            BoardPosition(row: 3, col: 7)
        ]
        #expect(rightPositions == expectedRight)

        // Test moving down (south)
        let downPositions = board.positions(from: start, rowDirection: 1, colDirection: 0)
        let expectedDown = [
            BoardPosition(row: 4, col: 3),
            BoardPosition(row: 5, col: 3),
            BoardPosition(row: 6, col: 3),
            BoardPosition(row: 7, col: 3)
        ]
        #expect(downPositions == expectedDown)

        // Test moving diagonal (southeast)
        let diagonalPositions = board.positions(from: start, rowDirection: 1, colDirection: 1)
        let expectedDiagonal = [
            BoardPosition(row: 4, col: 4),
            BoardPosition(row: 5, col: 5),
            BoardPosition(row: 6, col: 6),
            BoardPosition(row: 7, col: 7)
        ]
        #expect(diagonalPositions == expectedDiagonal)
    }

    @Test("Valid moves for initial board")
    func testValidMovesInitialBoard() {
        let board = Board.initial

        let blackMoves = board.validMoves(for: .black)
        let whiteMoves = board.validMoves(for: .white)

        // Black should have 4 valid moves in the initial position
        #expect(blackMoves.count == 4)

        let expectedBlackMoves = [
            BoardPosition(row: 2, col: 3), // D6
            BoardPosition(row: 3, col: 2), // C5
            BoardPosition(row: 4, col: 5), // F4
            BoardPosition(row: 5, col: 4)  // E3
        ]

        for expectedMove in expectedBlackMoves {
            #expect(blackMoves.contains(expectedMove), "Black should be able to move to \(expectedMove)")
        }

        // White should have 4 valid moves too (symmetric)
        #expect(whiteMoves.count == 4)
    }

    @Test("Captured positions calculation")
    func testCapturedPositions() {
        let board = Board.initial
        let move = BoardPosition(row: 2, col: 3) // D6, valid black move

        let captured = board.capturedPositions(placing: .black, at: move)

        #expect(captured.count == 1)
        #expect(captured.contains(BoardPosition(row: 3, col: 3))) // Should capture the white piece
    }

    @Test("No capture when move is invalid")
    func testNoCaptureInvalidMove() {
        let board = Board.initial
        let invalidMove = BoardPosition(row: 0, col: 0) // Corner, no pieces to capture

        let captured = board.capturedPositions(placing: .black, at: invalidMove)

        #expect(captured.isEmpty)
    }

    @Test("Move validation")
    func testMoveValidation() {
        let board = Board.initial

        // Valid moves
        #expect(board.isValidMove(at: BoardPosition(row: 2, col: 3), for: .black))
        #expect(board.isValidMove(at: BoardPosition(row: 3, col: 2), for: .black))
        #expect(board.isValidMove(at: BoardPosition(row: 4, col: 5), for: .black))
        #expect(board.isValidMove(at: BoardPosition(row: 5, col: 4), for: .black))

        // Invalid moves
        #expect(!board.isValidMove(at: BoardPosition(row: 0, col: 0), for: .black)) // No capture
        #expect(!board.isValidMove(at: BoardPosition(row: 3, col: 3), for: .black)) // Occupied
        #expect(!board.isValidMove(at: BoardPosition(row: 1, col: 1), for: .black)) // No capture
    }

    @Test("Applying valid move")
    func testApplyingValidMove() {
        let board = Board.initial
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)

        let result = board.applyingMove(move)

        #expect(result != nil)

        if let (newBoard, captured) = result {
            #expect(captured.count == 1)
            #expect(captured.contains(BoardPosition(row: 3, col: 3)))

            #expect(newBoard[move.position] == .black)
            #expect(newBoard[BoardPosition(row: 3, col: 3)] == .black) // Captured piece flipped

            let newScore = newBoard.score
            #expect(newScore.black == 4) // Was 2, placed 1, captured 1
            #expect(newScore.white == 1) // Was 2, lost 1
        }
    }

    @Test("Applying invalid move returns nil")
    func testApplyingInvalidMove() {
        let board = Board.initial
        let invalidMove = Move(position: BoardPosition(row: 0, col: 0), player: .black)

        let result = board.applyingMove(invalidMove)

        #expect(result == nil)
    }

    @Test("Board immutability")
    func testBoardImmutability() {
        let originalBoard = Board.initial
        let move = Move(position: BoardPosition(row: 2, col: 3), player: .black)

        _ = originalBoard.applyingMove(move)

        // Original board should remain unchanged
        #expect(originalBoard.score == Score.initial)
        #expect(originalBoard[BoardPosition(row: 2, col: 3)] == .empty)
        #expect(originalBoard[BoardPosition(row: 3, col: 3)] == .white)
    }

    @Test("Board equality")
    func testBoardEquality() {
        let board1 = Board.initial
        let board2 = Board.initial
        let board3 = Board()

        #expect(board1 == board2)
        #expect(board1 != board3)
    }

    @Test("Board description includes visual representation")
    func testBoardDescription() {
        let board = Board.initial
        let description = board.description

        #expect(description.contains("A B C D E F G H"))
        #expect(description.contains("●")) // Black piece symbol
        #expect(description.contains("○")) // White piece symbol
        #expect(description.contains("·")) // Empty cell symbol
    }
}
