//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI

struct GameView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        Group {
#if os(macOS)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Status at top - fixed height
                    GameStatusView(viewModel: viewModel)
                        .frame(height: 60)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    // Board in center - takes remaining space
                    BoardView(viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)

                    // Button at bottom - fixed height  
                    Button("New Game") {
                        viewModel.requestNewGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(height: 44)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                }
            }
            .frame(minWidth: 500, minHeight: 600)
#else
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
#endif
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
