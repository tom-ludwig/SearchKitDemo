//
//  SidebarView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 07.11.23.
//

import SwiftUI

struct SidebarView: View {
    @Binding var files: [FileViewModel]
    var body: some View {
        if !files.isEmpty {
            List(files) { file in
                HStack {
                    Image(systemName: "doc")
                    
                    Text(file.name)
                }
            }
        } else {
            Text("Please add a file or folder")
        }
    }
}

#Preview {
    SidebarView(files: .constant([FileViewModel]()))
}
