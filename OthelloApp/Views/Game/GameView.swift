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
                viewModel.requestNewGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
        .padding()
        .alert("Invalid Move", isPresented: $viewModel.showingInvalidMoveAlert) {
            Button("OK") {
                viewModel.dismissInvalidMoveAlert()
            }
        } message: {
            Text("That position is not a valid move. Please select a highlighted cell.")
        }
        .alert("Game Complete", isPresented: $viewModel.showingGameCompletionAlert) {
            Button("New Game") {
                viewModel.confirmNewGame()
            }
            Button("OK") {
                viewModel.dismissGameCompletionAlert()
            }
        } message: {
            Text(viewModel.gameCompletionMessage)
        }
        .alert("Start New Game?", isPresented: $viewModel.showingNewGameConfirmation) {
            Button("Start New Game", role: .destructive) {
                viewModel.confirmNewGame()
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissNewGameConfirmation()
            }
        } message: {
            Text("This will end the current game. Are you sure?")
        }
    }
}

#Preview {
    GameView()
}
