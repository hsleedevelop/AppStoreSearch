//
//  TermProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

final class TermProvider: TermProviding {
    static let termsKey = "SEARCH_TERMS"
    static let maxTermsCount = 10
    
    private var dispatchQueue = DispatchQueue(label: "io.hsleedevelop.terms.queue", qos: DispatchQoS.default) //TODO: refactoring -> DI?
    private var terms: [String] = []
    
    func store(_ term: String) -> Observable<Bool> {
        if let index = terms.firstIndex(where: { $0 == term }) {//이미 저장된 검색어일 경우, 최상위로 올림
            terms.remove(at: index) //해당 검색어를 지워둠.
        }
        
        let count = terms.count >= Self.maxTermsCount ? Self.maxTermsCount - 1 : terms.count //최대 검색어 저장 갯수만큼 저장
        terms = [term] + terms[0 ..< count] //가장 최신을 위로
        
        return Observable.create { observer in
            self.dispatchQueue.sync { [weak self] in
                guard let self = self else { return }
                
                UserDefaults.standard.set(self.terms, forKey: Self.termsKey)
                observer.onNext(UserDefaults.standard.synchronize())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    ///저장된 검색어 fetch
    func fetch() -> Observable<[String]> {
        return Observable.create { observer in
            self.dispatchQueue.sync { [weak self] in
                guard let self = self else { return }

                UserDefaults.standard.array(forKey: Self.termsKey).flatMap { $0 as? [String] }.map { self.terms = $0 }
                observer.onNext(self.terms)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
