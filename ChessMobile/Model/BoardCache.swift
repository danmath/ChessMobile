//
//  BoardCache.swift
//  ChessMobile
//
//  Created by Daniel Mathews on 9/20/21.
//

import Foundation

class BoardCache {
    static var CAPACITY = 10000
    var cache = [UInt64: BoardCacheItem]()
    func storeOrUpdateBoardCacheItem(boardCacheItem: BoardCacheItem) {
        if(cache[boardCacheItem.boardId] != nil) {
            if(boardCacheItem.highestDepth > cache[boardCacheItem.boardId]!.highestDepth) {
                cache[boardCacheItem.boardId]?.currentEvaluation = boardCacheItem.currentEvaluation
                cache[boardCacheItem.boardId]?.highestDepth = boardCacheItem.highestDepth
            }
        }
        else {
            cache[boardCacheItem.boardId] = boardCacheItem
        }
    }
    func findBoardCacheItem(boardId: UInt64) -> BoardCacheItem? {
        if let item = cache[boardId] {
            return item
        }
        return nil
    }
    func clear() {
        cache.removeAll()
    }
}
