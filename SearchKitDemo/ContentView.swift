//
//  ContentView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 31.10.23.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State var files = [FileViewModel]()
    @State var searchResults = [SearchResultsViewModel]()
    @State var indexer = SearchIndexer.Memory.Create()
    @State private var elapsedTime: TimeInterval?
    @State private var searchTime: TimeInterval?
    @State private var searchQuery: String = ""
    @State private var asyncIndexing: Bool = false
    var body: some View {
        NavigationView {
            SidebarView(files: $files, searchResults: $searchResults, removeAction: delete)
            
            if !searchResults.isEmpty {
                VStack {
                    Text("Files Found: \(searchResults.count) within \(searchTime?.description ?? "0") seconds")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                        )
                    
                    Table(searchResults) {
                        TableColumn("Name") {
                            Text($0.url.lastPathComponent)
                        }
                        
                        TableColumn("Score") {
                            Text("\($0.score, specifier: "%.2f")")
                        }
                    }
                }
            } else {
                Text("Results will appear here")
            }
        }.toolbar {
            Toggle(isOn: $asyncIndexing) {
                Image(systemName: "arrow.triangle.pull")
            }
            
            Button {
                addFilesWithContentText()
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            
            Button {
                if asyncIndexing {
                    asyncIndex()
                } else {
                    index()
                }
            } label: {
                Image(systemName: "square.grid.3x3.square")
            }
            
            TextField("Query...", text: $searchQuery)
                .frame(minWidth: 100)
                .onSubmit {
                    search()
                }
            
            Button {
                search()
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
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
    
    private func asyncSearch() {
        searchResults = [SearchResultsViewModel]()
        let startTime = Date()
        
        guard let index = indexer else {
            return
        }
        let asyncController = SearchIndexer.AsyncManager(index: index)
        asyncController.next(query: searchQuery, 10, timeout: 1.0) { results in
            print(results)
        }
        
        let endTime = Date()
        searchTime = endTime.timeIntervalSince(startTime)
        print(searchTime as Any)
    }
    
    private func search() {
        var newSearchResults = [SearchResultsViewModel]()
        let startTime = Date()
        let results = indexer?.search(searchQuery)
        guard let results = results else {
            print("No results found")
            return
        }
        print(results.count)
        for result in results {
            let newResult = SearchResultsViewModel(url: result.url, score: result.score, lineMatches: [SearchResultLineMatchesModel]())
            newSearchResults.append(newResult)
        }
        evaluateResults(query: searchQuery, searchResults: &newSearchResults)
        
        //        searchResults = searchResults?.sorted {
        //            $0.score > $1.score
        //        }
        searchResults = newSearchResults
        let endTime = Date()
        searchTime = endTime.timeIntervalSince(startTime)
        print(searchTime as Any)
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
                
                if lineContainsSearchTerm(line: noSpaceLine, term: query) {
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
    
    func lineContainsSearchTerm(line: String, term: String) -> Bool {
        var line = line
        if line.hasPrefix(" ") { line.removeFirst() }
        if line.hasSuffix(" ") { line.removeLast() }
        
        let textContainsSearchTerm = line.contains(searchQuery)
        guard textContainsSearchTerm else { return false }
        
        let appearances = line.appearancesOfSubstring(substring: term, toLeft: 1, toRight: 1)
        var foundMatch = false
        for appearance in appearances {
            let appearanceString = String(line[appearance])
            guard appearanceString.count >= 2 else { continue }
            
            var startsWith = false
            var endsWith = false
            if appearanceString.hasPrefix(term) ||
                !appearanceString.first!.isLetter ||
                !appearanceString.character(at: 2).isLetter {
                startsWith = true
            }
            if appearanceString.hasSuffix(term) ||
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
            
            let endTime = Date()
            elapsedTime = endTime.timeIntervalSince(startTime)
            print("Elapsed time: \(elapsedTime ?? 0.0)")
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
        
        print(indexer.documents())
        
        let endTime = Date()
        elapsedTime = endTime.timeIntervalSince(startTime)
    }
    
    func addFilesWithURL() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let selectedFolderURL = openPanel.url {
                let fileManager = FileManager.default
                
                if let enumerator = fileManager.enumerator(at: selectedFolderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil) {
                    for case let fileURL as URL in enumerator {
                        files.append(FileViewModel(name: fileURL.lastPathComponent, url: fileURL))
                    }
                }
            }
        }
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
}


#Preview {
    ContentView()
}


extension String {
    func character(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    func appearancesOfSubstring(substring: String, toLeft: Int=0, toRight: Int=0) -> [Range<String.Index>] {
        guard !substring.isEmpty && self.contains(substring) else { return [] }
        var appearances: [Range<String.Index>] = []
        for (index, character) in self.enumerated() where character == substring.first {
            let startOfFoundCharacter = self.index(self.startIndex, offsetBy: index)
            guard index + substring.count < self.count else { continue }
            let lengthOfFoundCharacter = self.index(self.startIndex, offsetBy: (substring.count + index))
            if self[startOfFoundCharacter..<lengthOfFoundCharacter] == substring {
                let startIndex = self.index(
                    self.startIndex,
                    offsetBy: index - (toLeft <= index ? toLeft : 0)
                )
                let endIndex = self.index(
                    self.startIndex,
                    offsetBy: substring.count + index + (substring.count+index+toRight <= self.count ? toRight : 0)
                )
                appearances.append(startIndex..<endIndex)
            }
        }
        return appearances
    }
}
