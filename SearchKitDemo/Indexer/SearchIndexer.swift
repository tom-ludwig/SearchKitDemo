//
//  SearchIndexer.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

/// Provide the equivalent of @synchronised on objc
public func synchronised<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try body()
}

/// Ensures that critical sections of code only run on one thread at a time
public class Synchronised {
    private static let queue = DispatchQueue(label: "com.activcoding.SearchKitDemo")
    
    public class func withLock<T>(_ closure: () -> T) -> T {
        var result: T!
        queue.sync {
            result = closure()
        }
        return result
    }
}

/// Indexer using SKIndex
@objc public class SearchIndexer: NSObject {
    let queue = DispatchQueue(label: "com.activcoding.SearchKitDemo")
    @objc(SearchIndexerType)
    public enum IndexType: UInt32 {
        /// Unknown index type (kSKIndexUnknown)
        case unknown = 0
        /// Inverted index, mapping terms to documents (kSKIndexInverted)
        case inverted = 1
        /// Vector index, mapping documents to terms (kSKIndexVector)
        case vector = 2
        /// Index type with all the capabilities of an inverted and a vector index (kSKIndexInvertedVector)
        case invertedVector = 3
    }
    
    @objc(SearchIndexerCreateProperties)
    public class CreateProperties: NSObject {
        /// The type of the index to be created
        private(set) var indexType: SKIndexType = kSKIndexInverted
        /// Whether the index should use proximity indexing
        private(set) var proximityIndexing: Bool = false
        /// The stop words for the index
        private(set) var stopWords: Set<String> = Set<String>()
        /// The minimum size of word to add to the index
        private(set) var minTermLength: UInt = 1
        
        /// Create a properties object with the specified creation parameters
        ///
        /// - Parameters:
        ///   - indexType: The type of index
        ///   - proximityIndexing: A Boolean flag indicating whether or not Search Kit should use proximity indexing
        ///   - stopWords: A set of stopwords — words not to index
        ///   - minTermLength: The minimum term length to index (defaults to 1)
        public init(
            indexType: SearchIndexer.IndexType = .inverted,
            proximityIndexing: Bool = false,
            stopWords: Set<String> = [],
            minTermLengh: UInt = 1
        ) {
            self.indexType = SKIndexType(indexType.rawValue)
            self.proximityIndexing = proximityIndexing
            self.stopWords = stopWords
            self.minTermLength = minTermLengh
        }
        
        /// Returns a CFDictionary object to use for the call to SKIndexCreate
        internal func properties() -> CFDictionary {
            let properties: [CFString: Any] = [
                kSKProximityIndexing: self.proximityIndexing,
                kSKStopWords: self.stopWords,
                kSKMinTermLength: self.minTermLength,
            ]
            return properties as CFDictionary
        }
    }
    
    //private, can't make it private due to seperation of concerns, i.e. moving funcitons into differnet files.
    var index: SKIndex?
    
    /// Call  once at application launch to tell Search Kit to use the Spotlight metadata importers.
    lazy var dataExtractorLoaded: Bool = {
        SKLoadDefaultExtractorPlugIns()
        return true
    }()
    
    /// Stop words for the index
    private(set) lazy var stopWords: Set<String> = {
        var stopWords: Set<String> = []
        if let index = self.index,
           let properties = SKIndexGetAnalysisProperties(self.index),
           let sp = properties.takeRetainedValue() as? [String: Any] {
            stopWords = sp[kSKStopWords as String] as! Set<String>
        }
        return stopWords
    }()
    
    /// Close the index
    public func close() {
        if let index = self.index {
            SKIndexClose(index)
            self.index = nil
        }
    }
    
    internal init(index: SKIndex) {
        self.index = index
        super.init()
    }
    
    deinit {
        self.close()
    }
}

