//
//  SelectedShape.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/24/21.
//

import SwiftUI

struct SelectedShape: Shape {
    var selectedX: Int
    var selectedY: Int
    var rows: Int
    var columns: Int
    var width: CGFloat
    var height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if(selectedX != -1) {
            let startX = (CGFloat(selectedX) * width)/CGFloat(columns)
            let startY = (CGFloat(selectedY) * height)/CGFloat(rows)
            let w = width/CGFloat(columns)
            let h = height/CGFloat(rows)
            let rect = CGRect(x: startX, y: startY, width: w, height: h)
            path.addRect(rect)
        }
        return path
    }
}
