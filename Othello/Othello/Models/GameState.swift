//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Foundation

/// Represents the complete state of an Othello game
struct GameState: Hashable, Codable {
    let board: Board
    let currentPlayer: Player
    let gamePhase: GamePhase
    let moveHistory: MoveHistory
    let blackPlayerInfo: PlayerInfo
    let whitePlayerInfo: PlayerInfo
    let gameId: UUID
    let startTime: Date

    /// Creates a new game state
    /// - Parameters:
    ///   - board: The current board state
    ///   - currentPlayer: The player whose turn it is
    ///   - gamePhase: The current phase of the game
    ///   - moveHistory: History of moves played
    ///   - blackPlayerInfo: Information about the black player
    ///   - whitePlayerInfo: Information about the white player
    ///   - gameId: Unique identifier for this game
    ///   - startTime: When the game started
    init(board: Board,
         currentPlayer: Player,
         gamePhase: GamePhase,
         moveHistory: MoveHistory = MoveHistory(),
         blackPlayerInfo: PlayerInfo,
         whitePlayerInfo: PlayerInfo,
         gameId: UUID = UUID(),
         startTime: Date = Date()) {
        self.board = board
        self.currentPlayer = currentPlayer
        self.gamePhase = gamePhase
        self.moveHistory = moveHistory
        self.blackPlayerInfo = blackPlayerInfo
        self.whitePlayerInfo = whitePlayerInfo
        self.gameId = gameId
        self.startTime = startTime
    }

    /// Current score based on board state
    var score: Score {
        return board.score
    }

    /// Valid moves for the current player
    var availableMoves: [BoardPosition] {
        guard gamePhase == .playing else { return [] }
        return board.validMoves(for: currentPlayer)
    }

    /// Whether the current player has any valid moves
    var hasValidMoves: Bool {
        return !availableMoves.isEmpty
    }

    /// Whether the game is over (no valid moves for either player)
    var isGameOver: Bool {
        return gamePhase == .finished
    }

    /// The winning player, or nil if game is ongoing or tied
    var winner: Player? {
        guard isGameOver else { return nil }
        return score.leader
    }

    /// Whether the game ended in a tie
    var isTied: Bool {
        return isGameOver && score.isTied
    }

    /// Information about the current player
    var currentPlayerInfo: PlayerInfo {
        return playerInfo(for: currentPlayer)
    }

    /// Whether the current player is human
    var isCurrentPlayerHuman: Bool {
        return currentPlayerInfo.isHuman
    }

    /// Whether the current player is AI
    var isCurrentPlayerAI: Bool {
        return currentPlayerInfo.isAI
    }

    /// Get player information for a specific player
    /// - Parameter player: The player to get info for
    /// - Returns: PlayerInfo for that player
    func playerInfo(for player: Player) -> PlayerInfo {
        switch player {
        case .black: return blackPlayerInfo
        case .white: return whitePlayerInfo
        }
    }

    /// Number of moves played in the game
    var moveCount: Int {
        return moveHistory.count
    }

    /// Duration of the game so far
    var gameDuration: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }

    /// Creates a new game state after applying a move
    /// - Parameter move: The move to apply
    /// - Returns: New game state with the move applied, or nil if invalid
    func applyingMove(_ move: Move) -> GameState? {
        guard move.player == currentPlayer,
              gamePhase == .playing,
              let (newBoard, _) = board.applyingMove(move) else {
            return nil
        }

        var newMoveHistory = moveHistory
        newMoveHistory.addMove(move)

        // Determine next player and game phase
        let nextPlayer = move.player.opposite
        let nextPlayerHasMoves = newBoard.validMoves(for: nextPlayer).isEmpty == false
        let currentPlayerHasMoves = newBoard.validMoves(for: move.player).isEmpty == false

        let (newCurrentPlayer, newGamePhase): (Player, GamePhase) = {
            if nextPlayerHasMoves {
                // Next player can move
                return (nextPlayer, .playing)
            } else if currentPlayerHasMoves {
                // Next player can't move, but current player can continue
                return (move.player, .playing)
            } else {
                // Neither player can move - game over
                return (move.player, .finished)
            }
        }()

        return GameState(
            board: newBoard,
            currentPlayer: newCurrentPlayer,
            gamePhase: newGamePhase,
            moveHistory: newMoveHistory,
            blackPlayerInfo: blackPlayerInfo,
            whitePlayerInfo: whitePlayerInfo,
            gameId: gameId,
            startTime: startTime
        )
    }

    /// Creates a new game state with the current player switched
    /// Used when a player has no valid moves but the game continues
    /// - Returns: New game state with switched player
    func switchingPlayer() -> GameState {
        guard gamePhase == .playing else { return self }

        let nextPlayer = currentPlayer.opposite
        let nextPlayerHasMoves = board.validMoves(for: nextPlayer).isEmpty == false

        if nextPlayerHasMoves {
            return GameState(
                board: board,
                currentPlayer: nextPlayer,
                gamePhase: gamePhase,
                moveHistory: moveHistory,
                blackPlayerInfo: blackPlayerInfo,
                whitePlayerInfo: whitePlayerInfo,
                gameId: gameId,
                startTime: startTime
            )
        } else {
            // Neither player can move - game over
            return GameState(
                board: board,
                currentPlayer: currentPlayer,
                gamePhase: .finished,
                moveHistory: moveHistory,
                blackPlayerInfo: blackPlayerInfo,
                whitePlayerInfo: whitePlayerInfo,
                gameId: gameId,
                startTime: startTime
            )
        }
    }

    /// Game result summary for completed games
    var gameResult: GameResult? {
        guard isGameOver else { return nil }

        if let winner = winner {
            return GameResult(
                winner: winner,
                finalScore: score,
                moveCount: moveCount,
                duration: gameDuration,
                gameId: gameId
            )
        } else {
            return GameResult(
                winner: nil,
                finalScore: score,
                moveCount: moveCount,
                duration: gameDuration,
                gameId: gameId
            )
        }
    }
}

// MARK: - Game Phase

/// Represents the current phase of the game
enum GamePhase: String, CaseIterable, Codable {
    case playing
    case finished

    /// Localized description
    var localizedDescription: String {
        switch self {
        case .playing:
            return NSLocalizedString("game.phase.playing", comment: "Game is in progress")
        case .finished:
            return NSLocalizedString("game.phase.finished", comment: "Game is finished")
        }
    }
}

// MARK: - Game Result

/// Represents the final result of a completed game
struct GameResult: Codable, Hashable {
    let winner: Player?
    let finalScore: Score
    let moveCount: Int
    let duration: TimeInterval
    let gameId: UUID
    let timestamp: Date

    init(winner: Player?,
         finalScore: Score,
         moveCount: Int,
         duration: TimeInterval,
         gameId: UUID,
         timestamp: Date = Date()) {
        self.winner = winner
        self.finalScore = finalScore
        self.moveCount = moveCount
        self.duration = duration
        self.gameId = gameId
        self.timestamp = timestamp
    }

    /// Whether the game ended in a tie
    var isTied: Bool {
        return winner == nil
    }

    /// Result description for display
    var description: String {
        if let winner = winner {
            return "\(winner.localizedName) wins \(finalScore.description)"
        } else {
            return "Tie game \(finalScore.description)"
        }
    }

    /// Accessibility announcement for the result
    var accessibilityAnnouncement: String {
        if let winner = winner {
            return "Game over. \(winner.localizedName) wins with \(finalScore.score(for: winner)) pieces."
        } else {
            return "Game over. It's a tie with \(finalScore.total / 2) pieces each."
        }
    }
}

// MARK: - Static Factory Methods

extension GameState {
    /// Standard starting game state for human vs human
    static func newHumanVsHuman() -> GameState {
        return GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )
    }

    /// Starting game state for human vs AI
    /// - Parameters:
    ///   - humanPlayer: Which color the human plays
    ///   - aiDifficulty: AI difficulty level
    /// - Returns: New game state
    static func newHumanVsAI(humanPlayer: Player, aiDifficulty: AIDifficulty) -> GameState {
        _ = humanPlayer.opposite

        let blackPlayerInfo = humanPlayer == .black
            ? PlayerInfo(player: .black, type: .human)
            : PlayerInfo(player: .black, type: .artificial, aiDifficulty: aiDifficulty)

        let whitePlayerInfo = humanPlayer == .white
            ? PlayerInfo(player: .white, type: .human)
            : PlayerInfo(player: .white, type: .artificial, aiDifficulty: aiDifficulty)

        return GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: blackPlayerInfo,
            whitePlayerInfo: whitePlayerInfo
        )
    }

    /// Starting game state for AI vs AI (for testing)
    /// - Parameters:
    ///   - blackDifficulty: Black AI difficulty
    ///   - whiteDifficulty: White AI difficulty
    /// - Returns: New game state
    static func newAIVsAI(blackDifficulty: AIDifficulty, whiteDifficulty: AIDifficulty) -> GameState {
        return GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: PlayerInfo(player: .black, type: .artificial, aiDifficulty: blackDifficulty),
            whitePlayerInfo: PlayerInfo(player: .white, type: .artificial, aiDifficulty: whiteDifficulty)
        )
    }
}

// MARK: - Extensions

extension GameState: CustomStringConvertible {
    var description: String {
        let phaseInfo = gamePhase == .finished ? " (FINISHED)" : ""
        return "Game \(gameId.uuidString.prefix(8)): \(currentPlayer.name)'s turn\(phaseInfo), \(score.description)"
    }
}

extension GameState: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
        GameState {
          ID: \(gameId.uuidString.prefix(8))
          Phase: \(gamePhase.rawValue)
          Current Player: \(currentPlayer.name) (\(currentPlayerInfo.type.rawValue))
          Score: \(score.description)
          Available Moves: \(availableMoves.count)
          Move Count: \(moveCount)
          Duration: \(String(format: "%.1f", gameDuration))s
          Board:
        \(board.description.split(separator: "\n").map { "    \($0)" }.joined(separator: "\n"))
        }
        """
    }
}
