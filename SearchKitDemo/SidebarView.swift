//
//  SidebarView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 07.11.23.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedView: SideBarSelectedView = .files
    @Binding var files: [FileViewModel]
    @Binding var searchResults: [SearchResultsViewModel]
    var removeAction: (URL) -> (Bool)
    
    
    enum SideBarSelectedView {
        case files
        case searchResults
    }
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        selectedView = .files
                    }
                } label: {
                    Image(systemName: "doc")
                        .foregroundStyle(selectedView == .files ? .blue : .gray)
                }
                
                Button {
                    withAnimation {
                        selectedView = .searchResults
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                } .foregroundStyle(selectedView == .searchResults ? .blue : .gray)
            }.buttonStyle(.accessoryBar)
            
            if selectedView == .files {
                if !files.isEmpty {
                    List(files) { file in
                        FileTabItemView(file: file, removeAction: removeAction)
                    }
                } else {
                    Text("Please add a file or folder")
                }
            } else {
                List(searchResults) { results in
                    SearchResultsFileTabItem(file: results)
                }
            }
        }
    }
}

//#Preview {
//    SidebarView(files: .constant([FileViewModel]()), searchResults: .constant([SearchResultsViewModel]), removeAction: { _ in return true })
//}
