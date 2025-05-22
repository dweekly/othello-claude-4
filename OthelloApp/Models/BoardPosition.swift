import Foundation

/// Represents a position on the Othello board
///
/// BoardPosition uses zero-based indexing where (0,0) represents the top-left corner
/// and (7,7) represents the bottom-right corner of the standard 8x8 Othello board.
public struct BoardPosition: Hashable, Codable {
    public let row: Int
    public let col: Int

    /// Creates a new board position
    /// - Parameters:
    ///   - row: Row index (0-7)
    ///   - col: Column index (0-7)
    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    /// Whether this position is within the valid 8x8 board bounds
    public var isValid: Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }

    /// Human-readable description of the position (e.g., "A1", "H8")
    public var algebraicNotation: String {
        guard isValid else { return "Invalid" }
        let columnLetter = String(Character(UnicodeScalar(65 + col)!)) // A-H
        let rowNumber = String(8 - row) // 1-8 (flipped because row 0 is top)
        return "\(columnLetter)\(rowNumber)"
    }

    /// Accessibility description for screen readers
    public var accessibilityDescription: String {
        guard isValid else { return "Invalid position" }
        return "Row \(row + 1), Column \(col + 1)"
    }
}

// MARK: - Extensions

extension BoardPosition: CustomStringConvertible {
    public var description: String {
        return "(\(row), \(col))"
    }
}

extension BoardPosition: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "BoardPosition(row: \(row), col: \(col)) [\(algebraicNotation)]"
    }
}

// MARK: - Static Factory Methods

extension BoardPosition {
    /// Creates a board position from algebraic notation (e.g., "A1", "H8")
    /// - Parameter notation: Algebraic notation string
    /// - Returns: BoardPosition if valid, nil otherwise
    public static func from(algebraicNotation notation: String) -> BoardPosition? {
        guard notation.count == 2 else { return nil }

        let characters = Array(notation.uppercased())
        guard let columnChar = characters.first,
              let rowChar = characters.last else { return nil }

        // Convert column letter (A-H) to index (0-7)
        guard let columnScalar = columnChar.unicodeScalars.first,
              columnScalar.value >= 65 && columnScalar.value <= 72 else { return nil }
        let col = Int(columnScalar.value - 65)

        // Convert row number (1-8) to index (7-0, flipped)
        guard let rowNumber = Int(String(rowChar)),
              rowNumber >= 1 && rowNumber <= 8 else { return nil }
        let row = 8 - rowNumber

        let position = BoardPosition(row: row, col: col)
        return position.isValid ? position : nil
    }

    /// All valid positions on the board in row-major order
    public static var allPositions: [BoardPosition] {
        var positions: [BoardPosition] = []
        for row in 0..<8 {
            for col in 0..<8 {
                positions.append(BoardPosition(row: row, col: col))
            }
        }
        return positions
    }
}

// MARK: - Direction Helpers

extension BoardPosition {
    /// All eight possible directions from this position
    public var adjacentDirections: [BoardPosition] {
        return [
            BoardPosition(row: row - 1, col: col - 1), // Northwest
            BoardPosition(row: row - 1, col: col),     // North
            BoardPosition(row: row - 1, col: col + 1), // Northeast
            BoardPosition(row: row, col: col - 1),     // West
            BoardPosition(row: row, col: col + 1),     // East
            BoardPosition(row: row + 1, col: col - 1), // Southwest
            BoardPosition(row: row + 1, col: col),     // South
            BoardPosition(row: row + 1, col: col + 1)  // Southeast
        ].filter { $0.isValid }
    }

    /// Returns position in the specified direction, or nil if invalid
    /// - Parameters:
    ///   - rowOffset: Row direction (-1, 0, 1)
    ///   - colOffset: Column direction (-1, 0, 1)
    /// - Returns: New position or nil if out of bounds
    public func offset(row rowOffset: Int, col colOffset: Int) -> BoardPosition? {
        let newPosition = BoardPosition(row: row + rowOffset, col: col + colOffset)
        return newPosition.isValid ? newPosition : nil
    }
}
