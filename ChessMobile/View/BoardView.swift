//
//  BoardView.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/15/21.
//

import SwiftUI

struct BoardView: View {
    var width: CGFloat
    var height: CGFloat
    var cellWidth: CGFloat = 0
    var cellHeight: CGFloat = 0
    var halfCellWidth: CGFloat = 0
    var halfCellHeight: CGFloat = 0
    @ObservedObject var board: Board = Board()
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint?
    init(_ width: CGFloat, _ height: CGFloat) {
        self.width = width
        self.height = height
        self.cellWidth = width/8
        self.cellHeight = height/8
        self.halfCellWidth = self.cellWidth/2
        self.halfCellHeight = self.cellHeight/2
        }
    var body: some View {
        let tap = TapGesture().onEnded {
            if let tap = dragLocation {
                board.tappedOnLocation(location: tap)
            }
        }
        let drag = DragGesture(minimumDistance: 0).onChanged { value in
            dragLocation = value.location
        }.sequenced(before: tap)
        VStack {
            HStack {
                Button {
                    print("board reset")
                    board.reset()
                } label: {
                    Text("Reset Board")
                }
                Button {
                    print("board reset")
                    board.reset()
                } label: {
                    Text("Confirm Move")
                }
            }

            ZStack {
                CheckerboardShape(rows: Board.HEIGHT, columns: Board.WIDTH).border(Color.black).foregroundColor(Color.red)
                SelectedShape(selectedX: board.pieceSelectedX ?? -1, selectedY: board.pieceSelectedY ?? -1, rows: Board.WIDTH, columns: Board.HEIGHT, width: width, height: height).foregroundColor(Color.green)
                SelectedShape(selectedX: board.moveSelectedX ?? -1, selectedY: board.moveSelectedY ?? -1, rows: Board.WIDTH, columns: Board.HEIGHT, width: width, height: height).foregroundColor(Color.orange)
                let heighWidth = Board.WIDTH * Board.HEIGHT
                ForEach(0..<heighWidth) { x in
                    let xx = x%Board.WIDTH
                    let yy = x/Board.HEIGHT
                    board.imageRepresentation[xx][yy].position(x: (self.halfCellWidth+(CGFloat(xx)*self.cellWidth)), y: self.halfCellHeight+(CGFloat(yy)*self.cellHeight))
                }
            }.frame(width: width, height: height, alignment: Alignment.center)
            .gesture(drag)
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.width)
    }
}
