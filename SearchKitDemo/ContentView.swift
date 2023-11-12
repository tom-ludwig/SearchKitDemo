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
    @State var searchResults: [SearchResultsViewModel]? = nil
    @State var indexer = SearchIndexer.Memory.Create()
    @State private var elapsedTime: TimeInterval?
    @State private var searchTime: TimeInterval?
    @State private var searchQuery: String = ""
    @State private var asyncIndexing: Bool = false
    var body: some View {
        NavigationView {
            SidebarView(files: $files, removeAction: delete)
            
            if let searchResults {
                VStack {
                    Text("Files Found: \(searchResults.count) within \(searchTime?.description ?? "0") seconds")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                        )
                    
                    Table(searchResults) {
                        TableColumn("Name") {
                           Text($0.fileName)
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
    
    private func search() {
        searchResults = [SearchResultsViewModel]()
        let startTime = Date()
        let results = indexer?.search(searchQuery)
        guard let results = results else {
            print("No results found")
            return
        }
        for result in results {
            let newResult = SearchResultsViewModel(fileName: result.url.lastPathComponent, url: result.url, score: result.score)
            searchResults?.append(newResult)
        }
        searchResults = searchResults?.sorted {
            $0.score > $1.score
        }
        let endTime = Date()
        searchTime = endTime.timeIntervalSince(startTime)
        print(searchTime as Any)
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
