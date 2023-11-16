//
//  FileTabItemView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 14.11.23.
//

import SwiftUI

struct FileTabItemView: View {
    @State var file: FileViewModel
    @State private var isHovered = false
    var removeAction: (URL) -> (Bool)
    var body: some View {
        HStack {
            Image(systemName: "doc")
            
            Text(file.url.lastPathComponent)
            
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


#Preview {
    FileTabItemView(file: FileViewModel(name: "test", url: URL(string: "file:///test.doc")!)) { _ in
        return true
    }
}
