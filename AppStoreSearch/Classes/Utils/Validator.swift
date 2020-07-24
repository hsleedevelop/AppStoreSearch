//
//  Validator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

final class Validator {
    private enum Policy {
        case term
        
        var pattern: String {
            switch self {
            case .term:
                return "^[가-힣ㄱ-ㅎㅏ-ㅣ0-9\\s]$"
            }
        }
    }
    
    static func isValid(term: String) -> Bool {
        isValid(target: term, policy: Policy.term)
    }
    
    private static func isValid(target: String, policy: Policy) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: policy.pattern, options: [])
            let result = regex.firstMatch(in: target, options: [], range: .init(location: 0, length: target.utf16.count))
            return result != nil
        } catch {
            logW(error.localizedDescription)
            return false
        }
    }
}
