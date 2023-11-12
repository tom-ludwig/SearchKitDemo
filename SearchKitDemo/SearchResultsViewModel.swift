//
//  SearchResultsViewModel.swift
//  SearchKitDemo
//
//  Created by Tommy Ludwig on 12.11.23.
//

import Foundation

struct SearchResultsViewModel: Identifiable {
    var id = UUID()
    var fileName: String
    var url: URL
    var score: Float
}
