//
//  SearchIndexer+PrivateMethods.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 03.11.23.
//

import Foundation
import UniformTypeIdentifiers

extension SearchIndexer {
    typealias DocumentID = (URL, SKDocument, SKDocumentID)
    
    /// Returns the mime type for the url, or nil if the mime type couldn't be ascertained from the extension
    ///
    /// - Parameter url: the url to detect the mime type for
    /// - Returns: the mime type of the url if able to detect, nil otherwise
     func detectMimeType(_ url: URL) -> String? {
        if let type = UTType(filenameExtension: url.pathExtension) {
            if let mimetype = type.preferredMIMEType {
                return mimetype
            }
        }
        return nil
    }
    
    /// Remove the given document from the index
    /// When the app deletes a document, use this function to update the index to reflect the change, i. e. the index does not need to get flushed.
     func remove(document: SKDocument) -> Bool {
        if let index = self.index {
            return queue.sync {
                SKIndexRemoveDocument(index, document)
            }
        }
        return false
    }
    
    /// Returns the number of terms of the specified document
    private func termCount(for document: SKDocumentID) -> Int {
        guard self.index != nil else {
            return 0
        }
        return SKIndexGetDocumentTermCount(self.index!, document)
    }
    
    /// Is the specified document empty (ie. it has no terms)
    private func isEmpty(for document: SKDocumentID) -> Bool {
        guard self.index != nil else {
            return true // true would be the default value, i.e. document is Empty
        }
        return self.termCount(for: document) == 0
    }
    
    /// Recurse through the children of a document and return an array containing all the document-ids
    private func addLeafURLs(index: SKIndex, inParentDocument: SKDocument?, docs: inout [DocumentID]) {
        guard let index = self.index else {
            return
        }
        
        var isLeaf = true
        
        let iterator = SKIndexDocumentIteratorCreate(index, inParentDocument).takeUnretainedValue()
        while let skDocument = SKIndexDocumentIteratorCopyNext(iterator) {
            isLeaf = false
            self.addLeafURLs(index: index, inParentDocument: skDocument.takeUnretainedValue(), docs: &docs)
        }
        
        if isLeaf, inParentDocument != nil, kSKDocumentStateNotIndexed != SKIndexGetDocumentState(index, inParentDocument) {
            if let temp = SKDocumentCopyURL(inParentDocument) {
                let baseURL = temp.takeUnretainedValue()
                let documentID = SKIndexGetDocumentID(index, inParentDocument)
                docs.append((baseURL as URL, inParentDocument!, documentID))
            }
        }
    }
    
    /// Return an array of all the documents contained within the index
    ///
    /// - Parameter termState: the termstate of documents to be returned (eg. all, empty only, non-empty only)
    /// - Returns: An array containing all the documents matching the termstate
     func fullDocuments(termState: TermState = .All) -> [DocumentID] {
        guard let index = self.index else {
            return []
        }
        
        var allDocs = [DocumentID]()
        
        self.addLeafURLs(index: index, inParentDocument: nil, docs: &allDocs)
        
        switch termState {
        case .Empty:
            // $0.2 corresponds to the typealias DocumentID = (URL, SKDocument, SKDocumentID)
            allDocs = allDocs.filter { self.isEmpty(for: $0.2 )}
        case .NotEmpty:
            allDocs = allDocs.filter { !self.isEmpty(for: $0.2 )}
        default:
            break
        }
        
        return allDocs
    }
}
