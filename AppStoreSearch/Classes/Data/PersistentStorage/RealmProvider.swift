//
//  RealmProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/27.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class TermRealmObject: Object {
    @objc dynamic var index = 0
    @objc dynamic var term = ""
}

class RealmProvider: TermProviding {
    static let maxTermsCount = 10

    lazy var realm: Realm = {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("AppStoreSearchTerm.realm")
        
        let realm = try! Realm(configuration: config)
        return realm
    }()
    
    init() {
    }
    
    func store(_ term: String) -> Observable<Bool> {
        let termObjets = self.realm.objects(TermRealmObject.self).sorted(byKeyPath: "index", ascending: false)
        if let existObject = termObjets.filter("term == '\(term)'").first {
            print("exists")
            try? self.realm.write {
                self.realm.delete(existObject)
            }
        }
        
        while (termObjets.count >= Self.maxTermsCount) {
            guard let lastObject = termObjets.last else {
                break
            }
            try? self.realm.write {
                self.realm.delete(lastObject)
            }
        }

        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            do {
                let termObject = TermRealmObject()
                termObject.term = term
                termObject.index = (termObjets.max(ofProperty: "index") as Int? ?? 0) + 1
                
                try self.realm.write {
                    self.realm.add(termObject)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func fetch() -> Observable<[String]> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let termsObjects = self.realm.objects(TermRealmObject.self).sorted(byKeyPath: "index", ascending: false)
            let terms = termsObjects.value(forKeyPath: "term") as? [String] ?? []
            observer.onNext(terms)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}
