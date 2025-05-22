//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI
import OthelloCore

struct GameView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        VStack(spacing: 20) {
            GameStatusView(viewModel: viewModel)

            BoardView(viewModel: viewModel)

            Button("New Game") {
                viewModel.resetGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    GameView()
}
