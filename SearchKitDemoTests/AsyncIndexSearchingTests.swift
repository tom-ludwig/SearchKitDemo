//
//  AsyncIndexSearchingTests.swift
//  SearchKitDemoTests
//
//  Created by Tommy Ludwig on 06.11.23.
//

@testable import SearchKitDemo
import XCTest

final class AsyncIndexSearchingTests: XCTestCase {
    fileprivate func bundleResourceURL(forResource name: String, withExtension ext: String) -> URL {
        let thisSourceFile = URL(fileURLWithPath: #file)
        var thisDirectory = thisSourceFile.deletingLastPathComponent()
        thisDirectory = thisDirectory.appendingPathComponent("Resources")
        thisDirectory = thisDirectory.appendingPathComponent(name + "." + ext)
        return thisDirectory
    }
    fileprivate func bundleResourceFolderURL() -> URL {
        let thisSourceFile = URL(fileURLWithPath: #file)
        var thisDirectory = thisSourceFile.deletingLastPathComponent()
        thisDirectory = thisDirectory.appendingPathComponent("Resources")
        return thisDirectory
    }
    
    func testAddDocuments() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let filePath = bundleResourceURL(forResource: "APACHE_LICENSE", withExtension: "pdf")
        let txtPath = bundleResourceURL(forResource: "the_school_short_story", withExtension: "txt")
        
        let asyncManager = SearchIndexer.AsyncManager.SearchTask
    }
}
