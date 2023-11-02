//
//  SearchIndex+Summariser.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 02.11.23.
//

import Foundation

extension SearchIndex {
    @objc(DFSearchIndexSummarizer) public class Summarizer: NSObject {
        private let summary: SKSummary

        @objc(DFSearchIndexSummarizerSentence)
        public class Sentence: NSObject {
            /// The text content of the sentence
            @objc public let text: String
            /// The rank of each sentence; most important sentence is rank 1
            @objc public let rank: Int
            /// the index of the sentence
            @objc public let sentenceOrder: Int
            /// The index of the paragraph in which sentence occured
            @objc public let paragraphOrder: Int

            @objc fileprivate init(text: String, rank: Int, sentenceOrder: Int, paragraphOrder: Int) {
                self.text = text
                self.rank = rank
                self.sentenceOrder = sentenceOrder
                self.paragraphOrder = paragraphOrder
            }

            public override var debugDescription: String {
                return "Sentence Order: \(self.sentenceOrder), Paragraph Order: \(self.paragraphOrder) Rank: \(self.rank) \n '\(self.text)'"
            }
        }

        @objc(DFSearchIndexSummarizerParagraph)
        public class Paragraph: NSObject {
            /// The text content of the paragraph
            @objc public let text: String
            /// The rank of each paragraph; most important sentence is rank 1
            @objc public let rank: Int
            /// The index of the paragraph in which sentence occured
            @objc public let paragraphOrder: Int

            @objc fileprivate init(text: String, rank: Int, paragraphOrder: Int) {
                self.text = text
                self.rank = rank
                self.paragraphOrder = paragraphOrder
            }

            public override var debugDescription: String {
                return "Paragraph Order: \(self.paragraphOrder) Rank: \(self.rank) \n '\(self.text)'"
            }
        }

        @objc public init(_ textString: String) {
            self.summary = SKSummaryCreateWithString(textString as CFString).takeRetainedValue()
        }

        /// Return the number of paragraphs in the text
        @objc public func paragraphCount() -> Int {
            return SKSummaryGetParagraphCount(self.summary)
        }

        /// Return the number of sentences in the text
        @objc public func sentenceCount() -> Int {
            return SKSummaryGetSentenceCount(self.summary)
        }

        /// Gets detailed information about a body of text for constructing a custom sentence-based summary string.
        ///
        /// - Parameter maxSentences: The maximum number of sentences to return, or all paragraphs if not specified
        ///                           If requesting less than the total count, returns sentences in rank order
        /// - Returns: an array containing the sentences contained within the text
        @objc public func sentenceSummary(maxSentences: Int = -1) -> [Sentence] {
            var result: [Sentence] = []

            let limit = (maxSentences <= 0) ? self.sentenceCount() : maxSentences

            var rankOrder: [CFIndex] = Array(repeating: 0, count: limit)
            var sentenceOrder: [CFIndex] = Array(repeating: 0, count: limit)
            var paragraphOrder: [CFIndex] = Array(repeating: 0, count: limit)

            let sentenceCount = SKSummaryGetSentenceSummaryInfo(
                self.summary,
                maxSentences,
                &rankOrder,
                &sentenceOrder,
                &paragraphOrder
            )

            if sentenceCount <= 0 {
                return result
            }

            for count in 0 ..< sentenceCount {
                let sentence = SKSummaryCopySentenceAtIndex(self.summary, sentenceOrder[count]).takeRetainedValue()
                let summary = Sentence(
                    text: sentence as String,
                    rank: rankOrder[count] as Int,
                    sentenceOrder: sentenceOrder[count] as Int,
                    paragraphOrder: paragraphOrder[count] as Int
                )
                result.append(summary)
            }
            return result
        }

        /// Return a paragraph summary for the text
        ///
        /// - Parameter maxParagraphs: the maximum number of paragraphs to return, or all paragraphs if not specified.
        ///                            If requesting less than the total count, returns paragraphs in rank order
        /// - Returns: an array containing the paragraphs contained in order that they appear in the text
        @objc public func paragraphSummary(maxParagraphs: Int = -1) -> [Paragraph] {
            var result: [Paragraph] = []

            let limit = (maxParagraphs == -1) ? self.paragraphCount() : maxParagraphs

            var rankOrder: [CFIndex] = Array(repeating: 0, count: limit)
            var paragraphOrder: [CFIndex] = Array(repeating: 0, count: limit)

            let paragraphCount = SKSummaryGetParagraphSummaryInfo(self.summary, limit, &rankOrder, &paragraphOrder)
            if paragraphCount <= 0 {
                return result
            }

            for count in 0 ..< paragraphCount {
                let paragraph = SKSummaryCopyParagraphAtIndex(self.summary, paragraphOrder[count]).takeRetainedValue()
                let summary = Paragraph(
                    text: paragraph as String,
                    rank: rankOrder[count] as Int,
                    paragraphOrder: paragraphOrder[count] as Int
                )
                result.append(summary)
            }
            return result
        }
    }
}
