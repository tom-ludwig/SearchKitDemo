//
//  ContentView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 31.10.23.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State var tempDoc: FileUtils.TempFile?
    @State var files = [FileViewModel]()
    @State var indexer = SearchIndexer.Memory.Create()
    @State private var elapsedTime: TimeInterval?
    
    var body: some View {
        NavigationView {
            SidebarView(files: $files)
            
            VStack {
                HStack {
                    VStack {
                        Button("Index") {
                             let startTime = Date()
                            guard let indexer = indexer else {
                                return
                            }
                            
                            files.forEach { file in
                                let result = indexer.add(fileURL: file.url, canReplace: false)
                                print(result)
                            }
                            
                            indexer.flush()
                            
                            print(indexer.search("cruising", limit: 10))
                            
                            let endTime = Date()
                            elapsedTime = endTime.timeIntervalSince(startTime)
                        }
                        
                        
                        if let elapsedTime = elapsedTime {
                            Text("\(elapsedTime)")
                        }
                    }
                    
                    Button("Search") {
                        let results = indexer?.search("cruising")
                        guard let results = results else {
                            return
                        }
                        for result in results {
                            print(result.url)
                        }
                    }
                }
                
                HStack {
                    Button("Remove") {
                        
                    }
                    
                    Button("Memory") {
                        
                    }
                }
            }.buttonStyle(.accessoryBarAction)
            
        }.toolbar {
            Button("Open") {
                let openPanel = NSOpenPanel()
                openPanel.canChooseFiles = false
                openPanel.canChooseDirectories = true
                openPanel.allowsMultipleSelection = false
                
                if openPanel.runModal() == .OK {
                    if let selectedFolderURL = openPanel.url {
                        let fileManager = FileManager.default
                        
                        if let enumerator = fileManager.enumerator(at: selectedFolderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: nil) {
                            for case let fileURL as URL in enumerator {
                                do {
                                    if let file = try? FileViewModel(name: fileURL.lastPathComponent, url: fileURL) {
                                        files.append(file)
                                    }
                                } catch {
                                    print("File could not be added.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
