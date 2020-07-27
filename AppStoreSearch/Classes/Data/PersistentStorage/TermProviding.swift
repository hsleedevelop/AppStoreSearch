//
//  TermProviding.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/27.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

protocol TermProviding: class {
    @discardableResult
    func store(_ term: String) -> Observable<Bool>
    func fetch() -> Observable<[String]>
}
