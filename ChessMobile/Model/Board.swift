//
//  Board.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/15/21.
//

import Foundation
import SwiftUI
import Combine

class Board: ObservableObject {
    static var zobrist_array = [[[Piece: UInt64]]]()
    static var zobrist_white_moves = random64(upper_bound: UInt64.max)
    static var zobrist_castling_white = [UInt64]()
    static var zobrist_castling_black = [UInt64]()
    static var zobrist_en_pesante = [UInt64]()
    var zobrist_signature: UInt64 = 0// 0 is the default number for the start of the game
    static var WIDTH = 8
    static var HEIGHT = 8
    var representation = [[Piece]]()
    @Published var imageRepresentation = [[Image?]]()
    @Published var pieceSelectedX: Int?
    @Published var pieceSelectedY: Int?
    @Published var moveSelectedX: Int?
    @Published var moveSelectedY: Int?
    var currentScore = 0
    var whiteMoves = true
    var moves = [[[Move]]]()
    var blackCanLeftCastle = true
    var blackCanRightCastle = true
    var whiteCanLeftCastle = true
    var whiteCanRightCastle = true
    var enPessanteWhiteArray = [Bool]()
    var enPessanteBlackArray = [Bool]()
    var boardCache = BoardCache()
    
    init() {
        self.reset()
    }
    
    func reset() {
        Board.generateZobristArray()
        self.representation = [[Piece]]()
        self.imageRepresentation = [[Image?]]()
        for x in 0..<Board.WIDTH {
            self.representation.append([Piece]())
            self.imageRepresentation.append([Image?]())
            for _ in 0..<Board.HEIGHT {
                representation[x].append(Piece(pieceColor: PieceColor.Empty, pieceType: PieceType.Empty))
                imageRepresentation[x].append(nil)
            }
        }
        
        //set the Kings
        self.representation[4][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.King)
        self.representation[4][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.King)
        
        //set the Queens
        self.representation[3][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Queen)
        self.representation[3][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Queen)
        
        //set the Bishops
        self.representation[2][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Bishop)
        self.representation[2][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Bishop)
        self.representation[5][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Bishop)
        self.representation[5][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Bishop)
        
        //set the Knights
        self.representation[1][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Knight)
        self.representation[1][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Knight)
        self.representation[6][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Knight)
        self.representation[6][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Knight)
        
        //set the Rooks
        self.representation[0][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Rook)
        self.representation[0][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Rook)
        self.representation[7][0] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Rook)
        self.representation[7][7] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Rook)
        
        //set the Pawns
        for i in 0..<8 {
            self.representation[i][1] = Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Pawn)
            self.representation[i][6] = Piece(pieceColor: PieceColor.White, pieceType: PieceType.Pawn)
        }
        
        self.currentScore = 0
        self.whiteMoves = true
        self.blackCanLeftCastle = true
        self.blackCanRightCastle = true
        self.whiteCanLeftCastle = true
        self.whiteCanRightCastle = true
        self.zobrist_signature = 0
        for _ in 0..<Board.WIDTH {
            self.enPessanteWhiteArray.append(false)
            self.enPessanteBlackArray.append(false)
        }
        self.boardCache.clear()
        self.mapRepresentationToImages()
    }
    
    //this function generates random numbers to eventaully generate an id that will represent the board
    static func generateZobristArray() {
        for x in 0..<Board.WIDTH {
            zobrist_array.append([[Piece: UInt64]]())
            for y in 0..<Board.HEIGHT {
                zobrist_array[x].append([Piece: UInt64]())
                zobrist_array[x][y][Piece(pieceColor: PieceColor.White, pieceType: PieceType.Bishop)] = random64(upper_bound: UInt64.max)
                zobrist_array[x][y][Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Bishop)] = random64(upper_bound: UInt64.max)
                
                zobrist_array[x][y][Piece(pieceColor: PieceColor.White, pieceType: PieceType.King)] = random64(upper_bound: UInt64.max)
                zobrist_array[x][y][Piece(pieceColor: PieceColor.Black, pieceType: PieceType.King)] = random64(upper_bound: UInt64.max)
                
                zobrist_array[x][y][Piece(pieceColor: PieceColor.White, pieceType: PieceType.Knight)] = random64(upper_bound: UInt64.max)
                zobrist_array[x][y][Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Knight)] = random64(upper_bound: UInt64.max)
                
                zobrist_array[x][y][Piece(pieceColor: PieceColor.White, pieceType: PieceType.Pawn)] = random64(upper_bound: UInt64.max)
                zobrist_array[x][y][Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Pawn)] = random64(upper_bound: UInt64.max)
                
                zobrist_array[x][y][Piece(pieceColor: PieceColor.White, pieceType: PieceType.Queen)] = random64(upper_bound: UInt64.max)
                zobrist_array[x][y][Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Queen)] = random64(upper_bound: UInt64.max)
                
                zobrist_array[x][y][Piece(pieceColor: PieceColor.White, pieceType: PieceType.Rook)] = random64(upper_bound: UInt64.max)
                zobrist_array[x][y][Piece(pieceColor: PieceColor.Black, pieceType: PieceType.Rook)] = random64(upper_bound: UInt64.max)
            }
        }
        zobrist_white_moves = random64(upper_bound: UInt64.max)
        for _ in 0..<2 {//0 == left, 1 == right
            zobrist_castling_white.append(random64(upper_bound: UInt64.max))
            zobrist_castling_black.append(random64(upper_bound: UInt64.max))
        }
        for _ in 0..<Board.WIDTH {
            zobrist_en_pesante.append(random64(upper_bound: UInt64.max))
        }
    }
    
    func mapRepresentationToImages() {
        for x in 0..<Board.WIDTH {
            for y in 0..<Board.HEIGHT {
                self.imageRepresentation[x][y] = self.imageForPieceAtPosition(x: x, y: y)
            }
        }
    }
    
    func imageForPieceAtPosition(x: Int, y: Int) -> Image? {
        var imageName = ""
        switch(representation[x][y].pieceColor) {
        case .White:
            imageName = "White"
        case .Black:
            imageName = "Black"
        case .Empty:
            return nil
        }
        switch(representation[x][y].pieceType) {
            
        case .King:
            imageName += "King"
        case .Queen:
            imageName += "Queen"
        case .Bishop:
            imageName += "Bishop"
        case .Knight:
            imageName += "Knight"
        case .Rook:
            imageName += "Rook"
        case .Pawn:
            imageName += "Pawn"
        case .Empty:
            return nil
        }
        return Image(imageName)
    }
    
    func tappedOnLocation(location: CGPoint) {
        let x = Int((location.x * 8)/UIScreen.main.bounds.size.width)
        let y = Int((location.y * 8)/UIScreen.main.bounds.size.width)
        let piece = self.representation[x][y]
        if((piece.pieceColor == .White && self.whiteMoves) || (piece.pieceColor == .Black && !self.whiteMoves)) {
            self.pieceSelectedX = x
            self.pieceSelectedY = y
        }
        else if(self.pieceSelectedX != -1) {
            self.moveSelectedX = x
            self.moveSelectedY = y
        }
    }
    
    static func random64(upper_bound: UInt64) -> UInt64 {

        // Generate 64-bit random value in a range that is
        // divisible by upper_bound:
        let range = UInt64.max - UInt64.max % upper_bound
        var rnd : UInt64 = 0
        repeat {
            arc4random_buf(&rnd, MemoryLayout.size(ofValue: rnd))
        } while rnd >= range

        return rnd % upper_bound
    }
    
    func generateMoves() {
        let boardCacheItem = boardCache.findBoardCacheItem(boardId: self.zobrist_signature)
        if(boardCacheItem != nil) {
            if let moves = boardCacheItem?.moves {
                self.moves = moves
                return
            }
        }
        var moves = [[[Move]]]()
        for x in 0..<Board.WIDTH {
            moves.append([[Move]]())
            for y in 0..<Board.HEIGHT {
                moves[x].append([Move]())
                let piece = representation[x][y]
                let pieceType = piece.pieceType
                let pieceColor = piece.pieceColor
                if(pieceColor != .Empty && self.whiteMoves == (pieceColor == .White)) {
                    switch pieceType {
                    case .King:
                        if((pieceColor == .Black && blackCanLeftCastle) || (pieceColor == .White && whiteCanLeftCastle)) {//check for left castle
                            if(representation[x-1][y].pieceType == PieceType.Empty && representation[x-2][y].pieceType == PieceType.Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-2, destinationY: y, capturedPiece: representation[x-2][y]))
                            }
                        }
                        if((pieceColor == PieceColor.Black && blackCanRightCastle) || (pieceColor == PieceColor.White && whiteCanRightCastle)) {//check for right castle
                            if(representation[x+1][y].pieceType == PieceType.Empty && representation[x+2][y].pieceType == PieceType.Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+2, destinationY: y, capturedPiece: representation[x+2][y]))
                            }
                        }
                        if(y > 0 && representation[x][y-1].pieceColor != pieceColor) {
                            moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y-1, capturedPiece: representation[x][y-1]))
                        }
                        if(y < Board.HEIGHT-1 && representation[x][y+1].pieceColor != pieceColor) {
                            moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y+1, capturedPiece: representation[x][y-1]))
                        }
                        if(x > 0 && representation[x-1][y].pieceColor != pieceColor) {
                            moves[x][y].append(Move(originX: x, originY: y, destinationX: x-1, destinationY: y, capturedPiece: representation[x][y-1]))
                        }
                        if(x < Board.WIDTH-1 && representation[x+1][y].pieceColor != pieceColor) {
                            moves[x][y].append(Move(originX: x, originY: y, destinationX: x+1, destinationY: y, capturedPiece: representation[x][y-1]))
                        }
                        break
                    case .Queen:
                        //check vetical
                        for i in 1..<Board.WIDTH-x {
                            let targetPiece = representation[x+i][y]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1...x {
                            let targetPiece = representation[x-i][y]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        //check horizontal
                        for i in 1..<Board.HEIGHT-y {
                            let targetPiece = representation[x][y+i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y+i, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y+i, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1...y {
                            let targetPiece = representation[x][y-i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y-1, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y-1, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                    case .Bishop:
                        //check diagonal
                        for i in 1..<Board.WIDTH {
                            if(y-i < 0) {
                                break
                            }
                            let targetPiece = representation[x-i][y-i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y-1, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y-1, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1..<Board.WIDTH {
                            if(y+i == Board.HEIGHT) {
                                break
                            }
                            let targetPiece = representation[x-i][y+i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y+1, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y+1, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1...x {
                            if(y-i < 0) {
                                break
                            }
                            let targetPiece = representation[x+i][y-i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y-1, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y-1, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1...x {
                            if(y+i == Board.HEIGHT) {
                                break
                            }
                            let targetPiece = representation[x+i][y+i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y+1, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y+1, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        break
                    case .Knight:
                        if(x+2 < Board.WIDTH) {
                            if(y+1 < Board.HEIGHT) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+2, destinationY: y+1, capturedPiece: representation[x+2][y+1]))
                            }
                            if(y-1 >= 0) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+2, destinationY: y-1, capturedPiece: representation[x+2][y-1]))
                            }
                        }
                        if(x+1 < Board.WIDTH) {
                            if(y+1 < Board.HEIGHT) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+1, destinationY: y+1, capturedPiece: representation[x+1][y+1]))
                            }
                            if(y-1 >= 0) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+1, destinationY: y-1, capturedPiece: representation[x+1][y-1]))
                            }
                        }
                        if(x-2 >= 0) {
                            if(y+1 < Board.HEIGHT) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-2, destinationY: y+1, capturedPiece: representation[x-2][y+1]))
                            }
                            if(y-1 >= 0) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-2, destinationY: y-1, capturedPiece: representation[x-2][y-1]))
                            }
                        }
                        if(x-1 >= 0) {
                            if(y+1 < Board.HEIGHT) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-1, destinationY: y+1, capturedPiece: representation[x-1][y+1]))
                            }
                            if(y-1 >= 0) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-1, destinationY: y-1, capturedPiece: representation[x-1][y-1]))
                            }
                        }
                        break
                    case .Rook:
                        //check vertical
                        for i in 1..<Board.WIDTH-x {
                            let targetPiece = representation[x+i][y]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x+i, destinationY: y, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1...x {
                            let targetPiece = representation[x-i][y]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x-i, destinationY: y, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        //check horizontal
                        for i in 1..<Board.HEIGHT-y {
                            let targetPiece = representation[x][y+i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y+i, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y+i, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        for i in 1...y {
                            let targetPiece = representation[x][y-i]
                            if(targetPiece.pieceColor == .Empty) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y-1, capturedPiece: targetPiece))
                            }
                            else if((targetPiece.pieceColor == .White) != whiteMoves) {
                                moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y-1, capturedPiece: targetPiece))
                                break
                            }
                            else {
                                break
                            }
                        }
                        break
                    case .Pawn:
                        if(pieceColor == .White) {//white goes up
                            if(y > 0) {
                                //check if pawn can move forward
                                if(representation[x][y-1].pieceColor == .Empty) {
                                    moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y-1, capturedPiece: representation[x][y-1]))
                                }
                                //check if pawn can capture a piece
                                if(x > 0 && representation[x-1][y-1].pieceColor != .Empty && representation[x-1][y-1].pieceColor != pieceColor) {
                                    moves[x][y].append(Move(originX: x, originY: y, destinationX: x-1, destinationY: y-1, capturedPiece: representation[x-1][y-1]))
                                }
                                if(x < Board.WIDTH-1 && representation[x+1][y-1].pieceColor != .Empty && representation[x+1][y-1].pieceColor != pieceColor) {
                                    moves[x][y].append(Move(originX: x, originY: y, destinationX: x+1, destinationY: y-1, capturedPiece: representation[x+1][y-1]))
                                }
                            }
                        }
                        else {
                            if(y < Board.HEIGHT-1) {
                                //check if pawn can move forward
                                if(representation[x][y+1].pieceColor == .Empty) {
                                    moves[x][y].append(Move(originX: x, originY: y, destinationX: x, destinationY: y+1, capturedPiece: representation[x][y+1]))
                                }
                                //check if pawn can capture a piece
                                if(x > 0 && representation[x-1][y+1].pieceColor != .Empty && representation[x-1][y+1].pieceColor != pieceColor) {
                                    moves[x][y].append(Move(originX: x, originY: y, destinationX: x-1, destinationY: y+1, capturedPiece: representation[x-1][y+1]))
                                }
                                if(x < Board.WIDTH-1 && representation[x+1][y+1].pieceColor != .Empty && representation[x+1][y+1].pieceColor != pieceColor) {
                                    moves[x][y].append(Move(originX: x, originY: y, destinationX: x+1, destinationY: y+1, capturedPiece: representation[x+1][y+1]))
                                }
                            }
                        }
                        break
                    case .Empty:
                        break
                    }
                }
            }
        }
        self.moves = moves
    }
    
    func generateBoardState() {
        
    }
    
    func generateScoreForCurrentMoves(depth: Int) {
        generateMoves()
        if(whiteMoves) {
            for x in 0..<Board.WIDTH {
                for y in 0..<Board.HEIGHT {
                    for i in 0..<moves[x][y].count {
                        moves[x][y][i].bestScore = maxScore(move: moves[x][y][i], depth: depth-1)
                        moves[x][y][i].highestDepth = depth
                    }
                }
            }
        }
        else {
            for x in 0..<Board.WIDTH {
                for y in 0..<Board.HEIGHT {
                    for i in 0..<moves[x][y].count {
                        moves[x][y][i].bestScore = minScore(move: moves[x][y][i], depth: depth-1)
                        moves[x][y][i].highestDepth = depth
                    }
                }
            }
        }
    }
    
    func minScore(move: Move, depth: Int) -> Int {
        var min = Int.max
        doMove(move: move)
        generateMoves()
        for x in 0..<Board.WIDTH {
            for y in 0..<Board.HEIGHT {
                for i in 0..<moves[x][y].count {
                    if let cachedBoardItem = boardCache.findBoardCacheItem(boardId: self.zobrist_signature) { if(cachedBoardItem.moves[x][y][i].highestDepth >= depth) {
                            let result = cachedBoardItem.moves[x][y][i].bestScore
                            if(min > result) {
                                min = result
                            }
                        }
                        else {
                            let result = maxScore(move: moves[x][y][i], depth: depth-1)
                            if(min > result) {
                                min = result
                            }
                        }
                    }
                    else {
                        let result = maxScore(move: moves[x][y][i], depth: depth-1)
                        if(min > result) {
                            min = result
                        }
                    }
                }
            }
        }
        undoMove(move: move)
        boardCache.storeOrUpdateBoardCacheItem(boardCacheItem: BoardCacheItem(boardId: self.zobrist_signature, moves: self.moves, currentEvaluation: self.currentScore, futureEvaluation: min, highestDepth: depth))
        return min
    }
    
    func maxScore(move: Move, depth: Int) -> Int {
        var max = Int.min
        doMove(move: move)
        generateMoves()
        for x in 0..<Board.WIDTH {
            for y in 0..<Board.HEIGHT {
                for i in 0..<moves[x][y].count {
                    if let cachedBoardItem = boardCache.findBoardCacheItem(boardId: self.zobrist_signature) {
                        if(cachedBoardItem.moves[x][y][i].highestDepth >= depth) {
                            let result = cachedBoardItem.moves[x][y][i].bestScore
                            if(max < result) {
                                max = result
                            }
                        }
                    }
                    else {
                        let result = minScore(move: moves[x][y][i], depth: depth-1)
                        if(max < result) {
                            max = result
                        }
                    }
                }
            }
        }
        undoMove(move: move)
        boardCache.storeOrUpdateBoardCacheItem(boardCacheItem: BoardCacheItem(boardId: self.zobrist_signature, moves: self.moves, currentEvaluation: self.currentScore, futureEvaluation: max, highestDepth: depth))
        return max
    }
    
    func addOrRemovePiece(x: Int, y: Int, piece: Piece) {
        zobrist_signature ^= Board.zobrist_array[x][y][piece] ?? 0
    }
    
    func confirmMove() {
        
    }
    
    func doMove(move: Move) {
        var scoreChange = pieceValue(piece: move.capturedPiece)
        if(!self.whiteMoves) {
            scoreChange *= -1
        }
        addOrRemovePiece(x: move.originY, y: move.originY, piece: representation[move.originX][move.originY])
        addOrRemovePiece(x: move.destinationX, y: move.destinationY, piece: representation[move.originX][move.originY])
        if(representation[move.destinationX][move.destinationY].pieceType != PieceType.Empty) {
            addOrRemovePiece(x: move.destinationX, y: move.destinationY, piece: representation[move.destinationX][move.destinationY])
        }
        
        representation[move.originX][move.originY] = Piece(pieceColor: .Empty, pieceType: .Empty)
        representation[move.destinationX][move.destinationY] = representation[move.originX][move.originY]
        
        currentScore += scoreChange
        moves = [[[Move]]]()
        whiteMoves = !whiteMoves
    }
    
    func undoMove(move: Move) {
        var scoreChange = pieceValue(piece: move.capturedPiece)
        if(self.whiteMoves) {
            scoreChange *= -1
        }
        addOrRemovePiece(x: move.destinationX, y: move.destinationY, piece: representation[move.destinationX][move.destinationY])
        addOrRemovePiece(x: move.originX, y: move.originY, piece: representation[move.destinationX][move.destinationY])
        if(move.capturedPiece.pieceType != PieceType.Empty) {
            addOrRemovePiece(x: move.destinationX, y: move.destinationY, piece: move.capturedPiece)
        }
        
        representation[move.originX][move.originY] = representation[move.destinationX][move.destinationY]
        representation[move.destinationX][move.destinationY] = move.capturedPiece
        
        currentScore += scoreChange
        moves = [[[Move]]]()
        whiteMoves = !whiteMoves
    }
    
    func pieceValue(piece: Piece) -> Int {
        switch(piece.pieceType) {
        case .King:
            return 1000
        case .Queen:
            return 9
        case .Bishop:
            return 3
        case .Knight:
            return 3
        case .Rook:
            return 5
        case .Pawn:
            return 1
        case .Empty:
            return 0
        }
    }
}
