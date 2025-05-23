//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Represents the state of a cell on the Othello board
enum CellState: String, CaseIterable, Codable {
    case empty
    case black
    case white

    /// The opposite piece color, or nil for empty cells
    var opposite: CellState? {
        switch self {
        case .empty: return nil
        case .black: return .white
        case .white: return .black
        }
    }

    /// Whether this cell contains a piece (not empty)
    var hasPiece: Bool {
        return self != .empty
    }

    /// Human-readable description
    var description: String {
        switch self {
        case .empty: return "Empty"
        case .black: return "Black"
        case .white: return "White"
        }
    }

    /// Accessibility description for screen readers
    var accessibilityDescription: String {
        switch self {
        case .empty: return "Empty cell"
        case .black: return "Black piece"
        case .white: return "White piece"
        }
    }

    /// Localized description for UI display
    var localizedDescription: String {
        switch self {
        case .empty:
            return NSLocalizedString("cell.state.empty", comment: "Empty cell")
        case .black:
            return NSLocalizedString("cell.state.black", comment: "Black piece")
        case .white:
            return NSLocalizedString("cell.state.white", comment: "White piece")
        }
    }
}
