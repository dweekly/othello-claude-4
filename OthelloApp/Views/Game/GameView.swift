//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI
import OthelloCore

struct GameView: View {
    @State private var viewModel = GameViewModel()
    @State private var showingGameSetup = false

    var body: some View {
        VStack(spacing: 20) {
            GameStatusView(viewModel: viewModel)

            BoardView(viewModel: viewModel)

            HStack(spacing: 16) {
                Button("New Game") {
                    viewModel.requestNewGame()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("AI Game") {
                    showingGameSetup = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        }
        .padding()
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
        .sheet(isPresented: $showingGameSetup) {
            AIGameSetupView(viewModel: viewModel)
        }
    }
}

struct AIGameSetupView: View {
    let viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOpponentDifficulty: AIDifficulty = .medium
    @State private var playerIsBlack = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Setup AI Game")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Choose your settings for a game against the computer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Color")
                            .font(.headline)
                        
                        Picker("Player Color", selection: $playerIsBlack) {
                            Text("Black (First)").tag(true)
                            Text("White (Second)").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Difficulty")
                            .font(.headline)
                        
                        Picker("AI Difficulty", selection: $selectedOpponentDifficulty) {
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
                        .pickerStyle(.menu)
                    }
                }
                
                Spacer()
                
                Button("Start Game") {
                    startAIGame()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("AI Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startAIGame() {
        let humanPlayer = playerIsBlack ? Player.black : Player.white
        let aiPlayer = humanPlayer.opposite
        
        let blackPlayerInfo = PlayerInfo(
            player: .black,
            type: humanPlayer == .black ? .human : .ai,
            aiDifficulty: humanPlayer == .black ? nil : selectedOpponentDifficulty
        )
        
        let whitePlayerInfo = PlayerInfo(
            player: .white,
            type: humanPlayer == .white ? .human : .ai,
            aiDifficulty: humanPlayer == .white ? nil : selectedOpponentDifficulty
        )
        
        viewModel.startNewGame(blackPlayer: blackPlayerInfo, whitePlayer: whitePlayerInfo)
    }
}

#Preview {
    GameView()
}
