//
//  AppStoreSearchUITests.swift
//  AppStoreSearchUITests
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import XCTest

class AppStoreSearchUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchCase1() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let searchNavigationBar = app.navigationBars["Search"]
        let appStoreSearchField = searchNavigationBar.searchFields["App Store"]
        appStoreSearchField.tap()
        appStoreSearchField.typeText("카카오뱅크")
        
        if app.buttons["search"].waitForExistence(timeout: 1) {
            app.buttons["search"].tap()
        }
        
        if app.buttons["검색"].waitForExistence(timeout: 1) {
            app.buttons["검색"].tap()
        }
        
        if app/*@START_MENU_TOKEN@*/.tables.cells.staticTexts["카카오뱅크 - 같지만 다른 은행"]/*[[".otherElements[\"Double-tap to dismiss\"].tables",".cells.staticTexts[\"카카오뱅크 - 같지만 다른 은행\"]",".staticTexts[\"카카오뱅크 - 같지만 다른 은행\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,1]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5) {
            app/*@START_MENU_TOKEN@*/.tables.cells.staticTexts["카카오뱅크 - 같지만 다른 은행"]/*[[".otherElements[\"Double-tap to dismiss\"].tables",".cells.staticTexts[\"카카오뱅크 - 같지만 다른 은행\"]",".staticTexts[\"카카오뱅크 - 같지만 다른 은행\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,1]]@END_MENU_TOKEN@*/.tap()
        }
        
        //wait for screenshot image collection
        let imageView = app.descendants(matching: .any)["screenshotImageView"].firstMatch
        imageView.tap()
        
        app.collectionViews.firstMatch.swipeLeft()
        app.collectionViews.firstMatch.swipeLeft()
        app.collectionViews.firstMatch.swipeLeft()
        app.collectionViews.firstMatch.swipeLeft()
        
        app.navigationBars["AppStoreSearch.ScreenshotsView"].buttons["Done"].tap()

        searchNavigationBar.buttons["Search"].tap()
        searchNavigationBar.buttons["Cancel"].tap()
        
        _ = app.descendants(matching: .any)["JUST_WAIT"].waitForExistence(timeout: 7)
    }


    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
