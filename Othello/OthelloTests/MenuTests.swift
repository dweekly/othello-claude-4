import Testing
@testable import Othello
import SwiftUI

@Suite("Menu Tests")
struct MenuTests {
    @Test("Main menu displays correctly")
    func testMainMenuView() {
        let view = MainMenuView()

        // Test that view can be created
        _ = view.body
    }

    @Test("Game mode enum works correctly")
    func testGameMode() {
        let humanMode = GameMode.humanVsHuman
        let aiEasyMode = GameMode.humanVsAI(difficulty: .easy)
        let aiMediumMode = GameMode.humanVsAI(difficulty: .medium)
        let aiHardMode = GameMode.humanVsAI(difficulty: .hard)

        // Test black player is always human
        #expect(humanMode.blackPlayerType == .human)
        #expect(aiEasyMode.blackPlayerType == .human)

        // Test white player type
        #expect(humanMode.whitePlayerType == .human)
        #expect(aiEasyMode.whitePlayerType == .artificial)
        #expect(aiMediumMode.whitePlayerType == .artificial)
        #expect(aiHardMode.whitePlayerType == .artificial)

        // Test AI difficulty
        #expect(humanMode.aiDifficulty == nil)
        #expect(aiEasyMode.aiDifficulty == .easy)
        #expect(aiMediumMode.aiDifficulty == .medium)
        #expect(aiHardMode.aiDifficulty == .hard)
    }

    @Test("GameViewModel initializes with correct game mode")
    @MainActor
    func testGameViewModelWithGameMode() {
        // Test human vs human
        let humanViewModel = GameViewModel(gameMode: .humanVsHuman)
        #expect(humanViewModel.gameState.blackPlayerInfo.type == .human)
        #expect(humanViewModel.gameState.whitePlayerInfo.type == .human)
        #expect(humanViewModel.gameState.blackPlayerInfo.aiDifficulty == nil)
        #expect(humanViewModel.gameState.whitePlayerInfo.aiDifficulty == nil)

        // Test human vs AI medium
        let aiViewModel = GameViewModel(gameMode: .humanVsAI(difficulty: .medium))
        #expect(aiViewModel.gameState.blackPlayerInfo.type == .human)
        #expect(aiViewModel.gameState.whitePlayerInfo.type == .artificial)
        #expect(aiViewModel.gameState.blackPlayerInfo.aiDifficulty == nil)
        #expect(aiViewModel.gameState.whitePlayerInfo.aiDifficulty == .medium)
    }

    @Test("ContentView shows main menu")
    func testContentViewShowsMainMenu() {
        let contentView = ContentView()

        // Just verify it can be created and body accessed
        _ = contentView.body
    }

    @Test("Settings view can be created")
    func testSettingsView() {
        let settingsView = SettingsView()

        // Verify view can be created
        _ = settingsView.body
    }

    @Test("How to play view can be created")
    func testHowToPlayView() {
        let howToPlayView = HowToPlayView()

        // Verify view can be created
        _ = howToPlayView.body
    }

    @Test("AI difficulty display names")
    func testAIDifficultyDisplayNames() {
        #expect(AIDifficulty.easy.displayName == "Easy")
        #expect(AIDifficulty.medium.displayName == "Medium")
        #expect(AIDifficulty.hard.displayName == "Hard")
    }
}
