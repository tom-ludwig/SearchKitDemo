//
//  ContentView.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 31.10.23.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: SearchKitDemoDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(SearchKitDemoDocument()))
}
