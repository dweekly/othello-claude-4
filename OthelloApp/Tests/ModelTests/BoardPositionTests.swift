//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import Testing
import Foundation
@testable import OthelloCore

@Suite("BoardPosition Tests")
struct BoardPositionTests {
    
    @Test("Valid positions are correctly identified")
    func testValidPositions() {
        #expect(BoardPosition(row: 0, col: 0).isValid)
        #expect(BoardPosition(row: 7, col: 7).isValid)
        #expect(BoardPosition(row: 3, col: 4).isValid)
    }
    
    @Test("Invalid positions are correctly identified")
    func testInvalidPositions() {
        #expect(!BoardPosition(row: -1, col: 0).isValid)
        #expect(!BoardPosition(row: 0, col: -1).isValid)
        #expect(!BoardPosition(row: 8, col: 0).isValid)
        #expect(!BoardPosition(row: 0, col: 8).isValid)
        #expect(!BoardPosition(row: -1, col: -1).isValid)
        #expect(!BoardPosition(row: 8, col: 8).isValid)
    }
    
    @Test("Algebraic notation conversion", arguments: [
        (BoardPosition(row: 0, col: 0), "A8"),
        (BoardPosition(row: 0, col: 7), "H8"),
        (BoardPosition(row: 7, col: 0), "A1"),
        (BoardPosition(row: 7, col: 7), "H1"),
        (BoardPosition(row: 3, col: 3), "D5"),
        (BoardPosition(row: 4, col: 4), "E4")
    ])
    func testAlgebraicNotation(position: BoardPosition, expected: String) {
        #expect(position.algebraicNotation == expected)
    }
    
    @Test("Algebraic notation parsing", arguments: [
        ("A8", BoardPosition(row: 0, col: 0)),
        ("H8", BoardPosition(row: 0, col: 7)),
        ("A1", BoardPosition(row: 7, col: 0)),
        ("H1", BoardPosition(row: 7, col: 7)),
        ("D5", BoardPosition(row: 3, col: 3)),
        ("E4", BoardPosition(row: 4, col: 4))
    ])
    func testAlgebraicNotationParsing(notation: String, expected: BoardPosition) {
        let parsed = BoardPosition.from(algebraicNotation: notation)
        #expect(parsed == expected)
    }
    
    @Test("Invalid algebraic notation returns nil")
    func testInvalidAlgebraicNotation() {
        #expect(BoardPosition.from(algebraicNotation: "I1") == nil) // Invalid column
        #expect(BoardPosition.from(algebraicNotation: "A9") == nil) // Invalid row
        #expect(BoardPosition.from(algebraicNotation: "A") == nil)  // Too short
        #expect(BoardPosition.from(algebraicNotation: "A10") == nil) // Too long
        #expect(BoardPosition.from(algebraicNotation: "Z1") == nil) // Invalid column
        #expect(BoardPosition.from(algebraicNotation: "A0") == nil) // Invalid row
        #expect(BoardPosition.from(algebraicNotation: "") == nil)   // Empty
    }
    
    @Test("All positions count is correct")
    func testAllPositionsCount() {
        let allPositions = BoardPosition.allPositions
        #expect(allPositions.count == 64)
        
        // Verify all positions are unique
        let uniquePositions = Set(allPositions)
        #expect(uniquePositions.count == 64)
    }
    
    @Test("All positions are valid")
    func testAllPositionsAreValid() {
        for position in BoardPosition.allPositions {
            #expect(position.isValid, "Position \(position) should be valid")
        }
    }
    
    @Test("Adjacent directions for corner positions")
    func testAdjacentDirectionsCorner() {
        let topLeft = BoardPosition(row: 0, col: 0)
        #expect(topLeft.adjacentDirections.count == 3)
        
        let topRight = BoardPosition(row: 0, col: 7)
        #expect(topRight.adjacentDirections.count == 3)
        
        let bottomLeft = BoardPosition(row: 7, col: 0)
        #expect(bottomLeft.adjacentDirections.count == 3)
        
        let bottomRight = BoardPosition(row: 7, col: 7)
        #expect(bottomRight.adjacentDirections.count == 3)
    }
    
    @Test("Adjacent directions for edge positions")
    func testAdjacentDirectionsEdge() {
        let topEdge = BoardPosition(row: 0, col: 3)
        #expect(topEdge.adjacentDirections.count == 5)
        
        let leftEdge = BoardPosition(row: 3, col: 0)
        #expect(leftEdge.adjacentDirections.count == 5)
        
        let rightEdge = BoardPosition(row: 3, col: 7)
        #expect(rightEdge.adjacentDirections.count == 5)
        
        let bottomEdge = BoardPosition(row: 7, col: 3)
        #expect(bottomEdge.adjacentDirections.count == 5)
    }
    
    @Test("Adjacent directions for center positions")
    func testAdjacentDirectionsCenter() {
        let center = BoardPosition(row: 3, col: 3)
        #expect(center.adjacentDirections.count == 8)
        
        let anotherCenter = BoardPosition(row: 4, col: 4)
        #expect(anotherCenter.adjacentDirections.count == 8)
    }
    
    @Test("Offset method works correctly")
    func testOffsetMethod() {
        let position = BoardPosition(row: 3, col: 3)
        
        // Valid offsets
        #expect(position.offset(row: 1, col: 0) == BoardPosition(row: 4, col: 3))
        #expect(position.offset(row: -1, col: 0) == BoardPosition(row: 2, col: 3))
        #expect(position.offset(row: 0, col: 1) == BoardPosition(row: 3, col: 4))
        #expect(position.offset(row: 0, col: -1) == BoardPosition(row: 3, col: 2))
        #expect(position.offset(row: 1, col: 1) == BoardPosition(row: 4, col: 4))
        
        // Invalid offsets (would go out of bounds)
        let corner = BoardPosition(row: 0, col: 0)
        #expect(corner.offset(row: -1, col: 0) == nil)
        #expect(corner.offset(row: 0, col: -1) == nil)
        #expect(corner.offset(row: -1, col: -1) == nil)
        
        let oppositeCorner = BoardPosition(row: 7, col: 7)
        #expect(oppositeCorner.offset(row: 1, col: 0) == nil)
        #expect(oppositeCorner.offset(row: 0, col: 1) == nil)
        #expect(oppositeCorner.offset(row: 1, col: 1) == nil)
    }
    
    @Test("Accessibility description is correct")
    func testAccessibilityDescription() {
        let position1 = BoardPosition(row: 0, col: 0)
        #expect(position1.accessibilityDescription == "Row 1, Column 1")
        
        let position2 = BoardPosition(row: 3, col: 4)
        #expect(position2.accessibilityDescription == "Row 4, Column 5")
        
        let position3 = BoardPosition(row: 7, col: 7)
        #expect(position3.accessibilityDescription == "Row 8, Column 8")
        
        let invalidPosition = BoardPosition(row: -1, col: 0)
        #expect(invalidPosition.accessibilityDescription == "Invalid position")
    }
    
    @Test("Hashable conformance works correctly")
    func testHashableConformance() {
        let position1 = BoardPosition(row: 3, col: 3)
        let position2 = BoardPosition(row: 3, col: 3)
        let position3 = BoardPosition(row: 3, col: 4)
        
        #expect(position1 == position2)
        #expect(position1 != position3)
        
        let set: Set<BoardPosition> = [position1, position2, position3]
        #expect(set.count == 2) // position1 and position2 are the same
    }
    
    @Test("Codable conformance works correctly")
    func testCodableConformance() throws {
        let position = BoardPosition(row: 3, col: 4)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(position)
        
        let decoder = JSONDecoder()
        let decodedPosition = try decoder.decode(BoardPosition.self, from: data)
        
        #expect(decodedPosition == position)
    }
}