//
//  AppCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

    // MARK: - * Private --------------------
    private let window: UIWindow

    // MARK: - * Initialize --------------------
    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - * Coordinate --------------------
    override func start() -> Observable<Void> {
        let serachCoordinator = SearchCoordinator(window: window)
        return coordinate(to: serachCoordinator)
    }
}
