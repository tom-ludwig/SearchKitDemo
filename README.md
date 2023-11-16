# SearchKitDemo
This project showcases the implementation of SearchKit for efficient indexing and searching within files, seamlessly integrated with SwiftUI.

## Features
- Index files and folders quickly and efficiently using in-memory or file-based indexes
- Add text/files to the index for a given file URL
- Perform searches within the indexed files for a given query with amazing speed
- Remove a document from the index for a given file URL
- Employ a pre-existing index to enhance efficiency when working with a particular file
- Persist the present index by saving it as a file, ensuring seamless data retention and accessibility.

## Test Results:
While putting the algorithm to the test on a project encompassing 29,000 lines of code spread across 500 files, the following results were attained:
- Indexing Time: 0.101 seconds
- Searching Time (245 results): 0.0051 seconds
- Searching Time (5 results): 0.0005 seconds

*Please bear in mind that these results can vary depending on the unique characteristics of different projects and the specifications of individual machines.*

## Usage

1. Clone the repository
2. Open `SearchKitDemo.xcodeproj` in Xcode
3. Build and run the project

## Available Methods
### Create a new in-memory index

In-memory indexes are faster but consume more memory. They are not persisted across app launches.
```swift
let indexer = SearchIndexer.Memory.Create()
```

### Create a new file-based index
File-based indexes are slower but consume less memory. They are persisted across app launches.
```swift
let indexer = SearchIndexer.File.Create()
```

### Add some text to the index for a given file URL
This method adds the provided text to the index for the given file URL. If `canReplace` is true, it will replace an existing document with the new one.
```swift
let fileURL = URL(fileURLWithPath: "/path/to/your/file.txt")
let text = "This is some text to add to the index."
let canReplace = true
indexer.add(url: fileURL, text: text, canReplace: canReplace)
```

### Search the indexed text for a given query
This method searches the indexed text for the provided query and returns the results.
```swift
let query = "text to search for"
let results = indexer.search(query: query)
```

### Remove a document from the index for a given file URL
This method removes the document associated with the given file URL from the index.
```swift
let fileURL = URL(fileURLWithPath: "/path/to/your/file.txt")
indexer.remove(url: fileURL)
```

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
