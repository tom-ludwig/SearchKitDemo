//
//  SearchResultsFileTabItem.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 14.11.23.
//

import SwiftUI
import AppKit

struct SearchResultsFileTabItem: View {
    @State var file: SearchResultsViewModel
    @State private var isHovered = false
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "doc")
                
                Text(file.url.lastPathComponent)
                
                Spacer()
            }.frame(maxWidth: .infinity)
            List {
                ForEach(file.lineMatches, id: \.id) { line in
                    AttributedTextView(attributedString: line.attributedLabel())
                        .frame(minHeight: 100)
                }
            }.frame(minHeight: 100)
        }
    }
}


#Preview {
    SearchResultsFileTabItem(file: SearchResultsViewModel(url: URL(string: "file:///ContentView.swift")!, score: 3.1, lineMatches: [SearchResultLineMatchesModel(file: URL(string: "file:///ContentView.swift")!, lineNumber: 20, lineContent: "this is a test and it stays a test", keywordRange: String("Hello, World!").index(String("Hello, World!").startIndex, offsetBy: 7)..<String("Hello, World!").index(String("Hello, World!").startIndex, offsetBy: 11))]))
}


struct AttributedTextView: NSViewRepresentable {
    let attributedString: NSAttributedString

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.textStorage?.setAttributedString(attributedString)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.textStorage?.setAttributedString(attributedString)
    }
}
