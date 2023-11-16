//
//  SearchResultsViewModel.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 12.11.23.
//

import Foundation
import AppKit

struct SearchResultsViewModel: Identifiable, Hashable {
    var id = UUID()
    var url: URL
    var score: Float
    var lineMatches: [SearchResultLineMatchesModel]
}

struct SearchResultLineMatchesModel: Identifiable, Equatable, Hashable {
    var id = UUID()
    var file: URL
    var lineNumber: Int
    var lineContent: String
    var keywordRange: Range<String.Index>
    
    func attributedLabel() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(
                ofSize: 13,
                weight: .regular
            ),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(
                ofSize: 13,
                weight: .bold
            ),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let lowerIndex = lineContent.safeOffset(keywordRange.lowerBound, offsetBy: -60)
        let upperIndex = lineContent.safeOffset(keywordRange.upperBound, offsetBy: 60)
        let preflix = String(lineContent[lowerIndex..<keywordRange.lowerBound])
        let searchMatch = String(lineContent[keywordRange.lowerBound..<keywordRange.upperBound])
        let postflix = String(lineContent[keywordRange.upperBound..<upperIndex])
        
        let attributedString = NSMutableAttributedString(
            string: preflix,
            attributes: normalAttributes
        )
        attributedString.append(NSAttributedString(string: searchMatch, attributes: boldAttributes))
        attributedString.append(NSAttributedString(string: postflix, attributes: normalAttributes))
        
        return attributedString
    }
}
