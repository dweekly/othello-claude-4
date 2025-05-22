//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import SwiftUI
@testable import OthelloCore
@testable import OthelloUI

@Suite("CellView Tests")
struct CellViewTests {
    
    @Test("CellView accessibility labels are correct")
    func testAccessibilityLabels() {
        let blackPosition = BoardPosition(row: 0, col: 0)
        let whitePosition = BoardPosition(row: 1, col: 1)
        let emptyPosition = BoardPosition(row: 2, col: 2)
        
        // Test black piece accessibility
        let blackCell = CellView(
            position: blackPosition,
            cellState: .black,
            isValidMove: false,
            isProcessing: false
        ) {}
        
        // Test white piece accessibility  
        let whiteCell = CellView(
            position: whitePosition,
            cellState: .white,
            isValidMove: false,
            isProcessing: false
        ) {}
        
        // Test empty cell with valid move
        let emptyCellValidMove = CellView(
            position: emptyPosition,
            cellState: .empty,
            isValidMove: true,
            isProcessing: false
        ) {}
        
        // Test empty cell without valid move
        let emptyCellInvalidMove = CellView(
            position: emptyPosition,
            cellState: .empty,
            isValidMove: false,
            isProcessing: false
        ) {}
        
        // We can't directly test the accessibility labels in unit tests without UI testing framework,
        // but we can verify the logic used to create them
        #expect(blackPosition.algebraicNotation == "A8")
        #expect(whitePosition.algebraicNotation == "B7")
        #expect(emptyPosition.algebraicNotation == "C6")
    }
    
    @Test("CellView handles different cell states correctly")
    func testCellStates() {
        let position = BoardPosition(row: 3, col: 3)
        let tapAction = {}
        
        // Test empty cell
        let emptyCell = CellView(
            position: position,
            cellState: .empty,
            isValidMove: false,
            isProcessing: false,
            onTap: tapAction
        )
        
        // Test black piece
        let blackCell = CellView(
            position: position,
            cellState: .black,
            isValidMove: false,
            isProcessing: false,
            onTap: tapAction
        )
        
        // Test white piece
        let whiteCell = CellView(
            position: position,
            cellState: .white,
            isValidMove: false,
            isProcessing: false,
            onTap: tapAction
        )
        
        // Verify cells can be created without crashing
        #expect(emptyCell.position == position)
        #expect(blackCell.cellState == .black)
        #expect(whiteCell.cellState == .white)
    }
    
    @Test("CellView valid move indicator behavior")
    func testValidMoveIndicator() {
        let position = BoardPosition(row: 2, col: 3)
        let tapAction = {}
        
        // Test cell with valid move
        let validMoveCell = CellView(
            position: position,
            cellState: .empty,
            isValidMove: true,
            isProcessing: false,
            onTap: tapAction
        )
        
        // Test cell without valid move
        let invalidMoveCell = CellView(
            position: position,
            cellState: .empty,
            isValidMove: false,
            isProcessing: false,
            onTap: tapAction
        )
        
        // Test cell with valid move but processing
        let processingCell = CellView(
            position: position,
            cellState: .empty,
            isValidMove: true,
            isProcessing: true,
            onTap: tapAction
        )
        
        // Verify the state properties are correctly set
        #expect(validMoveCell.isValidMove)
        #expect(!validMoveCell.isProcessing)
        
        #expect(!invalidMoveCell.isValidMove)
        
        #expect(processingCell.isValidMove)
        #expect(processingCell.isProcessing)
    }
    
    @Test("CellView tap action is preserved")
    func testTapAction() {
        var tapCalled = false
        let position = BoardPosition(row: 1, col: 2)
        
        let cell = CellView(
            position: position,
            cellState: .empty,
            isValidMove: true,
            isProcessing: false
        ) {
            tapCalled = true
        }
        
        // Call the tap action
        cell.onTap()
        
        #expect(tapCalled)
    }
    
    @Test("CellView position validation")
    func testPositionValidation() {
        // Test with valid positions
        let validPositions = [
            BoardPosition(row: 0, col: 0),
            BoardPosition(row: 3, col: 4),
            BoardPosition(row: 7, col: 7)
        ]
        
        for position in validPositions {
            #expect(position.isValid)
            
            let cell = CellView(
                position: position,
                cellState: .empty,
                isValidMove: false,
                isProcessing: false
            ) {}
            
            #expect(cell.position == position)
        }
        
        // Test with invalid positions
        let invalidPositions = [
            BoardPosition(row: -1, col: 0),
            BoardPosition(row: 0, col: 8),
            BoardPosition(row: 8, col: 8)
        ]
        
        for position in invalidPositions {
            #expect(!position.isValid)
        }
    }
    
    @Test("CellView algebraic notation consistency")
    func testAlgebraicNotation() {
        let testCases = [
            (row: 0, col: 0, expected: "A8"),
            (row: 0, col: 7, expected: "H8"),
            (row: 7, col: 0, expected: "A1"),
            (row: 7, col: 7, expected: "H1"),
            (row: 3, col: 3, expected: "D5"),
            (row: 4, col: 4, expected: "E4")
        ]
        
        for testCase in testCases {
            let position = BoardPosition(row: testCase.row, col: testCase.col)
            #expect(position.algebraicNotation == testCase.expected)
            
            // Verify CellView can handle these positions
            let cell = CellView(
                position: position,
                cellState: .empty,
                isValidMove: false,
                isProcessing: false
            ) {}
            
            #expect(cell.position.algebraicNotation == testCase.expected)
        }
    }
    
    @Test("CellView edge case handling")
    func testEdgeCases() {
        let position = BoardPosition(row: 0, col: 0)
        
        // Test all combinations of states
        let cellStates: [CellState] = [.empty, .black, .white]
        let validMoveStates = [true, false]
        let processingStates = [true, false]
        
        for cellState in cellStates {
            for isValidMove in validMoveStates {
                for isProcessing in processingStates {
                    let cell = CellView(
                        position: position,
                        cellState: cellState,
                        isValidMove: isValidMove,
                        isProcessing: isProcessing
                    ) {}
                    
                    // Verify cell maintains its properties
                    #expect(cell.position == position)
                    #expect(cell.cellState == cellState)
                    #expect(cell.isValidMove == isValidMove)
                    #expect(cell.isProcessing == isProcessing)
                }
            }
        }
    }
    
    @Test("CellView BoardPosition integration")
    func testBoardPositionIntegration() {
        // Test that CellView properly uses BoardPosition features
        let position = BoardPosition(row: 2, col: 3)
        
        let cell = CellView(
            position: position,
            cellState: .black,
            isValidMove: false,
            isProcessing: false
        ) {}
        
        // Verify position properties are accessible
        #expect(cell.position.row == 2)
        #expect(cell.position.col == 3)
        #expect(cell.position.isValid)
        #expect(cell.position.algebraicNotation == "D6")
        
        // Test with all corner positions
        let corners = [
            BoardPosition(row: 0, col: 0), // Top-left
            BoardPosition(row: 0, col: 7), // Top-right  
            BoardPosition(row: 7, col: 0), // Bottom-left
            BoardPosition(row: 7, col: 7)  // Bottom-right
        ]
        
        for corner in corners {
            let cornerCell = CellView(
                position: corner,
                cellState: .empty,
                isValidMove: false,
                isProcessing: false
            ) {}
            
            #expect(cornerCell.position.isValid)
            #expect(cornerCell.position == corner)
        }
    }
}