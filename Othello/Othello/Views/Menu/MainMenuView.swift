import SwiftUI

struct MainMenuView: View {
    @State private var showSettings = false
    @State private var showHowToPlay = false
    @State private var selectedGameMode: GameMode?
    @State private var selectedDifficulty: AIDifficulty = .medium
    
    enum GameMode: Identifiable {
        case humanVsHuman
        case humanVsAI
        
        var id: Self { self }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                titleSection
                
                VStack(spacing: 20) {
                    gameModesSection
                    
                    menuButtonsSection
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .navigationDestination(item: $selectedGameMode) { mode in
                GameView(
                    gameMode: mode == .humanVsAI ? .humanVsAI(difficulty: selectedDifficulty) : .humanVsHuman
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showHowToPlay) {
                HowToPlayView()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Othello")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Classic Strategy Game")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
    
    private var gameModesSection: some View {
        VStack(spacing: 16) {
            Text("New Game")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                selectedGameMode = .humanVsHuman
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                    Text("Human vs Human")
                        .font(.title3)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 12) {
                Button(action: {
                    selectedGameMode = .humanVsAI
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Human vs AI")
                            .font(.title3)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                if selectedGameMode == nil || selectedGameMode == .humanVsAI {
                    difficultySelector
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
        }
    }
    
    private var difficultySelector: some View {
        HStack(spacing: 12) {
            Text("Difficulty:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            difficultyButton(for: .easy)
            difficultyButton(for: .medium)
            difficultyButton(for: .hard)
        }
        .padding(.horizontal)
    }
    
    private func difficultyButton(for difficulty: AIDifficulty) -> some View {
        let isSelected = selectedDifficulty == difficulty
        
        return Button(action: {
            selectedDifficulty = difficulty
        }) {
            Text(difficulty.displayName)
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var menuButtonsSection: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.vertical, 10)
            
            Button(action: {
                showHowToPlay = true
            }) {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("How to Play")
                    Spacer()
                }
                .padding(.horizontal)
                .font(.body)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                showSettings = true
            }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                    Spacer()
                }
                .padding(.horizontal)
                .font(.body)
            }
            .buttonStyle(.plain)
        }
    }
}

extension AIDifficulty {
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

#Preview {
    MainMenuView()
}