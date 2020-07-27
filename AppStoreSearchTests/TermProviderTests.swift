//
//  TermProviderTests.swift
//  AppStoreSearchTests
//
//  Created by HS Lee on 2020/07/23.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RealmSwift

@testable import AppStoreSearch

class TermProviderTests: XCTestCase {

    var disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStore() throws {
        let provider = TermProvider()
        
        provider.store("앱스토어1")
            .subscribe(onNext: { result in
                XCTAssert(result == true)
            })
            .disposed(by: disposeBag)
        
        provider.store("앱스토어2")
            .subscribe(onNext: { result in
                XCTAssert(result == true)
            })
            .disposed(by: disposeBag)
    }
    
    func testStoreToRealm() throws {
        let provider = RealmProvider()
        
        provider.store("앱스토어1")
            .subscribe(onNext: { result in
                XCTAssert(result == true)
            })
            .disposed(by: disposeBag)
        
        provider.store("앱스토어2")
            .subscribe(onNext: { result in
                XCTAssert(result == true)
            })
            .disposed(by: disposeBag)
        
        provider.fetch()
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
