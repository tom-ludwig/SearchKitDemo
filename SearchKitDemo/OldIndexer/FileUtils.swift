//
//  FileUtils.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

class FileUtils {
    class TempFile {
        let fileURL: URL = {
            let directory = NSTemporaryDirectory()
            let fileName = UUID().uuidString
            
            return NSURL.fileURL(withPathComponents: [directory, fileName])! as URL
        }()
        
        deinit {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    static func url(_ val: String) -> URL {
        return URL(string: val)!
    }
}
