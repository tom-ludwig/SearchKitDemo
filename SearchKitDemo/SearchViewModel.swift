//
//  SearchViewModel.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 16.11.23.
//

import Foundation
import AppKit

class SearchManager: ObservableObject {
    @Published var files = [FileViewModel]()
    @Published var searchResults = [SearchResultsViewModel]()
    var indexer: SearchIndexer?
    
    init() {
        // configure Indexer here
        self.indexer = SearchIndexer.Memory.Create()
    }
    
    func addFilesWithContentText() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let selectedFolderURL = openPanel.url {
                let fileManager = FileManager.default
                
                if let enumerator = fileManager.enumerator(at: selectedFolderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil) {
                    for case let fileURL as URL in enumerator {
                        var isDirec: ObjCBool = false
                        fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirec)
                        
                        guard isDirec.boolValue == false else {
                            continue
                        }
                        guard let fileContent = try? String(contentsOf: fileURL) else {
                            continue
                        }
                        
                        files.append(FileViewModel(name: fileURL.lastPathComponent, url: fileURL, content: fileContent))
                    }
                }
            }
        }
        
        print("Added Files")
        
    }
    
    private func asyncIndex() {
        let startTime = Date()
        guard let indexer = indexer else {
            return
        }
        
        let asyncController = SearchIndexer.AsyncManager(index: indexer)
        
        Task{
            var textFiles = [SearchIndexer.AsyncManager.TextFile]()
            for file in files {
                textFiles.append(SearchIndexer.AsyncManager.TextFile(url: file.url, text: file.content ?? ""))
            }
            
            let _ = await asyncController.addText(files: textFiles, flushWhenComplete: false)
            
            indexer.flush()
            
            print("Added: \(indexer.documents().count) documents to the index.")
            print("Elapsed time: \(Date().timeIntervalSince(startTime))")
        }
    }
    
    private func index() {
        let startTime = Date()
        guard let indexer = indexer else {
            return
        }
        
        files.forEach { file in
            _ = indexer.add(file.url, text: file.content!, canReplace: false)
        }
        
        indexer.flush()
        
        print(indexer.documents().count)
        print(Date().timeIntervalSince(startTime))
    }
    
    func delete(url: URL) -> Bool {
        guard let indexer = indexer else {
            return false
        }
        let success = indexer.remove(url: url)
        
        if success {
            files.removeAll {
                $0.url == url
            }
        }
        
        return success
    }
    
    private func search(searchQuery: String) {
        guard let indexer = indexer else {
            return
        }
        
        var newSearchResults = [SearchResultsViewModel]()
        let startTime = Date()
        let results = indexer.search(searchQuery)
        print(results.count)
        for result in results {
            let newResult = SearchResultsViewModel(url: result.url, score: result.score, lineMatches: [SearchResultLineMatchesModel]())
            newSearchResults.append(newResult)
        }
        evaluateResults(query: searchQuery, searchResults: &newSearchResults)
        
        searchResults = searchResults.sorted {
            $0.score > $1.score
        }
        searchResults = newSearchResults
        print(Date().timeIntervalSince(startTime))
    }
    
    
    private func evaluateResults(query: String, searchResults: inout [SearchResultsViewModel]) {
        
        searchResults = searchResults.map { result in
            var newResult = result
            var newMatches = [SearchResultLineMatchesModel]()
            guard let data = try? Data(contentsOf: result.url), let string = String(data: data, encoding: .utf8) else {
                return newResult
            }
            
            for (lineNumber, line) in string.split(separator: "\n").lazy.enumerated() {
                let rawNoSapceLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                let noSpaceLine = rawNoSapceLine.lowercased()
                
                if lineContainsSearchTerm(line: noSpaceLine, query: query) {
                    let matches = noSpaceLine.ranges(of: query).map { range in
                        return [lineNumber, noSpaceLine, range]
                    }
                    for match in matches {
                        newMatches.append(SearchResultLineMatchesModel(file: result.url, lineNumber: match[0] as! Int, lineContent: match[1] as! String, keywordRange: match[2] as! Range<String.Index>))
                    }
                    //                    result.lineMatches.append(contentsOf: newMatches)
                }
            }
            newMatches.forEach { match in
                newResult.lineMatches.append(match)
            }
            return newResult
        }
    }
    
    func lineContainsSearchTerm(line: String, query: String) -> Bool {
        var line = line
        if line.hasPrefix(" ") { line.removeFirst() }
        if line.hasSuffix(" ") { line.removeLast() }
        
        let textContainsSearchTerm = line.contains(query)
        guard textContainsSearchTerm else { return false }
        
        let appearances = line.appearancesOfSubstring(substring: query, toLeft: 1, toRight: 1)
        var foundMatch = false
        for appearance in appearances {
            let appearanceString = String(line[appearance])
            guard appearanceString.count >= 2 else { continue }
            
            var startsWith = false
            var endsWith = false
            if appearanceString.hasPrefix(query) ||
                !appearanceString.first!.isLetter ||
                !appearanceString.character(at: 2).isLetter {
                startsWith = true
            }
            if appearanceString.hasSuffix(query) ||
                !appearanceString.last!.isLetter ||
                !appearanceString.character(at: appearanceString.count-2).isLetter {
                endsWith = true
            }
            
            // only matching for now
            return startsWith && endsWith ? true : false
            
            //            switch textMatching {
            //            case .MatchingWord:
            //                foundMatch = startsWith && endsWith ? true : foundMatch
            //            case .StartingWith:
            //                foundMatch = startsWith ? true : foundMatch
            //            case .EndingWith:
            //                foundMatch = endsWith ? true : foundMatch
            //            default: continue
            //            }
        }
        
        return false
    }
}
