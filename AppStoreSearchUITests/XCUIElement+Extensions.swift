//
//  XCUIElement+Extensions.swift
//  AppStoreSearchUITests
//
//  Created by HS Lee on 2020/07/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    func clearText(andReplaceWith newText:String? = nil) {
        tap()
        press(forDuration: 1.0)
        var select = XCUIApplication().menuItems["Select All"]

        if !select.exists {
            select = XCUIApplication().menuItems["Select"]
        }
        //For empty fields there will be no "Select All", so we need to check
        if select.waitForExistence(timeout: 0.5), select.exists {
            select.tap()
            typeText(String(XCUIKeyboardKey.delete.rawValue))
        } else {
            tap()
        }
        if let newVal = newText {
            typeText(newVal)
        }
    }

    /// Waits the specified amount of time for the element's exist property to be true
    /// and returns false if the timeout expires without the element coming into existence.
    ///
    /// - note: This is not needed when migrating to Xcode 9 & iOS 11 SDK as it's built in!
    ///   https://developer.apple.com/documentation/xctest/xcuielement/2879412-waitforexistence
    func waitForExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == 1")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout) // `XCTWaiter` Requires Xcode 8.3+
        return exists
    }
    
    private func waitForPredicate(format: String, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: format)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let waiter = XCTWaiter()

        switch waiter.wait(for: [expectation], timeout: timeout) {
        case .completed:
            return true
        default:
            return false
        }
    }
    
    func waitForEnable(timeout: TimeInterval) -> Bool {
        return waitForPredicate(format: "enabled == true", timeout: timeout)
    }
    
    func waitForFocus(timeout: TimeInterval) -> Bool {
        return waitForPredicate(format: "hasKeyboardFocus == true", timeout: timeout)
    }
}
