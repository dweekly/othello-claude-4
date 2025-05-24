//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI

/// Game setup view for configuring player types and AI difficulty
struct GameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var blackPlayerType: PlayerType = .human
    @State private var whitePlayerType: PlayerType = .human
    @State private var blackAIDifficulty: AIDifficulty = .medium
    @State private var whiteAIDifficulty: AIDifficulty = .medium
    
    let onGameStart: (PlayerInfo, PlayerInfo) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Black Player")) {
                    Picker("Type", selection: $blackPlayerType) {
                        Text("Human").tag(PlayerType.human)
                        Text("AI").tag(PlayerType.ai)
                    }
                    .pickerStyle(.segmented)
                    
                    if blackPlayerType == .ai {
                        Picker("Difficulty", selection: $blackAIDifficulty) {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                VStack(alignment: .leading) {
                                    Text(difficulty.localizedName)
                                    Text(difficulty.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(difficulty)
                            }
                        }
                    }
                }
                
                Section(header: Text("White Player")) {
                    Picker("Type", selection: $whitePlayerType) {
                        Text("Human").tag(PlayerType.human)
                        Text("AI").tag(PlayerType.ai)
                    }
                    .pickerStyle(.segmented)
                    
                    if whitePlayerType == .ai {
                        Picker("Difficulty", selection: $whiteAIDifficulty) {
                            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                VStack(alignment: .leading) {
                                    Text(difficulty.localizedName)
                                    Text(difficulty.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(difficulty)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Start Game") {
                        let blackPlayer = PlayerInfo(
                            player: .black,
                            type: blackPlayerType,
                            aiDifficulty: blackPlayerType == .ai ? blackAIDifficulty : nil
                        )
                        let whitePlayer = PlayerInfo(
                            player: .white,
                            type: whitePlayerType,
                            aiDifficulty: whitePlayerType == .ai ? whiteAIDifficulty : nil
                        )
                        
                        onGameStart(blackPlayer, whitePlayer)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                
                Section(footer: gameSetupInfo) {
                    EmptyView()
                }
            }
            .navigationTitle("Game Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var gameSetupInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI Difficulty Levels:")
                .font(.headline)
            
            ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                HStack(alignment: .top) {
                    Text("• \(difficulty.localizedName):")
                        .fontWeight(.medium)
                    Text(difficulty.description)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .font(.caption)
        .padding(.top)
    }
}

#Preview {
    GameSetupView { blackPlayer, whitePlayer in
        print("Starting game: \(blackPlayer.displayName) vs \(whitePlayer.displayName)")
    }
}