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
    @State private var searchTime: TimeInterval?
    @State private var searchQuery: String = ""
    var body: some View {
        NavigationView {
            SidebarView(files: $files)
            
            VStack {
                TextField("Query", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .frame(maxWidth: 200)
                HStack {
                    VStack {
                        Button("Index") {
                            let startTime = Date()
                            guard let indexer = indexer else {
                                return
                            }
                            
                            files.forEach { file in
//                                let result = indexer.add(fileURL: file.url, canReplace: false)
                                let result = indexer.add(file.url, text: file.content!, canReplace: false)
                                print(result)
                            }
                            
                            indexer.flush()
                            
                            print(indexer.documents())
                            
                            let endTime = Date()
                            elapsedTime = endTime.timeIntervalSince(startTime)
                        }
                        
                        
                        if let elapsedTime = elapsedTime {
                            Text("\(elapsedTime)")
                        }
                    }
                    
                    VStack {
                        Button("Search") {
                            let startTime = Date()
                            let results = indexer?.search(searchQuery)
                            guard let results = results else {
                                print("No results found")
                                return
                            }
                            for result in results {
                                print(result.url)
                            }
                            let endTime = Date()
                            searchTime = endTime.timeIntervalSince(startTime)
                        }
                        if let searchTime = searchTime {
                            Text("\(searchTime)")
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
                addFilesWithContentText()
            }
        }
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
                        if let file = try? FileViewModel(name: fileURL.lastPathComponent, url: fileURL) {
                            files.append(file)
                        } else {
                            print("Error happend on: \(fileURL)")
                        }
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
                            print("is a dir")
                            continue
                        }
//                        let fileContentData = try? Data(contentsOf: fileURL)
//                        let fileContentString = String(data: fileContentData!, encoding: .utf8)! // TODO: Remove force unwrapping
                        do {
                            guard let fileContent = try? String(contentsOf: fileURL) else {
                                continue
                            }
                            if let file = try? FileViewModel(name: fileURL.lastPathComponent, url: fileURL, content: fileContent) {
                                files.append(file)
                            } else {
                                print("an error occured")
                            }
                        } catch {
                            print("fatal error")
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
