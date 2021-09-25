//
//  Piece.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/19/21.
//

import Foundation

enum PieceColor {
    case White
    case Black
    case Empty
}

enum PieceType {
    case King
    case Queen
    case Bishop
    case Knight
    case Rook
    case Pawn
    case Empty
}

struct Piece: Hashable {
    var pieceColor: PieceColor
    var pieceType: PieceType
}
