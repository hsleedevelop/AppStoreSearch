//
//  AppListSectionModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxDataSources

struct AppListSectionModel {
    var section: Int
    var items: [SearchResultApp]
}

extension AppListSectionModel: AnimatableSectionModelType {
    typealias Identity = Int
    typealias Item = SearchResultApp
    
    var identity: Identity {
        return section
    }
    
    init(original: AppListSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
