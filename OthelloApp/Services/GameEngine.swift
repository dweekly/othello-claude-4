import Foundation

/// Production implementation of the Othello game engine
///
/// This class implements all the game rules and logic for Othello,
/// including move validation, piece capture, and game state management.
public final class GameEngine: GameEngineProtocol {
    public init() {}

    // MARK: - Move Validation

    public func isValidMove(_ move: Move, in gameState: GameState) -> Bool {
        // Basic validation
        guard gameState.gamePhase == .playing else { return false }
        guard move.player == gameState.currentPlayer else { return false }
        guard move.position.isValid else { return false }

        // Use board's validation logic
        return gameState.board.isValidMove(at: move.position, for: move.player)
    }

    public func availableMoves(for gameState: GameState) -> [BoardPosition] {
        return availableMoves(for: gameState.currentPlayer, in: gameState)
    }

    public func availableMoves(for player: Player, in gameState: GameState) -> [BoardPosition] {
        guard gameState.gamePhase == .playing else { return [] }
        return gameState.board.validMoves(for: player)
    }

    // MARK: - Move Application

    public func applyMove(_ move: Move, to gameState: GameState) -> MoveResult? {
        guard isValidMove(move, in: gameState) else { return nil }

        // Apply the move to the board
        guard let (_, capturedPositions) = gameState.board.applyingMove(move) else {
            return nil
        }

        // Create updated game state
        guard let newGameState = gameState.applyingMove(move) else {
            return nil
        }

        return MoveResult(
            move: move,
            capturedPositions: capturedPositions,
            newGameState: newGameState
        )
    }

    public func capturedPositions(for move: Move, in gameState: GameState) -> [BoardPosition] {
        guard move.position.isValid else { return [] }
        return gameState.board.capturedPositions(placing: move.player, at: move.position)
    }

    // MARK: - Game State Analysis

    public func isGameOver(_ gameState: GameState) -> Bool {
        if gameState.gamePhase == .finished {
            return true
        }

        // Game is over if neither player has valid moves
        let blackHasMoves = hasValidMoves(.black, in: gameState)
        let whiteHasMoves = hasValidMoves(.white, in: gameState)

        return !blackHasMoves && !whiteHasMoves
    }

    public func winner(of gameState: GameState) -> Player? {
        guard isGameOver(gameState) else { return nil }
        return gameState.score.leader
    }

    public func hasValidMoves(_ player: Player, in gameState: GameState) -> Bool {
        return !availableMoves(for: player, in: gameState).isEmpty
    }

    // MARK: - Game Flow

    public func nextTurn(from gameState: GameState) -> GameState {
        guard gameState.gamePhase == .playing else { return gameState }

        let nextPlayer = gameState.currentPlayer.opposite
        let nextPlayerHasMoves = hasValidMoves(nextPlayer, in: gameState)
        let currentPlayerHasMoves = hasValidMoves(gameState.currentPlayer, in: gameState)

        if nextPlayerHasMoves {
            // Next player can move - switch to them
            return GameState(
                board: gameState.board,
                currentPlayer: nextPlayer,
                gamePhase: .playing,
                moveHistory: gameState.moveHistory,
                blackPlayerInfo: gameState.blackPlayerInfo,
                whitePlayerInfo: gameState.whitePlayerInfo,
                gameId: gameState.gameId,
                startTime: gameState.startTime
            )
        } else if currentPlayerHasMoves {
            // Next player can't move, but current player can continue
            return gameState
        } else {
            // Neither player can move - game over
            return GameState(
                board: gameState.board,
                currentPlayer: gameState.currentPlayer,
                gamePhase: .finished,
                moveHistory: gameState.moveHistory,
                blackPlayerInfo: gameState.blackPlayerInfo,
                whitePlayerInfo: gameState.whitePlayerInfo,
                gameId: gameState.gameId,
                startTime: gameState.startTime
            )
        }
    }

    public func newGame(blackPlayer: PlayerInfo, whitePlayer: PlayerInfo) -> GameState {
        return GameState(
            board: .initial,
            currentPlayer: .black,
            gamePhase: .playing,
            blackPlayerInfo: blackPlayer,
            whitePlayerInfo: whitePlayer
        )
    }

    // MARK: - Board Analysis

    public func evaluatePosition(_ gameState: GameState, for player: Player) -> Double {
        let analysis = analyzePosition(gameState)
        return analysis.evaluation[player] ?? 0.0
    }

    public func analyzePosition(_ gameState: GameState) -> PositionAnalysis {
        let board = gameState.board

        // Mobility analysis
        let blackMobility = availableMoves(for: .black, in: gameState).count
        let whiteMobility = availableMoves(for: .white, in: gameState).count

        // Corner control analysis
        let corners = [
            BoardPosition(row: 0, col: 0), BoardPosition(row: 0, col: 7),
            BoardPosition(row: 7, col: 0), BoardPosition(row: 7, col: 7)
        ]

        let blackCorners = corners.filter { board[$0] == .black }.count
        let whiteCorners = corners.filter { board[$0] == .white }.count

        // Edge control analysis
        let edges = getEdgePositions()
        let blackEdges = edges.filter { board[$0] == .black }.count
        let whiteEdges = edges.filter { board[$0] == .white }.count

        // Stability analysis (simplified)
        let blackStability = calculateStability(for: .black, in: board)
        let whiteStability = calculateStability(for: .white, in: board)

        // Overall evaluation
        let blackEval = calculateOverallEvaluation(
            player: .black,
            mobility: blackMobility,
            corners: blackCorners,
            edges: blackEdges,
            stability: blackStability,
            score: gameState.score.black
        )

        let whiteEval = calculateOverallEvaluation(
            player: .white,
            mobility: whiteMobility,
            corners: whiteCorners,
            edges: whiteEdges,
            stability: whiteStability,
            score: gameState.score.white
        )

        return PositionAnalysis(
            mobility: [.black: blackMobility, .white: whiteMobility],
            cornerControl: [.black: blackCorners, .white: whiteCorners],
            edgeControl: [.black: blackEdges, .white: whiteEdges],
            stability: [.black: blackStability, .white: whiteStability],
            evaluation: [.black: blackEval, .white: whiteEval]
        )
    }

    // MARK: - Private Helper Methods

    private func getEdgePositions() -> [BoardPosition] {
        var edges: [BoardPosition] = []

        // Top and bottom edges
        for col in 0..<8 {
            edges.append(BoardPosition(row: 0, col: col))
            edges.append(BoardPosition(row: 7, col: col))
        }

        // Left and right edges (excluding corners already added)
        for row in 1..<7 {
            edges.append(BoardPosition(row: row, col: 0))
            edges.append(BoardPosition(row: row, col: 7))
        }

        return edges
    }

    private func calculateStability(for player: Player, in board: Board) -> Double {
        let playerPositions = board.positions(with: player.cellState)
        var stableCount = 0

        for position in playerPositions {
            if isStablePosition(position, for: player, in: board) {
                stableCount += 1
            }
        }

        return playerPositions.isEmpty ? 0.0 : Double(stableCount) / Double(playerPositions.count)
    }

    private func isStablePosition(_ position: BoardPosition, for player: Player, in board: Board) -> Bool {
        // Simplified stability check - corners are always stable
        let corners = [
            BoardPosition(row: 0, col: 0), BoardPosition(row: 0, col: 7),
            BoardPosition(row: 7, col: 0), BoardPosition(row: 7, col: 7)
        ]

        if corners.contains(position) {
            return true
        }

        // For now, consider edge pieces adjacent to corners as stable
        let stableEdges = getStableEdgePositions(in: board)
        return stableEdges.contains(position)
    }

    private func getStableEdgePositions(in board: Board) -> Set<BoardPosition> {
        var stableEdges: Set<BoardPosition> = []

        // Check each corner and add adjacent stable pieces
        let corners = [
            (BoardPosition(row: 0, col: 0), [(0, 1), (1, 0)]),  // Top-left
            (BoardPosition(row: 0, col: 7), [(0, -1), (1, 0)]), // Top-right
            (BoardPosition(row: 7, col: 0), [(-1, 0), (0, 1)]), // Bottom-left
            (BoardPosition(row: 7, col: 7), [(-1, 0), (0, -1)]) // Bottom-right
        ]

        for (corner, directions) in corners {
            if board[corner] != .empty {
                let cornerPlayer = board[corner]

                for (rowDir, colDir) in directions {
                    var current = corner
                    while let next = current.offset(row: rowDir, col: colDir),
                          board[next] == cornerPlayer {
                        stableEdges.insert(next)
                        current = next
                    }
                }
            }
        }

        return stableEdges
    }

    private func calculateOverallEvaluation(
        player: Player,
        mobility: Int,
        corners: Int,
        edges: Int,
        stability: Double,
        score: Int
    ) -> Double {
        // Weighted evaluation based on different factors
        let mobilityWeight = 10.0
        let cornerWeight = 100.0
        let edgeWeight = 5.0
        let stabilityWeight = 20.0
        let scoreWeight = 1.0

        return Double(mobility) * mobilityWeight +
               Double(corners) * cornerWeight +
               Double(edges) * edgeWeight +
               stability * stabilityWeight +
               Double(score) * scoreWeight
    }
}

// MARK: - GameEngine Extensions for Testing

extension GameEngine {
    /// Validates the internal consistency of a game state
    /// Used primarily for testing and debugging
    public func validateGameState(_ gameState: GameState) -> [String] {
        var issues: [String] = []

        // Check board consistency
        let boardScore = gameState.board.score
        if boardScore != gameState.score {
            issues.append("Board score (\(boardScore)) doesn't match game state score (\(gameState.score))")
        }

        // Check move history consistency
        if gameState.moveHistory.count != gameState.moveCount {
            issues.append("Move history count doesn't match move count")
        }

        // Check game phase consistency
        if gameState.gamePhase == .finished && !isGameOver(gameState) {
            issues.append("Game marked as finished but moves are still available")
        }

        if gameState.gamePhase == .playing && isGameOver(gameState) {
            issues.append("Game marked as playing but no moves are available")
        }

        // Check current player has moves (unless game is over)
        if gameState.gamePhase == .playing {
            let currentPlayerHasMoves = hasValidMoves(gameState.currentPlayer, in: gameState)
            let otherPlayerHasMoves = hasValidMoves(gameState.currentPlayer.opposite, in: gameState)

            if !currentPlayerHasMoves && !otherPlayerHasMoves {
                issues.append("Game is playing but neither player has moves")
            }
        }

        return issues
    }

    /// Creates a game state from a board configuration for testing
    public func createTestGameState(
        board: Board,
        currentPlayer: Player = .black,
        gamePhase: GamePhase = .playing
    ) -> GameState {
        return GameState(
            board: board,
            currentPlayer: currentPlayer,
            gamePhase: gamePhase,
            blackPlayerInfo: PlayerInfo(player: .black, type: .human),
            whitePlayerInfo: PlayerInfo(player: .white, type: .human)
        )
    }
}
