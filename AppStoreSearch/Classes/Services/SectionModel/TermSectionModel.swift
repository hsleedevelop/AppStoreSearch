//
//  TermSectionModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxDataSources

struct TermSectionModel {
    var header: String
    var items: [String]
}

extension TermSectionModel: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = String
    
    var identity: Identity {
        return header
    }
    
    init(original: TermSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

