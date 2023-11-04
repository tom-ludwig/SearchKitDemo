//
//  FileHelper.swift
//  SearchKitDemoTests
//
//  Created by Tommy Ludwig on 04.11.23.
//

import Foundation

class FileHelper {
    class TemporaryFile {
        let url: URL = {
            let folder = NSTemporaryDirectory()
            let name = UUID().uuidString
            
            return NSURL.fileURL(withPathComponents: [folder, name])! as URL
        }()
        
        deinit {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    static func url(_ value: String) -> URL {
        return URL(string: value)!
    }
}
