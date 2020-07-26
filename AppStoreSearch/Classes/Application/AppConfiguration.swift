//
//  AppConfiguration.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FLEX

final class AppConfiguration {
    static let shared = AppConfiguration()
    
    // MARK: - * Properties --------------------
    private let disposeBag = DisposeBag()
    
    // MARK: - * Lazy Variable --------------------
    lazy var apiBaseURL: String = {
        return "https://itunes.apple.com"
    }()
    
    lazy var appURLCache: URLCache = {
        let memoryCapacity = 20 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: 0, diskPath: nil)
        return urlCache
    }()

    // MARK: - * Initialize --------------------
    init() {
        setupRx()
    }
    
    // MARK: - * Setup --------------------
    func setupDefaultURLCache() {
        URLCache.shared = appURLCache
    }
    
    private func setupRx() {
        UIApplication.shared.rx
            .methodInvoked(#selector(UIApplicationDelegate.applicationDidReceiveMemoryWarning(_:)))
            .subscribe(onNext: { _ in
                URLCache.shared.removeAllCachedResponses()
            })
            .disposed(by: disposeBag)
    }
}
