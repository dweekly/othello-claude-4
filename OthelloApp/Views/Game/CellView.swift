//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI
import OthelloCore
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
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(isInvalidMove ? Color.red.opacity(0.3) : Color(.systemGreen))
                    .overlay(
                        Rectangle()
#if canImport(UIKit)
                            .stroke(isInvalidMove ? Color.red : Color(UIColor.systemBackground), lineWidth: isInvalidMove ? 2 : 1)
#else
                            .stroke(isInvalidMove ? Color.red : Color.primary.opacity(0.2), lineWidth: isInvalidMove ? 2 : 1)
#endif
                    )
                    .animation(.easeInOut(duration: 0.3), value: isInvalidMove)

                if isValidMove && !isProcessing {
                    Circle()
#if canImport(UIKit)
                        .fill(Color(UIColor.systemGray3))
#else
                        .fill(Color.primary.opacity(0.4))
#endif
                        .scaleEffect(0.3)
                        .opacity(0.6)
                }

                switch cellState {
                case .empty:
                    EmptyView()
                case .black:
                    Circle()
                        .fill(Color.black)
                        .scaleEffect(0.8)
                        .transition(.scale.combined(with: .opacity))
                case .white:
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Circle()
#if canImport(UIKit)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
#else
                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
#endif
                        )
                        .scaleEffect(0.8)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .disabled(isProcessing)
        .animation(.easeInOut(duration: 0.3), value: cellState)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isValidMove ? .isButton : [])
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
