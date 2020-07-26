//
//  API.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//
import Foundation

protocol API {
    var url: URL { get }
    var method: String { get }
}
