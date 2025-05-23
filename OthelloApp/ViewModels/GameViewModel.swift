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
    private let aiService: AIServiceProtocol

    private(set) var gameState: GameState
    private(set) var validMoves: Set<BoardPosition> = []
    private(set) var isProcessingMove = false
    private(set) var isAIThinking = false
    var showingGameCompletionAlert = false
    var showingNewGameConfirmation = false

    init(gameEngine: GameEngineProtocol = GameEngine(), aiService: AIServiceProtocol = AIService()) {
        self.gameEngine = gameEngine
        self.aiService = aiService
        self.gameState = gameEngine.newGame(
            blackPlayer: PlayerInfo(player: .black, type: .human),
            whitePlayer: PlayerInfo(player: .white, type: .human)
        )
        self.updateValidMoves()
    }

    func makeMove(at position: BoardPosition) {
        guard !isProcessingMove && !isAIThinking else { return }
        
        // Simply ignore invalid moves - no popup or feedback
        guard validMoves.contains(position) else { return }

        isProcessingMove = true

        let move = Move(position: position, player: gameState.currentPlayer)
        if let newState = gameState.applyingMove(move) {
            let nextState = gameEngine.nextTurn(from: newState)
            gameState = nextState
            updateValidMoves()

            // Provide haptic feedback for valid move
            #if canImport(UIKit)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            #endif

            // Check if game just finished
            if gameState.gamePhase == .finished {
                showingGameCompletionAlert = true
            } else {
                // Check if it's now an AI player's turn
                processNextPlayerTurn()
            }
        }

        isProcessingMove = false
    }
    
    private func processNextPlayerTurn() {
        // Prevent recursion and ensure we're still playing
        guard gameState.gamePhase == .playing && !isAIThinking else { return }
        
        let currentPlayerInfo = gameState.currentPlayer == .black ? 
            gameState.blackPlayerInfo : gameState.whitePlayerInfo
        
        if currentPlayerInfo.isAI {
            Task {
                await makeAIMove()
            }
        }
    }
    
    private func makeAIMove() async {
        guard gameState.gamePhase == .playing && !isAIThinking else { return }
        
        isAIThinking = true
        
        let currentPlayerInfo = gameState.currentPlayer == .black ? 
            gameState.blackPlayerInfo : gameState.whitePlayerInfo
        
        if let aiMove = await aiService.calculateMove(
            for: gameState,
            playerInfo: currentPlayerInfo,
            using: gameEngine
        ) {
            // Apply the AI move
            if let newState = gameState.applyingMove(aiMove) {
                let nextState = gameEngine.nextTurn(from: newState)
                gameState = nextState
                updateValidMoves()
                
                // Provide haptic feedback for AI move
                #if canImport(UIKit)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                #endif
                
                // Check if game just finished
                if gameState.gamePhase == .finished {
                    showingGameCompletionAlert = true
                } else {
                    // Check if the next player is also AI
                    processNextPlayerTurn()
                }
            }
        }
        
        isAIThinking = false
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
        isAIThinking = false
        showingGameCompletionAlert = false
        showingNewGameConfirmation = false
        
        // Cancel any ongoing AI calculation
        aiService.cancelCalculation()
        
        // Start AI move if black player is AI
        processNextPlayerTurn()
    }
    
    func startNewGame(blackPlayer: PlayerInfo, whitePlayer: PlayerInfo) {
        gameState = gameEngine.newGame(
            blackPlayer: blackPlayer,
            whitePlayer: whitePlayer
        )
        updateValidMoves()
        isProcessingMove = false
        isAIThinking = false
        showingGameCompletionAlert = false
        showingNewGameConfirmation = false
        
        // Cancel any ongoing AI calculation
        aiService.cancelCalculation()
        
        // Start AI move if black player is AI
        processNextPlayerTurn()
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
        let playerInfo = gameState.currentPlayer == .black ? 
            gameState.blackPlayerInfo : gameState.whitePlayerInfo
        return playerInfo.displayName
    }

    var gameStatusMessage: String {
        switch gameState.gamePhase {
        case .playing:
            if isAIThinking {
                return "\(currentPlayerName) is thinking..."
            } else {
                return "\(currentPlayerName)'s turn"
            }
        case .finished:
            let winner = gameEngine.winner(of: gameState)
            let blackPlayerInfo = gameState.blackPlayerInfo
            let whitePlayerInfo = gameState.whitePlayerInfo
            
            switch winner {
            case .black: return "\(blackPlayerInfo.displayName) wins!"
            case .white: return "\(whitePlayerInfo.displayName) wins!"
            case .none: return "It's a tie!"
            }
        }
    }

    var gameCompletionMessage: String {
        let winner = gameEngine.winner(of: gameState)
        let blackScore = gameState.score.black
        let whiteScore = gameState.score.white
        let blackPlayerInfo = gameState.blackPlayerInfo
        let whitePlayerInfo = gameState.whitePlayerInfo

        switch winner {
        case .black:
            return "\(blackPlayerInfo.displayName) wins with \(blackScore) pieces!\n\(whitePlayerInfo.displayName) had \(whiteScore) pieces."
        case .white:
            return "\(whitePlayerInfo.displayName) wins with \(whiteScore) pieces!\n\(blackPlayerInfo.displayName) had \(blackScore) pieces."
        case .none:
            return "It's a tie! Both players have \(blackScore) pieces."
        }
    }
}
