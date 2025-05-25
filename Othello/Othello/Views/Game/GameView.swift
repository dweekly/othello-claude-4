//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI

struct GameView: View {
    @State private var viewModel = GameViewModel()
    @State private var showingGameSetup = false

    var body: some View {
        Group {
#if os(macOS)
            GeometryReader { _ in
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
                        showingGameSetup = true
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
                    showingGameSetup = true
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
        .sheet(isPresented: $showingGameSetup) {
            GameSetupView(viewModel: viewModel)
        }
    }
}

struct GameSetupView: View {
    let viewModel: GameViewModel
    @Environment(\.dismiss)
    private var dismiss

    @State private var gameMode: GameMode = .humanVsAI
    @State private var selectedAIDifficulty: AIDifficulty = .medium

    enum GameMode: String, CaseIterable {
        case humanVsHuman = "Human vs Human"
        case humanVsAI = "Human vs AI"

        var description: String {
            switch self {
            case .humanVsHuman:
                return "Two players take turns"
            case .humanVsAI:
                return "You play Black, AI plays White"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("New Game")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose your game settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game Mode")
                            .font(.headline)

                        Picker("Game Mode", selection: $gameMode) {
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                VStack(alignment: .leading) {
                                    Text(mode.rawValue)
                                    Text(mode.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    if gameMode == .humanVsAI {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Difficulty")
                                .font(.headline)

                            Picker("AI Difficulty", selection: $selectedAIDifficulty) {
                                ForEach(AIDifficulty.allCases, id: \.self) { difficulty in
                                    VStack(alignment: .leading) {
                                        Text(difficultyDisplayName(difficulty))
                                        Text(difficultyDescription(difficulty))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .tag(difficulty)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }

                Spacer()

                Button("Start Game") {
                    startGame()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Game Setup")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func difficultyDisplayName(_ difficulty: AIDifficulty) -> String {
        switch difficulty {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    private func difficultyDescription(_ difficulty: AIDifficulty) -> String {
        switch difficulty {
        case .easy: return "Random moves with corner preference"
        case .medium: return "Strategic thinking (depth 3)"
        case .hard: return "Expert analysis (depth 4)"
        }
    }

    private func startGame() {
        let blackPlayerInfo: PlayerInfo
        let whitePlayerInfo: PlayerInfo

        switch gameMode {
        case .humanVsHuman:
            blackPlayerInfo = PlayerInfo(player: .black, type: .human)
            whitePlayerInfo = PlayerInfo(player: .white, type: .human)

        case .humanVsAI:
            // Human always plays Black (goes first), AI always plays White
            blackPlayerInfo = PlayerInfo(player: .black, type: .human)
            whitePlayerInfo = PlayerInfo(player: .white, type: .artificial, aiDifficulty: selectedAIDifficulty)
        }

        viewModel.startNewGame(blackPlayer: blackPlayerInfo, whitePlayer: whitePlayerInfo)
    }
}

#Preview {
    GameView()
}
