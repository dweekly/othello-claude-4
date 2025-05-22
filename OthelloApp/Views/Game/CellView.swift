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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGreen))
                    .overlay(
                        Rectangle()
#if canImport(UIKit)
                            .stroke(Color(UIColor.systemBackground), lineWidth: 1)
#else
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
#endif
                    )

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
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .disabled(isProcessing || !isValidMove)
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
        if isValidMove && !isProcessing {
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
                isProcessing: false
            ) {}

            CellView(
                position: BoardPosition(row: 0, col: 1),
                cellState: .black,
                isValidMove: false,
                isProcessing: false
            ) {}

            CellView(
                position: BoardPosition(row: 0, col: 2),
                cellState: .white,
                isValidMove: false,
                isProcessing: false
            ) {}
        }
    }
    .padding()
}
