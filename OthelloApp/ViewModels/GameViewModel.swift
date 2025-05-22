import SwiftUI
import Foundation
import OthelloCore

@MainActor
@Observable
class GameViewModel {
    private let gameEngine: GameEngineProtocol
    
    private(set) var gameState: GameState
    private(set) var validMoves: Set<BoardPosition> = []
    private(set) var isProcessingMove = false
    
    init(gameEngine: GameEngineProtocol = GameEngine()) {
        self.gameEngine = gameEngine
        self.gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        self.updateValidMoves()
    }
    
    func makeMove(at position: BoardPosition) {
        guard !isProcessingMove,
              validMoves.contains(position) else { return }
        
        isProcessingMove = true
        
        let move = Move(position: position, player: gameState.currentPlayer)
        if let newState = gameState.applyingMove(move) {
            gameState = newState
            updateValidMoves()
        }
        
        isProcessingMove = false
    }
    
    func resetGame() {
        gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        updateValidMoves()
        isProcessingMove = false
    }
    
    private func updateValidMoves() {
        validMoves = Set(gameEngine.availableMoves(for: gameState))
    }
    
    var currentPlayerName: String {
        switch gameState.currentPlayer {
        case .black: return "Black"
        case .white: return "White"
        }
    }
    
    var gameStatusMessage: String {
        switch gameState.gamePhase {
        case .playing:
            return "\(currentPlayerName)'s turn"
        case .finished:
            let winner = gameEngine.winner(of: gameState)
            switch winner {
            case .black: return "Black wins!"
            case .white: return "White wins!"
            case .none: return "It's a tie!"
            }
        }
    }
}
