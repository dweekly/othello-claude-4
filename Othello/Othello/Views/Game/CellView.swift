//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct CellView: View {
    let position: BoardPosition
    let cellState: CellState
    let isValidMove: Bool
    let isProcessing: Bool
    let isInvalidMove: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            // Board background - this is just the green felt
            Rectangle()
                .fill(isInvalidMove ? Color.red.opacity(0.3) : boardColor)
                .overlay(
                    Rectangle()
                        .stroke(boardLineColor, lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.3), value: isInvalidMove)

            // Valid move indicator (small hint circle)
            if isValidMove && !isProcessing {
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 8, height: 8)
            }

            // Game pieces (much larger)
            switch cellState {
            case .empty:
                EmptyView()
            case .black:
                Circle()
                    .fill(Color.black)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
                    .scaleEffect(0.9) // Much bigger pieces
                    .transition(.scale.combined(with: .opacity))
            case .white:
                Circle()
                    .fill(Color.white)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .scaleEffect(0.9) // Much bigger pieces
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .contentShape(Rectangle()) // Make entire cell tappable
        .onTapGesture {
            onTap()
        }
        .disabled(isProcessing)
        .animation(.easeInOut(duration: 0.3), value: cellState)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isValidMove ? .isButton : [])
    }

    private var boardColor: Color {
#if os(macOS)
        Color(red: 0.0, green: 0.6, blue: 0.2) // Rich green that shows well on macOS
#else
        Color(.systemGreen)
#endif
    }
    
    private var boardLineColor: Color {
#if os(macOS)
        Color(red: 0.0, green: 0.4, blue: 0.1) // Darker green for grid lines
#else
        Color.green.opacity(0.6)
#endif
    }

    private var accessibilityLabel: String {
        let positionName = position.algebraicNotation
        switch cellState {
        case .empty:
            return isValidMove ? "Empty cell \(positionName), valid move" : "Empty cell \(positionName)"
        case .black:
            return "Black piece at \(positionName)"
        case .white:
            return "White piece at \(positionName)"
        }
    }

    private var accessibilityHint: String {
        if isInvalidMove {
            return "Invalid move - this position is not available"
        } else if isValidMove && !isProcessing {
            return "Tap to place your piece here"
        }
        return ""
    }
}

#Preview {
    VStack {
        HStack {
            CellView(
                position: BoardPosition(row: 0, col: 0),
                cellState: .empty,
                isValidMove: true,
                isProcessing: false,
                isInvalidMove: false
            ) {}

            CellView(
                position: BoardPosition(row: 0, col: 1),
                cellState: .black,
                isValidMove: false,
                isProcessing: false,
                isInvalidMove: false
            ) {}

            CellView(
                position: BoardPosition(row: 0, col: 2),
                cellState: .white,
                isValidMove: false,
                isProcessing: false,
                isInvalidMove: false
            ) {}
        }
    }
    .padding()
}
