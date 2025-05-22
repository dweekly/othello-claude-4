import Foundation

/// Represents a move in the Othello game
public struct Move: Hashable, Codable {
    public let position: BoardPosition
    public let player: Player
    public let timestamp: Date

    /// Creates a new move
    /// - Parameters:
    ///   - position: The board position for this move
    ///   - player: The player making the move
    ///   - timestamp: When the move was made (defaults to now)
    public init(position: BoardPosition, player: Player, timestamp: Date = Date()) {
        self.position = position
        self.player = player
        self.timestamp = timestamp
    }

    /// Convenience initializer for creating moves with current timestamp
    /// - Parameters:
    ///   - row: Row index (0-7)
    ///   - col: Column index (0-7)
    ///   - player: The player making the move
    public init(row: Int, col: Int, player: Player) {
        self.init(position: BoardPosition(row: row, col: col), player: player)
    }

    /// Whether this is a valid position on the board
    public var isValidPosition: Bool {
        return position.isValid
    }

    /// Algebraic notation representation (e.g., "Black A1")
    public var notation: String {
        return "\(player.name) \(position.algebraicNotation)"
    }

    /// Accessibility description for screen readers
    public var accessibilityDescription: String {
        return "\(player.accessibilityDescription) move at \(position.accessibilityDescription)"
    }
}

// MARK: - Extensions

extension Move: CustomStringConvertible {
    public var description: String {
        return notation
    }
}

extension Move: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Move(\(player.rawValue) at \(position.debugDescription), \(timestamp))"
    }
}

// MARK: - Move Result

/// Represents the result of applying a move to the game board
public struct MoveResult: Codable {
    public let move: Move
    public let capturedPositions: [BoardPosition]
    public let newGameState: GameState

    public init(move: Move, capturedPositions: [BoardPosition], newGameState: GameState) {
        self.move = move
        self.capturedPositions = capturedPositions
        self.newGameState = newGameState
    }

    /// Number of pieces captured by this move
    public var captureCount: Int {
        return capturedPositions.count
    }

    /// Whether this move captured any pieces
    public var didCapture: Bool {
        return !capturedPositions.isEmpty
    }

    /// Accessibility announcement for the move result
    public var accessibilityAnnouncement: String {
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
public struct MoveHistory: Codable, Hashable {
    private var moves: [Move] = []

    public init() {}

    /// All moves in chronological order
    public var allMoves: [Move] {
        return moves
    }

    /// Number of moves played
    public var count: Int {
        return moves.count
    }

    /// Whether any moves have been played
    public var isEmpty: Bool {
        return moves.isEmpty
    }

    /// The most recent move, if any
    public var lastMove: Move? {
        return moves.last
    }

    /// Add a move to the history
    /// - Parameter move: The move to add
    public mutating func addMove(_ move: Move) {
        moves.append(move)
    }

    /// Get move at specific index
    /// - Parameter index: The index of the move
    /// - Returns: The move at that index, or nil if out of bounds
    public func move(at index: Int) -> Move? {
        guard index >= 0 && index < moves.count else { return nil }
        return moves[index]
    }

    /// Get all moves by a specific player
    /// - Parameter player: The player to filter by
    /// - Returns: Array of moves by that player
    public func moves(by player: Player) -> [Move] {
        return moves.filter { $0.player == player }
    }

    /// Clear all moves
    public mutating func clear() {
        moves.removeAll()
    }
}
