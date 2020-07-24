//
//  ScreenshotsCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

final class ScreenshotsCoordinator: BaseCoordinator<Void> {
    enum Flow {
        case main
        case didFetch(String)
        case detail(SearchResultApp)
    }
}
