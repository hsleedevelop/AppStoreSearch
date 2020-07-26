//
//  ImageProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ImageProviding {
     func get(_ urlString: String) -> Observable<UIImage>
}

class ImageProvider: ImageProviding {
    static let urlCache: URLCacheImageProvider = URLCacheImageProvider()
    static let nsCache: NSCacheImageProvider = NSCacheImageProvider()
    
    class var shared: ImageProvider {
        return Self.urlCache
    }
    
    func get(_ urlString: String) -> Observable<UIImage> {
        return .empty()
    }
}
