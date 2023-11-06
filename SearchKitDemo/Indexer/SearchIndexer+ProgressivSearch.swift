//
//  SearchIndexer+ProgressivSearch.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 03.11.23.
//

import Foundation

extension SearchIndexer {
    /// Object representaitng the search results
    public class SearchResult {
        /// The identifying url for the document
        public let url: URL
        
        /// The search score for the codument result, Heigher means more relevant
        public let score: Float
        
         init(url: URL, score: Float) {
            self.url = url
            self.score = score
        }
    }
    
    /// Start a progressive search
    public func progressiveSearch(
        query: String,
        options: SKSearchOptions = SKSearchOptions(kSKSearchOptionDefault)
    ) -> ProgressivSearch {
        return ProgressivSearch(options: options, index: self, query: query)
    }
    
    public class ProgressivSearch {
        public class Results {
            /// Create a search result
            ///
            /// - Parameters:
            ///   - moreResultsAvailable: A boolean indicating whether more search results are available
            ///   - results: The partial results for the search request
            public init(moreResultsAvailable: Bool, results: [SearchResult]) {
                self.moreResultsAvailable = moreResultsAvailable
                self.results = results
            }
            
            /// A boolean indicating whether more search results are available
            public let moreResultsAvailable: Bool
            
            /// The partial results for the search request
            public let results: [SearchResult]
        }
        
        private let options: SKSearchOptions
        private let search: SKSearch
        private let index: SearchIndexer
        private let query: String
        
         init(options: SKSearchOptions, index: SearchIndexer, query: String) {
            self.options = options
            self.search = SKSearchCreate(index.index, query as CFString, options).takeRetainedValue()
            self.index = index
            self.query = query
        }
        
        /// Cancel an active search
        public func cancel() {
            SKSearchCancel(self.search)
        }
        
        
        /// Get the next chunk of result
        public func next(_ limit: Int = 10, timeout: TimeInterval = 1.0) -> (ProgressivSearch.Results) {
            guard self.index.index != nil else {
                return Results(moreResultsAvailable: false, results: [])
            }
            
            var scores: [Float] = Array(repeating: 0.0, count: limit)
            var urls: [Unmanaged<CFURL>?] = Array(repeating: nil, count: limit)
            var documentIDs: [SKDocumentID] = Array(repeating: 0, count: limit)
            var foundCount = 0
            
            let hasMore = SKSearchFindMatches(self.search, limit, &documentIDs, &scores, timeout, &foundCount)
            SKIndexCopyDocumentURLsForDocumentIDs(self.index.index, foundCount, &documentIDs, &urls)
            
            let partialResult: [SearchResult] = zip(urls[0..<foundCount], scores).compactMap { (cfurl, score) -> SearchResult? in
                guard let url  = cfurl?.takeUnretainedValue() as URL? else {
                    return nil
                }
                
                return SearchResult(url: url, score: score)
            }
            
            return Results(moreResultsAvailable: hasMore, results: partialResult)
        }
    }
}
