//
//  SearchAPI.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

enum SearchAPI: API {
    ///검색
    case search(String, String, String, Int)
    
    private var path: String {
        switch self {
        case let .search(term, entity, country, limit):
            //urlString = "https://itunes.apple.com/search?term=\(term)&entity=software&country=KR&limit=20"
            return "/search?term=\(term)&entity=\(entity)&country=\(country)&limit=\(limit)"
        }
    }
    
    var method: String {
        switch self {
        default:
            return "GET" //method를 사용해야,,
        }
    }

    var url: URL {
        let urlString = AppConfiguration.init().apiBaseURL + self.path
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            fatalError("wrong url")
        }
        return url
    }
}
