//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI
import OthelloCore

struct BoardView: View {
    let viewModel: GameViewModel

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 8)

    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 2) {
            ForEach(0..<64, id: \.self) { index in
                let row = index / 8
                let col = index % 8
                let position = BoardPosition(row: row, col: col)

                CellView(
                    position: position,
                    cellState: viewModel.gameState.board[position],
                    isValidMove: viewModel.validMoves.contains(position),
                    isProcessing: viewModel.isProcessingMove,
                    isInvalidMove: viewModel.lastInvalidMovePosition == position
                ) {
                    viewModel.makeMove(at: position)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .background(Color(.systemGreen))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    BoardView(viewModel: GameViewModel())
        .padding()
}
