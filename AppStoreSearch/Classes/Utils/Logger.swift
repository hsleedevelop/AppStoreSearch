//
//  Logger.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

@inline(__always) func logI(_ items: Any...) {
    #if DEBUG
    //print(items)
    #endif
}

@inline(__always) func logD(_ items: Any...) {
    #if DEBUG
    print(items)
    #endif
}

@inline(__always) func logW(_ items: Any...) {
    print(items)
}
