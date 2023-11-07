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
        
        
        let asyncManager = SearchIndexer.AsyncManager(index: indexer)
        let expectation = XCTestExpectation(description: "Async operations completed")
        Task {
            let result = await asyncManager.addFiles(urls: [filePath, txtPath])
            print(result.count)
            XCTAssertEqual(result.count, 2)
            asyncManager.index.flush()
            print(asyncManager.index.documents())
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testSearchDocuments() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let filePath = bundleResourceURL(forResource: "APACHE_LICENSE", withExtension: "pdf")
        let txtPath = bundleResourceURL(forResource: "the_school_short_story", withExtension: "txt")
        
        
        let asyncManager = SearchIndexer.AsyncManager(index: indexer)
        let expectation = XCTestExpectation(description: "Async operations completed")
        Task {
            let result = await asyncManager.addFiles(urls: [filePath, txtPath])
            XCTAssertEqual(result.count, 2)
            asyncManager.index.flush()
            
            asyncManager.next(query: "school", 10) { searchResults in
                let urls = searchResults.results.map {
                    $0.url
                }
                XCTAssertEqual(urls.first, txtPath)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testAsyncPerformance() {
        self.measure {
            Task {
                testAddDocuments()
            }
        }
    }
}
