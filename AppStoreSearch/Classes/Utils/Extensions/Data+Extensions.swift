//
//  Data+Extensions.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

/// extesion concept from Moya RxSwift
///Moya 구현 대신 비교적 간단한 스펙이라서 직접 구현함.
extension Data {
    func map<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: self)
        } catch let error {
            throw error
        }
    }
}

