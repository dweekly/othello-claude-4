import Foundation

/// Represents the current score of an Othello game
public struct Score: Hashable, Codable {
    public let black: Int
    public let white: Int

    /// Creates a new score
    /// - Parameters:
    ///   - black: Number of black pieces
    ///   - white: Number of white pieces
    public init(black: Int, white: Int) {
        self.black = max(0, black)
        self.white = max(0, white)
    }

    /// Total number of pieces on the board
    public var total: Int {
        return black + white
    }

    /// The player currently in the lead, or nil if tied
    public var leader: Player? {
        if black > white {
            return .black
        } else if white > black {
            return .white
        } else {
            return nil
        }
    }

    /// The score difference (positive means black is winning)
    public var difference: Int {
        return black - white
    }

    /// Whether the game is tied
    public var isTied: Bool {
        return black == white
    }

    /// Score for a specific player
    /// - Parameter player: The player to get the score for
    /// - Returns: The score for that player
    public func score(for player: Player) -> Int {
        switch player {
        case .black: return black
        case .white: return white
        }
    }

    /// Creates a new score with updated values for a player
    /// - Parameters:
    ///   - player: The player to update
    ///   - newScore: The new score for that player
    /// - Returns: New Score instance with updated value
    public func updating(player: Player, to newScore: Int) -> Score {
        switch player {
        case .black:
            return Score(black: newScore, white: white)
        case .white:
            return Score(black: black, white: newScore)
        }
    }

    /// Formatted string for display
    public var displayString: String {
        return String(format: NSLocalizedString("score.display.format",
                                              comment: "Score display format"),
                     black, white)
    }

    /// Accessibility description
    public var accessibilityDescription: String {
        if isTied {
            return String(format: NSLocalizedString("score.accessibility.tied",
                                                  comment: "Score tied accessibility"),
                         total)
        } else if let leader = leader {
            let leadAmount = abs(difference)
            return String(format: NSLocalizedString("score.accessibility.leading",
                                                  comment: "Score leading accessibility"),
                         leader.localizedName, leadAmount)
        } else {
            return String(format: NSLocalizedString("score.accessibility.basic",
                                                  comment: "Basic score accessibility"),
                         black, white)
        }
    }
}

// MARK: - Extensions

extension Score: CustomStringConvertible {
    public var description: String {
        return "Black: \(black), White: \(white)"
    }
}

extension Score: CustomDebugStringConvertible {
    public var debugDescription: String {
        let leaderInfo = leader?.name ?? "Tied"
        return "Score(black: \(black), white: \(white), leader: \(leaderInfo))"
    }
}

// MARK: - Static Factory Methods

extension Score {
    /// Starting score for a new Othello game
    public static var initial: Score {
        return Score(black: 2, white: 2)
    }

    /// Empty score (no pieces on board)
    public static var zero: Score {
        return Score(black: 0, white: 0)
    }

    /// Maximum possible score (one player has all 64 squares)
    public static var maximum: Score {
        return Score(black: 64, white: 0)
    }
}

// MARK: - Score Comparison

extension Score: Comparable {
    /// Compare scores based on the leading player and margin
    public static func < (lhs: Score, rhs: Score) -> Bool {
        if lhs.black != rhs.black {
            return lhs.black < rhs.black
        }
        return lhs.white < rhs.white
    }
}
