//
//  SearchIndexer+Add.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

extension SearchIndexer {
    /// Add some text to the index
    ///
    /// - Parameters:
    ///   - url: The identifying URL for the text
    ///   - text: The text to add
    ///   - canReplace: if true, can attempt to replace an existing document with the new one.
    /// - Returns: true if the text was successfully added to the index, false otherwise
    @objc public func Add(_ url: URL, text: String, canReplace: Bool = true) -> Bool {
        guard let index = self.index,
              let document = SKDocumentCreateWithURL(url as CFURL) else {
            return false
        }
        
        return synchronised(self) {
            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
        }
    }
}
