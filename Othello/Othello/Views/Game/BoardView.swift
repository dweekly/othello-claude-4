//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI


struct BoardView: View {
    let viewModel: GameViewModel

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)

    var body: some View {
#if os(macOS)
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            let boardSize = min(availableWidth, availableHeight)
            
            LazyVGrid(columns: gridColumns, spacing: 0) {
                ForEach(0..<64, id: \.self) { index in
                    let row = index / 8
                    let col = index % 8
                    let position = BoardPosition(row: row, col: col)

                    CellView(
                        position: position,
                        cellState: viewModel.gameState.board[position],
                        isValidMove: viewModel.validMoves.contains(position),
                        isProcessing: viewModel.isProcessingMove,
                        isInvalidMove: false
                    ) {
                        viewModel.makeMove(at: position)
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .cornerRadius(8)
            .position(x: availableWidth / 2, y: availableHeight / 2)
        }
#else
        LazyVGrid(columns: gridColumns, spacing: 0) {
            ForEach(0..<64, id: \.self) { index in
                let row = index / 8
                let col = index % 8
                let position = BoardPosition(row: row, col: col)

                CellView(
                    position: position,
                    cellState: viewModel.gameState.board[position],
                    isValidMove: viewModel.validMoves.contains(position),
                    isProcessing: viewModel.isProcessingMove,
                    isInvalidMove: false
                ) {
                    viewModel.makeMove(at: position)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .cornerRadius(8)
        .padding(.horizontal)
#endif
    }
    
    private var boardBackgroundColor: Color {
#if os(macOS)
        Color(red: 0.0, green: 0.5, blue: 0.15) // Slightly darker green for contrast
#else
        Color(.systemGreen)
#endif
    }
}

#Preview {
    BoardView(viewModel: GameViewModel())
        .padding()
}
