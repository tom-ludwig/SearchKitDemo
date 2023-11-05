//
//  SearchIndexer+Indexer.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 03.11.23.
//

import Foundation

extension SearchIndexer {
    /// Flush any pending commands to the search index. Flush should always be called before performing a search
    public func flush() {
        if let index = self.index {
            SKIndexFlush(index)
        }
    }
    
    /// Reduce the size of index where possible, do NOT call on the main thread
    public func compact() {
        if let index = self.index {
            SKIndexCompact(index)
        }
    }
    
    /// Remove any documents that have no search terms
    public func cleanUp(progress: ((Int, Int) -> Void)?) -> Int {
        let allDocs = self.fullDocuments(termState: .Empty)
        let totalCount = allDocs.count
        var removedCount = 0
        for docID in allDocs {
            _ = self.remove(document: docID.1)
            removedCount += 1
            progress?(totalCount, totalCount)
        }
        return removedCount
    }
}
