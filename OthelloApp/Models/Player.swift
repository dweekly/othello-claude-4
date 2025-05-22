import Foundation

/// Represents a player in the Othello game
public enum Player: String, CaseIterable, Codable {
    case black = "black"
    case white = "white"

    /// The opposite player
    public var opposite: Player {
        switch self {
        case .black: return .white
        case .white: return .black
        }
    }

    /// The cell state corresponding to this player's pieces
    public var cellState: CellState {
        switch self {
        case .black: return .black
        case .white: return .white
        }
    }

    /// Human-readable name
    public var name: String {
        switch self {
        case .black: return "Black"
        case .white: return "White"
        }
    }

    /// Localized name for UI display
    public var localizedName: String {
        switch self {
        case .black:
            return NSLocalizedString("player.black", comment: "Black player")
        case .white:
            return NSLocalizedString("player.white", comment: "White player")
        }
    }

    /// Accessibility description for screen readers
    public var accessibilityDescription: String {
        switch self {
        case .black:
            return NSLocalizedString("accessibility.player.black", comment: "Black player accessibility")
        case .white:
            return NSLocalizedString("accessibility.player.white", comment: "White player accessibility")
        }
    }
}

// MARK: - Player Type Extensions

/// Represents the type of player (human or AI)
public enum PlayerType: String, CaseIterable, Codable {
    case human = "human"
    case ai = "ai"

    /// Localized name for UI display
    public var localizedName: String {
        switch self {
        case .human:
            return NSLocalizedString("player.type.human", comment: "Human player")
        case .ai:
            return NSLocalizedString("player.type.ai", comment: "AI player")
        }
    }
}

/// Complete player information including type and difficulty (for AI)
public struct PlayerInfo: Codable, Hashable {
    public let player: Player
    public let type: PlayerType
    public let aiDifficulty: AIDifficulty?

    public init(player: Player, type: PlayerType, aiDifficulty: AIDifficulty? = nil) {
        self.player = player
        self.type = type
        self.aiDifficulty = type == .ai ? aiDifficulty : nil
    }

    /// Whether this is a human player
    public var isHuman: Bool {
        return type == .human
    }

    /// Whether this is an AI player
    public var isAI: Bool {
        return type == .ai
    }

    /// Display name including type and difficulty
    public var displayName: String {
        switch type {
        case .human:
            return player.localizedName
        case .ai:
            let difficulty = aiDifficulty?.localizedName ?? "Unknown"
            return "\(player.localizedName) (\(difficulty) AI)"
        }
    }
}

/// AI difficulty levels
public enum AIDifficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"

    /// Localized name for UI display
    public var localizedName: String {
        switch self {
        case .easy:
            return NSLocalizedString("ai.difficulty.easy", comment: "Easy AI difficulty")
        case .medium:
            return NSLocalizedString("ai.difficulty.medium", comment: "Medium AI difficulty")
        case .hard:
            return NSLocalizedString("ai.difficulty.hard", comment: "Hard AI difficulty")
        }
    }

    /// Detailed description of the AI behavior
    public var description: String {
        switch self {
        case .easy:
            return NSLocalizedString("ai.difficulty.easy.description",
                                   comment: "Easy AI makes random moves")
        case .medium:
            return NSLocalizedString("ai.difficulty.medium.description",
                                   comment: "Medium AI uses basic strategy")
        case .hard:
            return NSLocalizedString("ai.difficulty.hard.description",
                                   comment: "Hard AI uses advanced algorithms")
        }
    }

    /// Search depth for minimax algorithm
    public var searchDepth: Int {
        switch self {
        case .easy: return 1
        case .medium: return 3
        case .hard: return 6
        }
    }

    /// Thinking time range in seconds
    public var thinkingTimeRange: ClosedRange<Double> {
        switch self {
        case .easy: return 0.5...1.5
        case .medium: return 1.0...3.0
        case .hard: return 2.0...5.0
        }
    }
}
