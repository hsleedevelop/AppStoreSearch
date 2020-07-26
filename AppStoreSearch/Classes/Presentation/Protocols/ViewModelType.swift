//
//  ViewModelType.swift
//  PhotoListDemo
//
//  reference : https://en.wikipedia.org/wiki/Black_box
//  https://medium.com/@SergDort/viewmodel-in-rxswift-world-13d39faa2cf5
//  https://github.com/sergdort/CleanArchitectureRxSwift
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
