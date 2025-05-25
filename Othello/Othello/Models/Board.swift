//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Represents an 8x8 Othello board with immutable operations
struct Board: Hashable, Codable {
    private var cells: [[CellState]]

    /// Creates a new board with the specified cell configuration
    /// - Parameter cells: 8x8 array of cell states
    private init(cells: [[CellState]]) {
        self.cells = cells
    }

    /// Creates an empty board
    init() {
        self.cells = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
    }

    /// Access cell state at a given position
    /// - Parameter position: The board position
    /// - Returns: The cell state at that position
    subscript(position: BoardPosition) -> CellState {
        guard position.isValid else { return .empty }
        return cells[position.row][position.col]
    }

    /// Access cell state using row and column indices
    /// - Parameters:
    ///   - row: Row index (0-7)
    ///   - col: Column index (0-7)
    /// - Returns: The cell state at that position
    subscript(row: Int, col: Int) -> CellState {
        return self[BoardPosition(row: row, col: col)]
    }

    /// Creates a new board with a piece placed at the specified position
    /// - Parameters:
    ///   - state: The cell state to place
    ///   - position: The position to place it
    /// - Returns: New board with the piece placed
    func placing(_ state: CellState, at position: BoardPosition) -> Board {
        guard position.isValid else { return self }

        var newCells = cells
        newCells[position.row][position.col] = state
        return Board(cells: newCells)
    }

    /// Creates a new board with multiple pieces placed
    /// - Parameter placements: Dictionary of positions and their new states
    /// - Returns: New board with all pieces placed
    func placing(_ placements: [BoardPosition: CellState]) -> Board {
        var newCells = cells

        for (position, state) in placements {
            guard position.isValid else { continue }
            newCells[position.row][position.col] = state
        }

        return Board(cells: newCells)
    }

    /// All positions on the board
    var allPositions: [BoardPosition] {
        return BoardPosition.allPositions
    }

    /// All positions containing pieces of the specified state
    /// - Parameter state: The cell state to find
    /// - Returns: Array of positions with that state
    func positions(with state: CellState) -> [BoardPosition] {
        return allPositions.filter { self[$0] == state }
    }

    /// All empty positions on the board
    var emptyPositions: [BoardPosition] {
        return positions(with: .empty)
    }

    /// Count of pieces for each player
    var score: Score {
        let blackCount = positions(with: .black).count
        let whiteCount = positions(with: .white).count
        return Score(black: blackCount, white: whiteCount)
    }

    /// Whether the board is full (no empty cells)
    var isFull: Bool {
        return emptyPositions.isEmpty
    }

    /// Whether the board is empty (no pieces)
    var isEmpty: Bool {
        return score.total == 0
    }

    /// Get all positions in a direction from a starting position
    /// - Parameters:
    ///   - start: Starting position
    ///   - rowDirection: Row direction (-1, 0, 1)
    ///   - colDirection: Column direction (-1, 0, 1)
    /// - Returns: Array of positions in that direction
    func positions(from start: BoardPosition,
                   rowDirection: Int,
                   colDirection: Int) -> [BoardPosition] {
        var positions: [BoardPosition] = []
        var current = start

        while let next = current.offset(row: rowDirection, col: colDirection) {
            positions.append(next)
            current = next
        }

        return positions
    }

    /// Find pieces that would be captured by placing a piece at the given position
    /// - Parameters:
    ///   - position: Position to place the piece
    ///   - player: Player making the move
    /// - Returns: Array of positions that would be captured
    func capturedPositions(placing player: Player, at position: BoardPosition) -> [BoardPosition] {
        guard position.isValid && self[position] == .empty else { return [] }

        var captured: [BoardPosition] = []
        let playerState = player.cellState
        let opponentState = player.opposite.cellState

        // Check all eight directions
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

        for (rowDir, colDir) in directions {
            let positionsInDirection = positions(from: position, rowDirection: rowDir, colDirection: colDir)

            var candidatesForCapture: [BoardPosition] = []

            for pos in positionsInDirection {
                let cellState = self[pos]

                if cellState == opponentState {
                    candidatesForCapture.append(pos)
                } else if cellState == playerState && !candidatesForCapture.isEmpty {
                    // Found our piece after opponent pieces - capture them
                    captured.append(contentsOf: candidatesForCapture)
                    break
                } else {
                    // Empty cell or our piece without opponents in between
                    break
                }
            }
        }

        return captured
    }

    /// Check if placing a piece at the given position would be a valid move
    /// - Parameters:
    ///   - position: Position to check
    ///   - player: Player making the move
    /// - Returns: True if the move is valid
    func isValidMove(at position: BoardPosition, for player: Player) -> Bool {
        guard position.isValid && self[position] == .empty else { return false }
        return !capturedPositions(placing: player, at: position).isEmpty
    }

    /// Get all valid moves for a player
    /// - Parameter player: The player to get moves for
    /// - Returns: Array of valid positions for moves
    func validMoves(for player: Player) -> [BoardPosition] {
        return emptyPositions.filter { isValidMove(at: $0, for: player) }
    }

    /// Apply a move to the board, returning the new board and captured positions
    /// - Parameter move: The move to apply
    /// - Returns: Tuple of new board and captured positions, or nil if invalid
    func applyingMove(_ move: Move) -> (board: Board, captured: [BoardPosition])? {
        let captured = capturedPositions(placing: move.player, at: move.position)
        guard !captured.isEmpty else { return nil }

        var placements: [BoardPosition: CellState] = [:]
        placements[move.position] = move.player.cellState

        for capturedPos in captured {
            placements[capturedPos] = move.player.cellState
        }

        let newBoard = placing(placements)
        return (newBoard, captured)
    }
}

// MARK: - Static Factory Methods

extension Board {
    /// Standard starting position for Othello
    static var initial: Board {
        var board = Board()
        board = board.placing(.white, at: BoardPosition(row: 3, col: 3))
        board = board.placing(.black, at: BoardPosition(row: 3, col: 4))
        board = board.placing(.black, at: BoardPosition(row: 4, col: 3))
        board = board.placing(.white, at: BoardPosition(row: 4, col: 4))
        return board
    }

    /// Empty board with no pieces
    static var empty: Board {
        return Board()
    }
}

// MARK: - Description and Debugging

extension Board: CustomStringConvertible {
    var description: String {
        var result = "  A B C D E F G H\n"

        for row in 0..<8 {
            result += "\(8 - row) "
            for col in 0..<8 {
                let cellState = self[row, col]
                let symbol = switch cellState {
                case .empty: "·"
                case .black: "●"
                case .white: "○"
                }
                result += "\(symbol) "
            }
            result += "\(8 - row)\n"
        }

        result += "  A B C D E F G H"
        return result
    }
}

extension Board: CustomDebugStringConvertible {
    var debugDescription: String {
        let score = self.score
        return """
        Board (Black: \(score.black), White: \(score.white)):
        \(description)
        """
    }
}
