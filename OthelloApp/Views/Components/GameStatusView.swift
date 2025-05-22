import SwiftUI
import OthelloCore
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
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isStaticText)
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
}

#Preview {
    GameStatusView(viewModel: GameViewModel())
        .padding()
}
