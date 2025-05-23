//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Represents a move in the Othello game
struct Move: Hashable, Codable {
    let position: BoardPosition
    let player: Player
    let timestamp: Date

    /// Creates a new move
    /// - Parameters:
    ///   - position: The board position for this move
    ///   - player: The player making the move
    ///   - timestamp: When the move was made (defaults to now)
    init(position: BoardPosition, player: Player, timestamp: Date = Date()) {
        self.position = position
        self.player = player
        self.timestamp = timestamp
    }

    /// Convenience initializer for creating moves with current timestamp
    /// - Parameters:
    ///   - row: Row index (0-7)
    ///   - col: Column index (0-7)
    ///   - player: The player making the move
    init(row: Int, col: Int, player: Player) {
        self.init(position: BoardPosition(row: row, col: col), player: player)
    }

    /// Whether this is a valid position on the board
    var isValidPosition: Bool {
        return position.isValid
    }

    /// Algebraic notation representation (e.g., "Black A1")
    var notation: String {
        return "\(player.name) \(position.algebraicNotation)"
    }

    /// Accessibility description for screen readers
    var accessibilityDescription: String {
        return "\(player.accessibilityDescription) move at \(position.accessibilityDescription)"
    }
}

// MARK: - Extensions

extension Move: CustomStringConvertible {
    var description: String {
        return notation
    }
}

extension Move: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Move(\(player.rawValue) at \(position.debugDescription), \(timestamp))"
    }
}

// MARK: - Move Result

/// Represents the result of applying a move to the game board
struct MoveResult: Codable {
    let move: Move
    let capturedPositions: [BoardPosition]
    let newGameState: GameState

    init(move: Move, capturedPositions: [BoardPosition], newGameState: GameState) {
        self.move = move
        self.capturedPositions = capturedPositions
        self.newGameState = newGameState
    }

    /// Number of pieces captured by this move
    var captureCount: Int {
        return capturedPositions.count
    }

    /// Whether this move captured any pieces
    var didCapture: Bool {
        return !capturedPositions.isEmpty
    }

    /// Accessibility announcement for the move result
    var accessibilityAnnouncement: String {
        if captureCount == 0 {
            return "\(move.player.localizedName) placed piece at \(move.position.accessibilityDescription)"
        } else if captureCount == 1 {
            return "\(move.player.localizedName) captured 1 piece"
        } else {
            return "\(move.player.localizedName) captured \(captureCount) pieces"
        }
    }
}

// MARK: - Move History

/// Maintains a history of moves in the game
struct MoveHistory: Codable, Hashable {
    private var moves: [Move] = []

    init() {}

    /// All moves in chronological order
    var allMoves: [Move] {
        return moves
    }

    /// Number of moves played
    var count: Int {
        return moves.count
    }

    /// Whether any moves have been played
    var isEmpty: Bool {
        return moves.isEmpty
    }

    /// The most recent move, if any
    var lastMove: Move? {
        return moves.last
    }

    /// Add a move to the history
    /// - Parameter move: The move to add
    mutating func addMove(_ move: Move) {
        moves.append(move)
    }

    /// Get move at specific index
    /// - Parameter index: The index of the move
    /// - Returns: The move at that index, or nil if out of bounds
    func move(at index: Int) -> Move? {
        guard index >= 0 && index < moves.count else { return nil }
        return moves[index]
    }

    /// Get all moves by a specific player
    /// - Parameter player: The player to filter by
    /// - Returns: Array of moves by that player
    func moves(by player: Player) -> [Move] {
        return moves.filter { $0.player == player }
    }

    /// Clear all moves
    mutating func clear() {
        moves.removeAll()
    }
}
