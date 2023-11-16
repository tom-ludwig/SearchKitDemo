//
//  ContentView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 31.10.23.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var searchManager: SearchManager = SearchManager()
    @State private var searchQuery: String = ""
    @State private var asyncIndexing: Bool = false
    var body: some View {
        NavigationView {
            SidebarView(files: $searchManager.files, searchResults: $searchManager.searchResults, removeAction: searchManager.delete)
            
            if !searchManager.searchResults.isEmpty {
                VStack {
                    Text("Files Found: \(searchManager.searchResults.count).")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                        )
                    
                    Table(searchManager.searchResults) {
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
                searchManager.addFilesWithContentText()
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            
            Button {
                if asyncIndexing {
                    searchManager.asyncIndex()
                } else {
                    searchManager.index()
                }
            } label: {
                Image(systemName: "square.grid.3x3.square")
            }
            
            TextField("Query...", text: $searchQuery)
                .frame(minWidth: 100)
                .onSubmit {
                    searchManager.search(searchQuery: searchQuery)
                }
            
            Button {
                searchManager.search(searchQuery: searchQuery)
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}


#Preview {
    ContentView()
}
