//
//  SearchIndexer+Terms.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 03.11.23.
//

import Foundation

extension SearchIndexer {
    /// A class to contain a term and the count of times it appears
    public class TermCount: NSObject {
        /// A term within the document
        public let term: String
        
        /// The number of occurrences of `term`
        public let count: Int
        
         init(term: String, count: Int) {
            self.term = term
            self.count = count
            super.init()
        }
        
        public override var debugDescription: String {
            return "Term: '\(self.term)', Count: \(self.count)'"
        }
    }
    
    /// A enum to specify the state of the document
    public enum TermState: Int {
        /// All document states
        case All = 0
        /// Only documents that have no terms
        case Empty = 1
        /// Only documents that have terms
        case NotEmpty = 2
    }
    
    /// Returns all the document URLs loaded into the index matching the specified term state
    ///
    /// - Parameter termState: Only return documents matching the specified document state
    /// - Returns: An array containing all the document URLs
    public func documents(termState: TermState = .All) -> [URL] {
        return self.fullDocuments(termState: termState).map { $0.0 }
    }
    
    /// Returns the number of terms for the specified document url
    public func termCount(for url: URL) -> Int {
        if let index = self.index,
           let document = SKDocumentCreateWithURL(url as CFURL) {
            let documentID = SKIndexGetDocumentID(index, document.takeUnretainedValue())
            return SKIndexGetDocumentTermCount(index, documentID)
        }
        return 0
    }
    
    /// Is the specified document empty (ie. it has no terms)
    public func isEmpty(for url: URL) -> Bool {
        return self.termCount(for: url) > 0
    }
    
    /// Returns an array containing the terms and counts for a specified URL
    ///
    /// - Parameter url: The document URL in the index to locate
    /// - Returns: An array of the terms and corresponding counts located in the document.
    ///            Returns an empty array if the document cannot be located.
    public func terms(for url: URL) -> [TermCount] {
        guard let index = self.index else {
            return []
        }
        
        var result = [TermCount]()
        
        let document = SKDocumentCreateWithURL(url as CFURL).takeUnretainedValue()
        let documentID = SKIndexGetDocumentID(index, document)
        
        guard let termVals = SKIndexCopyTermIDArrayForDocumentID(index, documentID),
              let terms = termVals.takeUnretainedValue() as? [CFIndex] else {
            return []
        }
        
        for term in terms {
            if let termVal = SKIndexCopyTermStringForTermID(index, term) {
                let termString = termVal.takeUnretainedValue() as String
                if !self.stopWords.contains(termString) {
                    let count = SKIndexGetDocumentTermFrequency(index, documentID, term) as Int
                    result.append(TermCount(term: termString, count: count))
                }
            }
        }
        
        return result
    }
}
