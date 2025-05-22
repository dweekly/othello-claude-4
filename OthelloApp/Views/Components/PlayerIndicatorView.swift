import SwiftUI
import OthelloCore
#if canImport(UIKit)
import UIKit
#endif

struct PlayerIndicatorView: View {
    let player: Player
    let score: Int
    let isCurrentPlayer: Bool
    let isGameFinished: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(player == .black ? Color.black : Color.white)
                    .overlay(
                        Circle()
#if canImport(UIKit)
                            .stroke(player == .white ? Color(UIColor.systemGray4) : Color.clear, lineWidth: 1)
#else
                            .stroke(player == .white ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1)
#endif
                    )
                    .frame(width: 24, height: 24)
                
                Text(playerName)
                    .font(.subheadline)
                    .fontWeight(isCurrentPlayer && !isGameFinished ? .bold : .regular)
            }
            
            Text("\(score)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(isCurrentPlayer && !isGameFinished ? .accentColor : .primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentPlayer && !isGameFinished ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var playerName: String {
        switch player {
        case .black: return "Black"
        case .white: return "White"
        }
    }
    
    private var accessibilityLabel: String {
        let turnIndicator = isCurrentPlayer && !isGameFinished ? ", current player" : ""
        return "\(playerName): \(score) pieces\(turnIndicator)"
    }
}

#Preview {
    VStack {
        PlayerIndicatorView(
            player: .black,
            score: 2,
            isCurrentPlayer: true,
            isGameFinished: false
        )
        
        PlayerIndicatorView(
            player: .white,
            score: 2,
            isCurrentPlayer: false,
            isGameFinished: false
        )
    }
    .padding()
}
