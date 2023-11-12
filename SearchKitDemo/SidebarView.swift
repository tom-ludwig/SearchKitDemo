//
//  SidebarView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 07.11.23.
//

import SwiftUI

struct SidebarView: View {
    @Binding var files: [FileViewModel]
    var removeAction: (URL) -> (Bool)
    var body: some View {
        if !files.isEmpty {
            List(files) { file in
                FileTabItemView(file: file, removeAction: removeAction)
            }
        } else {
            Text("Please add a file or folder")
        }
    }
}

#Preview {
    SidebarView(files: .constant([FileViewModel]()), removeAction: { _ in return true })
}


struct FileTabItemView: View {
    @State var file: FileViewModel
    @State private var isHovered = false
    var removeAction: (URL) -> (Bool)
    var body: some View {
        HStack {
            Image(systemName: "doc")
            
            Text(file.name)
            
            Spacer()
            
            if isHovered {
                Button {
                    let result = removeAction(file.url)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .onHover { hovering in
            withAnimation {
                self.isHovered = hovering
            }
        }
    }
}
