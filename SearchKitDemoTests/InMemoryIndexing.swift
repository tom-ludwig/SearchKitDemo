//
//  IndexingAndSearchingTests.swift
//  SearchKitDemoTests
//
//  Created by Tommy Ludwig on 03.11.23.
//

@testable import SearchKitDemo
import XCTest

final class IndexingAndSearchingTests: XCTestCase {
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
    
    func testIndexFile() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let filePath = bundleResourceURL(forResource: "APACHE_LICENSE", withExtension: "pdf")
        let textFilePath = bundleResourceURL(forResource: "the_school_short_story", withExtension: "txt")
        
        var indexResults = indexer.add(fileURL: filePath, canReplace: false)
        XCTAssertEqual(indexResults, true)
        indexResults = indexer.add(fileURL: textFilePath, canReplace: false)
        XCTAssertEqual(indexResults, true)
        
        indexer.flush()
    }
    
    func testIndexFolder() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let folderPath = bundleResourceFolderURL()
        let result = indexer.addFolderContent(folderURL: folderPath, canReplace: false)
        XCTAssertEqual(result.count, 3)
    }
    
    func testSearchFiles() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let filePath = bundleResourceURL(forResource: "APACHE_LICENSE", withExtension: "pdf")
        let textFilePath = bundleResourceURL(forResource: "the_school_short_story", withExtension: "txt")
        
        var indexResults = indexer.add(fileURL: filePath, canReplace: false)
        XCTAssertEqual(indexResults, true)
        indexResults = indexer.add(fileURL: textFilePath, canReplace: false)
        XCTAssertEqual(indexResults, true)
        
        indexer.flush()
        
        var searchResults = indexer.search("apache")
        XCTAssertEqual(1, searchResults.count)
        XCTAssertEqual(filePath, searchResults[0].url)
        
        searchResults = indexer.search("excavating")
        XCTAssertEqual(1, searchResults.count)
        XCTAssertEqual(searchResults[0].url, textFilePath)
        
    }
    
    func testSearchFolder() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let folderPath = bundleResourceFolderURL()
        let result = indexer.addFolderContent(folderURL: folderPath, canReplace: false)
        XCTAssertEqual(result.count, 3)
        
        indexer.flush()
        
        var searchResults = indexer.search("apache")
        XCTAssertEqual(1, searchResults.count)
        
        searchResults = indexer.search("school")
        XCTAssertEqual(searchResults.count, 1)
    }
    
    func testRemoveDocument() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let doc1 = FileHelper.url("doc://viewModel.swift")
        XCTAssertTrue(indexer.add(doc1, text: "struct ViewModel: Identifiable, Hashable, Codable {"))
        let doc2 = FileHelper.url("doc://apiCall.swift")
        XCTAssertTrue(indexer.add(doc2, text: "public func createUser(name: String, email: String, password: String) async throws -> User {"))
        
        indexer.flush()
        
        var documents = indexer.documents()
        XCTAssertEqual(documents.count, 2)
        
        XCTAssertEqual(indexer.search("ViewModel").count, 1)
        XCTAssertEqual(indexer.search("func").count, 1)
        
        XCTAssertTrue(indexer.remove(url: doc1))
        indexer.flush()
        
        documents = indexer.documents()
        
        XCTAssertEqual(documents.count, 1)
        XCTAssertEqual(indexer.search("ViewModel").count, 0)
        XCTAssertEqual(indexer.search("func").count, 1)
    }
    
    func testProximitySearch() {
        let properties = SearchIndexer.CreateProperties(proximityIndexing: true)
        guard let indexer = SearchIndexer.Memory.Create(properties: properties) else {
            XCTFail()
            return
        }
        
        let doc1 = FileHelper.url("doc://viewModel.swift")
        XCTAssertTrue(indexer.add(doc1, text: "struct ViewModel: Identifiable, Hashable, Codable {"))
        
        indexer.flush()
        
        XCTAssertEqual(indexer.search("viEwmodeL").count, 1)
    }
    
    func testWildcardSearching() {
        let properties = SearchIndexer.CreateProperties(proximityIndexing: true)
        guard let indexer = SearchIndexer.Memory.Create(properties: properties) else {
            XCTFail()
            return
        }
        
        let doc1 = FileHelper.url("doc://viewModel.swift")
        XCTAssertTrue(indexer.add(doc1, text: "struct ViewModel: Identifiable, Hashable, Codable {"))
        
        indexer.flush()
        
        // Note that two asterisk symbols are required to perform a wildcard search. Infront of the search term for prefix matching and at the end of the search term for suffix matching.
        XCTAssertEqual(indexer.search("*modeL*").count, 1)
    }
    
    func testSaveAndLoad() {
        guard let indexer = SearchIndexer.Memory.Create() else {
            XCTFail()
            return
        }
        
        let textFilePath = bundleResourceURL(forResource: "the_school_short_story", withExtension: "txt")
        
        XCTAssertTrue(indexer.add(fileURL: textFilePath, canReplace: false))
        
        indexer.flush()
        
        let searchResults = indexer.search("excavating")
        XCTAssertEqual(1, searchResults.count)
        XCTAssertEqual(searchResults[0].url, textFilePath)
        
        // Save the current index.
        let savedIndex = indexer.getAsData()
        XCTAssertNotNil(savedIndex)
        // Close the index, i.e. the index gets deallocated form memory.
        indexer.close()
        
        // Load the saved index
        guard let loadedIndex = SearchIndexer.Memory(data: savedIndex!) else {
            XCTFail()
            return
        }
        
        let savedIndexResult = loadedIndex.search("excavating")
        XCTAssertEqual(savedIndexResult.count, 1)
    }
    
    func testFileIndexingPerformance() {
        self.measure {
            testIndexFile()
        }
    }
    
    func testFolderIndexingPerformance() {
        self.measure {
            testIndexFolder()
        }
    }
}
