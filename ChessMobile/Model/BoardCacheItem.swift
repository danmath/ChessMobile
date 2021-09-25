//
//  BoardCacheItem.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/20/21.
//

import Foundation

struct BoardCacheItem {
    var boardId: UInt64
    var moves: [[[Move]]]
    var currentEvaluation: Int
    var futureEvaluation = 0
    var highestDepth = 0
}
