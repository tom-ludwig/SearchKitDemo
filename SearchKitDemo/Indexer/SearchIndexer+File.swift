//
//  SearchIndexer+File.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 04.11.23.
//

import Foundation

extension SearchIndexer {
    /// A file based index
    @objc(SearchIndexerFile)
    public class File: SearchIndexer {
        /// The file url where the index is located
        @objc
        public let fileURL: URL
        
        private init(url: URL, index: SKIndex) {
            self.fileURL = url
            super.init(index: index)
        }
        
        /// Create a new file based index
        /// - Parameter fileURL: The file URL to create the index at
        /// - Parameter properties: The properties defining the capabilities of the index
        @objc
        public convenience init?(fileURL: URL, properties: CreateProperties) {
            if !FileManager.default.fileExists(atPath: fileURL.absoluteString),
               let skIndex = SKIndexCreateWithURL(fileURL as CFURL, nil, properties.indexType, properties.properties()) {
                self.init(url: fileURL, index: skIndex.takeUnretainedValue())
            } else {
                return nil
            }
        }
        
        /// Load an index from a file url
        /// - Parameter fileURL: The file URL to load the index from
        /// - Parameter writable: Can we modify the index?
        @objc
        public convenience init?(fileURL: URL, writeable: Bool) {
            // TODO: Maybe add file existence check?
            if let skIndex = SKIndexOpenWithURL(fileURL as CFURL, nil, writeable) {
                self.init(url: fileURL, index: skIndex.takeUnretainedValue())
            } else {
                return nil
            }
        }
        
        /// Open an index from a file url.
        ///
        /// - Parameters:
        ///   - fileURL: The file url to open
        ///   - writable: should the index be modifiable?
        /// - Returns: A new index object if successful, nil otherwise
        @objc
        public static func Open(fileURL: URL, writeable: Bool) -> SearchIndexer.File? {
            if let temp = SKIndexOpenWithURL(fileURL as CFURL, nil, writeable) {
                return SearchIndexer.File(url: fileURL, index: temp.takeUnretainedValue())
            }
            return nil
        }
        
        
        /// Create an indexer using a new data container for the store
        ///
        /// - Parameter fileURL: the file URL to store the index at.  url must be a non-existent file
        /// - Parameter properties: the properties for index creation
        /// - Returns: A new index object if successful, nil otherwise. Returns nil if the file already exists at url
        @objc
        public static func Create(fileURL: URL, properties: CreateProperties = CreateProperties()) -> SearchIndexer.File? {
            if !FileManager.default.fileExists(atPath: fileURL.absoluteString),
               let skIndex = SKIndexCreateWithURL(fileURL as CFURL,
                                                  nil,
                                                  properties.indexType,
                                                  properties.properties()
               ) {
                return SearchIndexer.File(url: fileURL, index: skIndex.takeUnretainedValue())
            } else {
                return nil
            }
        }
        
        /// Flush, compact and write the content of the index to the file
        @objc
        public func save() {
            flush()
            compact()
        }
    }
}
