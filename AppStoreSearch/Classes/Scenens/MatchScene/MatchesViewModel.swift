//
//  TermViewModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt

final class TermViewModel: ViewModelType {
    // MARK: - * Properties --------------------
    private var disposeBag = DisposeBag()
    private var termObs: Observable<String>
    
    let matchRelay: BehaviorRelay<[String]>
    let cancelRelay: PublishRelay<Void>
    
    init(termObs: Observable<String>) {
        self.termObs = termObs

        self.matchRelay = .init(value: [])
        self.cancelRelay = .init()
    }
    
    func transform(input: Input) -> Output {

//        let selectedPhoto = indexRelay.withLatestFrom(self.photosObs) { ($0, $1) }
//            .map { $0.1[$0.0] }
        let matches = input.matches
        return Output(list: matches.asDriver { _ in Driver.empty() })
        
        return Output(matches: selectedPhoto.asDriverOnErrorJustComplete(),
                      term: photosObs.asDriverOnErrorJustComplete())
    }
}

extension TermViewModel {
    struct Input {
        
    }
    
    struct Output {
        var matches: Driver<[String]>
        var term: Driver<String>
    }
}
