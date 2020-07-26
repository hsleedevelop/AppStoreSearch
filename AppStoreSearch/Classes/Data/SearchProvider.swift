//
//  SearchProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchProviding {
    func search(term: String) -> Observable<[SearchResultApp]>
}

final class SearchProvider: NetworkProvider, SearchProviding {
    typealias T = SearchAPI

    func search(term: String) -> Observable<[SearchResultApp]> { //TODO: refactor -> 메소드 시그니쳐,
        return request(api: .search(term, "software", "KR", 20))
            .map(SearchResponse.self)
            .map { $0.results ?? [] }
    }
}
