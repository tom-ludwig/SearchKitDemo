//
//  SearchIndexer+AsyncManager.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 06.11.23.
//

import Foundation

extension SearchIndexer {
    /// Manager for SearchIndexer objct that supports async calls to the index
    class AsyncManager {
        public let index: SearchIndexer
        private let addQueue = DispatchQueue(label: "com.SearchkitDemo.addQueue", attributes: .concurrent)
        private let searchQueue = DispatchQueue(label: "com.SearchkitDemo.searchQueue", attributes: .concurrent)
        
        /// Queue for handling async modifications to the index
        //        fileprivate let modifyQueue = DispatchQueue(label: "com.SearchkitDemo.modifyQueue", attributes: .concurrent)
        init(index: SearchIndexer) {
            self.index = index
        }
        
        
        class TextTask {
            let url: URL
            let text: String
            
            /// Create a text async task
            ///
            /// - Parameters:
            ///   - url: the identifying document URL
            ///   - text: The text to add to the index
            init(url: URL, text: String) {
                self.url = url
                self.text = text
            }
        }
        
        // MARK: - Search
        func next(
            query: String,
            _ maxResults: Int,
            timeout: TimeInterval = 1.0,
            complete: @escaping (SearchIndexer.ProgressivSearch.Results) -> Void
        ) {
            let search = index.progressiveSearch(query: query)
            searchQueue.async {
                let results = search.next(maxResults, timeout: timeout)
                let searchResults = SearchIndexer.ProgressivSearch.Results(moreResultsAvailable: results.moreResultsAvailable, results: results.results)
                
                DispatchQueue.main.async {
                    complete(searchResults)
                }
            }
        }
        
        // MARK: - Add
        
        func addText(
            async textTask: [TextTask],
            flushWhenComplete: Bool = false,
            complete: @escaping ([TextTask]) -> Void
        ) {
            let dispatchGroup = DispatchGroup()
            
            for task in textTask {
                dispatchGroup.enter()
                addQueue.async { [weak self] in
                    guard let self = self else { return }
                    let _ = self.index.add(task.url, text: task.text)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if flushWhenComplete {
                    self.index.flush()
                }
                complete(textTask)
            }
        }
        
        func addFiles(
            urls: [URL],
            flushWhenComplete: Bool = false
        ) async -> [Bool] {
            var addedURLs = [Bool]()
            
            await withTaskGroup(of: Bool.self) { taskGroup in
                for url in urls {
                    taskGroup.addTask {
                        return self.index.add(fileURL: url, canReplace: false)
                    }
                }
                
                for await results in taskGroup {
                    addedURLs.append(results)
                }
            }
            
            return addedURLs
        }
        
        func addFolder(
            url: URL,
            flushWhenComplete: Bool = false
        ) {
            let dispatchGroup = DispatchGroup()
            
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles], errorHandler: nil)!
            
            for case let fileURL as URL in enumerator {
                dispatchGroup.enter()
                
                if FileHelper.urlIsFolder(url) {
                    addQueue.async { [weak self] in
                        guard let self = self else { return }
                        self.addFolder(url: url)
                        dispatchGroup.leave()
                    }
                } else {
                    addQueue.async { [weak self] in
                        guard let self = self else { return }
                        let _ = self.index.add(fileURL: fileURL, canReplace: false)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if flushWhenComplete {
                    self.index.flush()
                }
            }
        }
    }
}

class FileHelper {
    static func urlIsFolder(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    static func urlIsFile(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }
}

