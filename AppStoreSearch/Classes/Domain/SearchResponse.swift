//
//  SearchResponse.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

///검색 결과 모델
struct SearchResponse: Decodable, Equatable {
    var resultCount: Int
    var results: [SearchResultApp]?

    // MARK: - * Local variable --------------------
    var term: String?
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case results
    }
}

func == (lhs: SearchResponse, rhs: SearchResponse) -> Bool {
    return lhs.term == rhs.term &&
            lhs.results == rhs.results
}
