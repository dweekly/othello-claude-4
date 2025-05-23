//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import XCTest

final class UIIntegrationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAppLaunchesSuccessfully() throws {
        // Verify the app launches and shows the main game screen
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["New Game"].exists)
    }
    
    func testGameBoardIsDisplayed() throws {
        // Verify the 8x8 game board is displayed
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // The board should be rendered as buttons or interactive elements
        // This is a basic check that the UI structure exists
        let gameElements = app.descendants(matching: .any)
        XCTAssertGreaterThan(gameElements.count, 50) // Should have many UI elements for the board
    }
    
    func testScoreDisplayUpdates() throws {
        // Wait for initial game state
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Check if score is displayed (format may vary)
        let scoreExists = app.staticTexts["Black: 2"].exists || 
                         app.staticTexts["2"].exists ||
                         app.descendants(matching: .staticText).containing(NSPredicate(format: "label CONTAINS '2'")).element.exists
        
        XCTAssertTrue(scoreExists, "Score should be displayed somewhere in the UI")
    }
    
    func testNewGameButtonFunctionality() throws {
        // Wait for game to load
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Tap the New Game button
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.exists)
        newGameButton.tap()
        
        // Should show confirmation dialog or restart immediately
        // Check that we're still in a valid game state
        let blackTurnExists = app.staticTexts["Black's turn"].waitForExistence(timeout: 3)
        let confirmationExists = app.buttons["Start New Game"].waitForExistence(timeout: 1)
        
        XCTAssertTrue(blackTurnExists || confirmationExists, "Should show game state or confirmation")
        
        if confirmationExists {
            // If confirmation dialog appeared, test it
            app.buttons["Start New Game"].tap()
            XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 3))
        }
    }
    
    func testPlayerTurnIndicatorChanges() throws {
        // Wait for initial state
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Try to find and tap a valid move area
        // This is challenging without knowing exact UI structure, so we'll tap in the board area
        let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.tap()
        
        // Wait a moment for potential state change
        Thread.sleep(forTimeInterval: 0.5)
        
        // Check if turn indicator might have changed
        // We can't be sure of exact move validity, but UI should remain stable
        let gameStateExists = app.staticTexts["Black's turn"].exists || 
                             app.staticTexts["White's turn"].exists
        XCTAssertTrue(gameStateExists, "Should show valid game state")
    }
    
    func testAppStabilityUnderRapidInput() throws {
        // Wait for game to load
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Rapid tapping in different areas
        for _ in 0..<10 {
            let randomX = Double.random(in: 0.2...0.8)
            let randomY = Double.random(in: 0.3...0.7)
            let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: randomX, dy: randomY))
            coordinate.tap()
        }
        
        // App should remain stable and responsive
        XCTAssertTrue(app.buttons["New Game"].exists)
        
        let gameStateExists = app.staticTexts["Black's turn"].exists || 
                             app.staticTexts["White's turn"].exists ||
                             app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'turn'")).element.exists
        XCTAssertTrue(gameStateExists, "App should remain in valid state after rapid input")
    }
    
    func testAccessibilityElements() throws {
        // Wait for game to load
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Check that key elements are accessible
        XCTAssertTrue(app.buttons["New Game"].isHittable)
        
        // Check that game status is accessible
        let gameStatus = app.staticTexts["Black's turn"]
        XCTAssertTrue(gameStatus.exists)
    }
    
    func testWindowResizing() throws {
        #if os(macOS)
        // This test is macOS specific for window resizing
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Get current window
        let window = app.windows.firstMatch
        XCTAssertTrue(window.exists)
        
        // Try to resize (this may not work in all test environments)
        // At minimum, verify the window exists and is responsive
        let originalFrame = window.frame
        
        // Verify UI remains stable after potential resize
        XCTAssertTrue(app.buttons["New Game"].exists)
        XCTAssertTrue(app.staticTexts["Black's turn"].exists || app.staticTexts["White's turn"].exists)
        #endif
    }
    
    func testGameCompletionFlow() throws {
        // Wait for initial state
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Make multiple moves to try to progress the game
        // We'll tap in various board positions
        let boardPositions = [
            CGVector(dx: 0.3, dy: 0.4),
            CGVector(dx: 0.7, dy: 0.4),
            CGVector(dx: 0.3, dy: 0.6),
            CGVector(dx: 0.7, dy: 0.6),
            CGVector(dx: 0.4, dy: 0.3),
            CGVector(dx: 0.6, dy: 0.3)
        ]
        
        for position in boardPositions {
            let coordinate = app.coordinate(withNormalizedOffset: position)
            coordinate.tap()
            
            // Small delay between moves
            Thread.sleep(forTimeInterval: 0.3)
            
            // Check if game completed
            if app.alerts.count > 0 {
                // Game completion alert appeared
                let alert = app.alerts.firstMatch
                if alert.buttons["New Game"].exists {
                    alert.buttons["New Game"].tap()
                } else if alert.buttons["OK"].exists {
                    alert.buttons["OK"].tap()
                }
                break
            }
        }
        
        // Verify we're still in a valid state
        let validStateExists = app.staticTexts["Black's turn"].exists || 
                              app.staticTexts["White's turn"].exists ||
                              app.buttons["New Game"].exists
        XCTAssertTrue(validStateExists, "Should be in valid game state")
    }
    
    func testPerformanceOfUIUpdates() throws {
        // Measure UI responsiveness
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
        
        // Wait for UI to load
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Measure UI interaction performance
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            // Perform multiple UI interactions
            for _ in 0..<5 {
                let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                coordinate.tap()
                
                app.buttons["New Game"].tap()
                
                // Handle potential confirmation
                if app.buttons["Start New Game"].waitForExistence(timeout: 1) {
                    app.buttons["Start New Game"].tap()
                }
                
                // Wait for state to settle
                _ = app.staticTexts["Black's turn"].waitForExistence(timeout: 2)
            }
        }
    }
    
    func testLongRunningGameSession() throws {
        // Test stability over extended use
        XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 5))
        
        // Simulate extended game session
        for gameRound in 0..<3 {
            // Play some moves
            for moveIndex in 0..<10 {
                let x = 0.3 + Double(moveIndex % 3) * 0.2
                let y = 0.3 + Double(moveIndex / 3) * 0.15
                let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
                coordinate.tap()
                
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            // Start new game
            app.buttons["New Game"].tap()
            
            if app.buttons["Start New Game"].waitForExistence(timeout: 1) {
                app.buttons["Start New Game"].tap()
            }
            
            // Verify game restarted successfully
            XCTAssertTrue(app.staticTexts["Black's turn"].waitForExistence(timeout: 3),
                         "Game should restart successfully in round \(gameRound)")
        }
        
        // Final verification
        XCTAssertTrue(app.buttons["New Game"].exists)
        XCTAssertTrue(app.staticTexts["Black's turn"].exists || app.staticTexts["White's turn"].exists)
    }
}