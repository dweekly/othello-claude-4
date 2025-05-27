import Foundation

enum GameMode {
    case humanVsHuman
    case humanVsAI(difficulty: AIDifficulty)
    
    var blackPlayerType: PlayerType {
        .human
    }
    
    var whitePlayerType: PlayerType {
        switch self {
        case .humanVsHuman:
            return .human
        case .humanVsAI:
            return .artificial
        }
    }
    
    var aiDifficulty: AIDifficulty? {
        switch self {
        case .humanVsHuman:
            return nil
        case .humanVsAI(let difficulty):
            return difficulty
        }
    }
}