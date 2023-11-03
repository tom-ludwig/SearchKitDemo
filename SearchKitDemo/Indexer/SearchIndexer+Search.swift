//
//  SearchIndexer+Search.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 03.11.23.
//

import Foundation

extension SearchIndexer {
    /// Perform a search
    ///
    /// - Parameters:
    ///   - query: A string containing the term(s) to be searched for
    ///   - limit: The maximum number of results to return
    ///   - timeout: How long to wait for a search to complete before stopping
    /// - Returns: An array containing match URLs and their corresponding 'score' (how relevant the match)
    @objc
    public func search(
        _ query: String,
        limit: Int = 10,
        timeout: TimeInterval = 1.0,
        options: SKSearchOptions = SKSearchOptions(kSKSearchOptionDefault)
    ) -> [SearchResult] {
        let search = self.progressiveSearch(query: query, options: options)
        
        var results: [SearchResult] = []
        var moreResultsAvailable = true
        repeat {
            let result = search.next(limit, timeout: timeout)
            results.append(contentsOf: result.results)
            moreResultsAvailable = result.moreResultsAvailable
        } while moreResultsAvailable
        
        // TODO: Change this to something like async stream to get the results asynchronously
        return results
    }
}
