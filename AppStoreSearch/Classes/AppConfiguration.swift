//
//  AppConfiguration.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

final class AppConfiguration {
    lazy var apiBaseURL: String = {
        return "https://itunes.apple.com"
    }()
}
