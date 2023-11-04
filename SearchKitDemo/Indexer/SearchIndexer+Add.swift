//
//  SearchIndexer+Add.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

extension SearchIndexer {
    
    //TODO: Check differences
    /// Add some text to the index
    ///
    /// - Parameters:
    ///   - url: The identifying URL for the text
    ///   - text: The text to add
    ///   - canReplace: if true, can attempt to replace an existing document with the new one.
    /// - Returns: true if the text was successfully added to the index, false otherwise
    @objc public func add(_ url: URL, text: String, canReplace: Bool = true) -> Bool {
        guard let index = self.index,
              let document = SKDocumentCreateWithURL(url as CFURL) else {
            return false
        }
        
//        return synchronised(self) {
//            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
//        }
//        return Synchronised.withLock {
//            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
//        }
        return queue.sync {
            SKIndexAddDocumentWithText(index, document.takeUnretainedValue(), text as CFString, canReplace)
        }
    }
    
    /// Add some text to the index
    ///
    /// - Parameters:
    ///   - textURL: The identifying URL for the text (must be a valid URL)
    ///   - text: The text to add
    ///   - canReplace: if true, can attempt to replace an existing document with the new one.
    /// - Returns: true if the text was successfully added to the index, false otherwise
    @objc
    public func add(textURL: String, text: String, canReplace: Bool = true) -> Bool {
        guard let url = URL(string: textURL) else {
            return false
        }
        return self.add(url, text: text, canReplace: canReplace)
    }
    
    /// Add a file as a document to the index
    ///
    /// - Parameters:
    ///   - fileURL: The file URL for the document (of the form file:///Users/blahblah.txt)
    ///   - mimeType: An optional mimetype.  If nil, attempts to work out the type of file from the extension.
    ///   - canReplace: if true, can attempt to replace an existing document with the new one.
    /// - Returns: true if the command was successful.
    ///                 **NOTE** If the document _wasnt_ updated it also returns true!
    @objc
    public func add(fileURL: URL, mimeType: String? = nil, canReplace: Bool = true) -> Bool {
        guard self.dataExtractorLoaded,
              let index = self.index,
              let document = SKDocumentCreateWithURL(fileURL as CFURL) else {
                return false
              }
        // Try to detect the mime type if it wasn't specified
        let mime = mimeType ?? self.detectMimeType(fileURL)
        
        return queue.sync {
            SKIndexAddDocument(index, document.takeUnretainedValue(), mime as CFString?, canReplace)
        }
    }
    
    /// Recursively add the files contained within a folder to the search index
    ///
    /// - Parameters:
    ///   - folderURL: The folder to be indexed.
    ///   - canReplace: If the document already exists within the index, can it be replaced?
    /// - Returns: The URLs of documents added to the index.  If folderURL isn't a folder, returns empty
    @objc
    public func addFolderContent(folderURL: URL, canReplace: Bool = true) -> [URL] {
        let fileManger = FileManager.default
        
        var isDir: ObjCBool = false
        guard fileManger.fileExists(atPath: folderURL.path, isDirectory: &isDir),
              isDir.boolValue == true else {
            return []
        }
        
        var addedUrls: [URL] = []
        let enumerator = fileManger.enumerator(at: folderURL, includingPropertiesForKeys: nil)
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileManger.fileExists(atPath: fileURL.path, isDirectory: &isDir),
               isDir.boolValue == false,
               self.add(fileURL: fileURL, canReplace: canReplace) {
                addedUrls.append(fileURL)
            }
        }
        
        return addedUrls
    }
    
    /// Remove a document from the index
    ///
    /// - Parameter url: The identifying URL for the document
    /// - Returns: true if the document was successfully removed, false otherwise.
    ///            **NOTE** if the document didn't exist, this returns true as well
    @objc
    public func remove(url: URL) -> Bool {
        let document = SKDocumentCreateWithURL(url as CFURL).takeUnretainedValue()
        return self.remove(document: document)
    }
    
    /// Remove an array of documents from the index
    ///
    /// - Parameter urls: An array of URLs identifying the documents to remove
    @objc
    public func remove(urls: [URL]) {
        urls.forEach { url in
            _ = self.remove(url: url)
        }
    }
    
    /// Returns the indexing state for the specified URL.
    @objc
    public func documentState(_ url: URL) -> SKDocumentIndexState {
        if let index = self.index,
           let document = SKDocumentCreateWithURL(url as CFURL) {
            return SKIndexGetDocumentState(index, document.takeUnretainedValue())
        }
        return kSKDocumentStateNotIndexed
    }
    
    /// Returns true if the document that corresponds to the specified URL is in the index.
    @objc
    public func documentIndexed(_ url: URL) -> Bool {
        return self.documentState(url) == kSKDocumentStateIndexed
    }
}
