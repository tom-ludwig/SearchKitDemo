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
    var body: some View {
        VStack {
            HStack {
                Button("Search") {
                    
//                    tempDoc = FileUtils.TempFile()
//                    guard let tempDoc = tempDoc else { return }
//                    guard let indexer = SearchIndex.File(fileURL: tempDoc.fileURL, properties: SearchIndex.CreateProperties()) else {
//                        return
//                    }
//                    
//                    let document1 = FileUtils.url("doc-url://document1.txt")
//                    let _ = indexer.add(document1, text: "struct ContentView: View {")
//                    
//                    let document2 = FileUtils.url("doc-url://document2.txt")
//                    let _ = indexer.add(document2, text: "Good morning, World!")
//                    
//                    indexer.flush()
//                    
//                    let results = indexer.search("Cont")
//                    print(results)
//                    displayedResults = results
                }
            }
        }
    }

//    func loadFileNames() -> [SearchIndex.SearchResult]? {
//        var selectedURL: URL?
//        let openPannel = NSOpenPanel()
//        openPannel.allowsMultipleSelection = false
//        openPannel.canChooseFiles = false
//        openPannel.canChooseDirectories = true
//        openPannel.canCreateDirectories = false
//        openPannel.prompt = "Index"
//        // get url
//        if openPannel.runModal() == .OK {
//            if let url = openPannel.urls.first {
//                selectedURL = url
//            }
//        }
//        guard let selectedURL = selectedURL else { return [] }
//        
//        let fileManger = FileManager.default
//        //let contents = try fileManger.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
//        let enumerator = fileManger.enumerator(
//            at: selectedURL,
//            includingPropertiesForKeys: [
//                .isRegularFileKey,
//            ],
//            options: [
//                .skipsHiddenFiles,
//                .skipsPackageDescendants,
//            ]
//        )
//        guard let filePaths = enumerator?.allObjects as? [URL] else { return [] }
//        
//        tempDoc = FileUtils.TempFile()
//        guard let tempDoc = tempDoc else { return [] }
//        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
//            let indexURL = cacheDirectory.appendingPathComponent("\(UUID().uuidString).plist")
//            indexer = SearchIndex.File(fileURL: indexURL, properties: SearchIndex.CreateProperties())
//        }
//        
//        let fileURLs = indexer?.addFolderContent(folderURL: selectedURL, canReplace: false)
//        
////        for filePath in filePaths {
////            // convert url to data and then the data to string
////            if let data = try? Data(contentsOf: filePath) {
////                if let content = String(data: data, encoding: .utf8) {
////                    let resultOfAdding = indexer?.add(filePath, text: content)
////                    print(resultOfAdding)
////                } else {
////                    print("Error while getting string:")
////                    continue
////                }
////            } else {
////                print("Data error")
////                continue
////            }
////        }
//        indexer?.flush()
////        print(i)
//        let result = indexer?.search("View")
//        
//        return result
//    }
}

#Preview {
    ContentView()
}
