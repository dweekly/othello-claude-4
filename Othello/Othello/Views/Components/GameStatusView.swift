//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct GameStatusView: View {
    let viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                PlayerIndicatorView(
                    player: .black,
                    score: viewModel.gameState.score.black,
                    isCurrentPlayer: viewModel.gameState.currentPlayer == .black,
                    isGameFinished: viewModel.gameState.gamePhase == .finished
                )

                Spacer()

                PlayerIndicatorView(
                    player: .white,
                    score: viewModel.gameState.score.white,
                    isCurrentPlayer: viewModel.gameState.currentPlayer == .white,
                    isGameFinished: viewModel.gameState.gamePhase == .finished
                )
            }

            Text(viewModel.gameStatusMessage)
                .font(.headline)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isStaticText)
                .accessibilityLabel(accessibilityGameStatus)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
#if canImport(UIKit)
                .fill(Color(UIColor.secondarySystemBackground))
#else
                .fill(Color.secondary.opacity(0.1))
#endif
        )
    }

    private var accessibilityGameStatus: String {
        switch viewModel.gameState.gamePhase {
        case .playing:
            let validMovesCount = viewModel.validMoves.count
            return "\(viewModel.gameStatusMessage). \(validMovesCount) valid moves available."
        case .finished:
            return "\(viewModel.gameStatusMessage)"
        }
    }
}

#Preview {
    GameStatusView(viewModel: GameViewModel())
        .padding()
}
