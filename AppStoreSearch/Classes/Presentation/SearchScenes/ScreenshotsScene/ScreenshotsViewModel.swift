//
//  ScreenshotsViewModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxSwiftExt

final class ScreenshotsViewModel: ViewModelType {
    
    // MARK: - * Properties  --------------------
    let coordinatorRelay = PublishRelay<ScreenshotsCoordinator.CoordinationResult>()
    
    // MARK: - * Dependencies --------------------
    private let screenshotURLs: [String]
    private let index: Int
    
    // MARK: - * private --------------------
    private let disposeBag = DisposeBag()
    
    init(screenshotURLs: [String], index: Int) {
        self.screenshotURLs = screenshotURLs
        self.index = index
    }
    
    func transform(input: Input) -> Output {
        return Output(screenshotURLsWithIndex: .just((screenshotURLs, index)))
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension ScreenshotsViewModel {
    struct Input {
    }
    
    struct Output {
        let screenshotURLsWithIndex: Driver<([String], Int)>
    }
}
