//
//  Move.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/15/21.
//

import Foundation

struct Move {
    var originX: Int
    var originY: Int
    var destinationX: Int
    var destinationY: Int
    var capturedPiece: Piece
    var bestScore = 0
    var highestDepth = 0
}
