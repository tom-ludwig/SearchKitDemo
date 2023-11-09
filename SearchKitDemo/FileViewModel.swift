//
//  SearchManger.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 31.10.23.
//

import Foundation

struct FileViewModel: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let content: String?
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
        self.content = nil
    }
    
    init(name: String, url: URL, content: String) {
        self.name = name
        self.url = url
        self.content = content
    }
}
