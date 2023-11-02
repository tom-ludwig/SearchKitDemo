//
//  SearchIndex+Memory.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

extension SearchIndex {
    /// A memory-based index using NSMutableData as the backing.
    @objc(DFSearchIndexMemory) public class Memory: SearchIndex {
        // The data index store
        private var store = NSMutableData()

        /// Create a new in-memory index
        /// - Parameter properties: The properties to use in the index
        @objc public init?(properties: CreateProperties = CreateProperties()) {
            let data = NSMutableData()
            if let skIndex = SKIndexCreateWithMutableData(
                data, nil,
                properties.indexType,
                properties.properties()
            ) {
                super.init(index: skIndex.takeUnretainedValue())
                self.store = data
            }
            else {
                return nil
            }
        }

        /// Create an in-memory index from the data provided
        /// - Parameter data: The data to load the index data from
        @objc public convenience init?(data: Data) {
            if let rawData = (data as NSData).mutableCopy() as? NSMutableData,
                let skIndex = SKIndexOpenWithMutableData(rawData, nil) {
                self.init(data: rawData, index: skIndex.takeUnretainedValue())
            }
            else {
                return nil
            }
        }

        /// Create an indexer using a new data container for the store
        ///
        /// - Parameter properties: the properties for index creation
        /// - Returns: A new index object if successful, nil otherwise
        @objc public static func Create(properties: CreateProperties = CreateProperties()) -> SearchIndex.Memory? {
            let data = NSMutableData()
            if let skIndex = SKIndexCreateWithMutableData(
                data, nil,
                properties.indexType,
                properties.properties()
            ) {
                return SearchIndex.Memory(data: data, index: skIndex.takeUnretainedValue())
            }
            return nil
        }

        /// Create an indexer using the data stored in 'data'.
        ///
        /// **NOTE** Makes a copy of the data first - does not work on a live Data object
        ///
        /// - Parameter data: The data to load as an index
        /// - Returns: A new index object if successful, nil otherwise
        @objc public static func Load(from data: Data) -> SearchIndex.Memory? {
            if let rawData = (data as NSData).mutableCopy() as? NSMutableData,
                let skIndex = SKIndexOpenWithMutableData(rawData, nil) {
                return SearchIndex.Memory(data: rawData, index: skIndex.takeUnretainedValue())
            }
            return nil
        }

        /// Returns the index content as a (copied) Swift Data object
        @objc public func data() -> Data? {
            flush()
            return self.store.copy() as? Data
        }

        private init(data: NSMutableData, index: SKIndex) {
            super.init(index: index)
            self.store = data
        }

    }
}
