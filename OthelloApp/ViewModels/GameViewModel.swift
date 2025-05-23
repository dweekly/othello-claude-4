//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
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
    private(set) var lastInvalidMovePosition: BoardPosition?
    var showingInvalidMoveAlert = false
    var showingGameCompletionAlert = false
    var showingNewGameConfirmation = false

    init(gameEngine: GameEngineProtocol = GameEngine()) {
        self.gameEngine = gameEngine
        self.gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        self.updateValidMoves()
    }

    func makeMove(at position: BoardPosition) {
        guard !isProcessingMove else { return }

        // Clear any previous invalid move indicators
        lastInvalidMovePosition = nil

        guard validMoves.contains(position) else {
            // Handle invalid move
            lastInvalidMovePosition = position
            showingInvalidMoveAlert = true

            // Provide haptic feedback for invalid move
            #if canImport(UIKit)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif

            // Clear the invalid move indicator after a delay
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                lastInvalidMovePosition = nil
            }
            return
        }

        isProcessingMove = true

        let move = Move(position: position, player: gameState.currentPlayer)
        if let newState = gameState.applyingMove(move) {
            gameState = newState
            updateValidMoves()

            // Provide haptic feedback for valid move
            #if canImport(UIKit)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            #endif

            // Check if game just finished
            if gameState.gamePhase == .finished {
                showingGameCompletionAlert = true
            }
        }

        isProcessingMove = false
    }

    func requestNewGame() {
        if gameState.gamePhase == .playing {
            showingNewGameConfirmation = true
        } else {
            confirmNewGame()
        }
    }

    func confirmNewGame() {
        gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        updateValidMoves()
        isProcessingMove = false
        lastInvalidMovePosition = nil
        showingInvalidMoveAlert = false
        showingGameCompletionAlert = false
        showingNewGameConfirmation = false
    }

    func dismissInvalidMoveAlert() {
        showingInvalidMoveAlert = false
    }

    func dismissGameCompletionAlert() {
        showingGameCompletionAlert = false
    }

    func dismissNewGameConfirmation() {
        showingNewGameConfirmation = false
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

    var gameCompletionMessage: String {
        let winner = gameEngine.winner(of: gameState)
        let blackScore = gameState.score.black
        let whiteScore = gameState.score.white

        switch winner {
        case .black:
            return "Black wins with \(blackScore) pieces!\nWhite had \(whiteScore) pieces."
        case .white:
            return "White wins with \(whiteScore) pieces!\nBlack had \(blackScore) pieces."
        case .none:
            return "It's a tie! Both players have \(blackScore) pieces."
        }
    }
}
