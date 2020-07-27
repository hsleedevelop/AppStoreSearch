//
//  URLCacheImageProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

///이미지 다운로드 제공
final class URLCacheImageProvider: ImageProvider {

    //MARK: * Singleton --------------------
    
    // MARK: - *  --------------------
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 60
        configuration.waitsForConnectivity = false
        
        let memoryCapacity: Int = 50 * 1024 * 1024
        let diskCapacity: Int = 30 * 1024 * 1024
        
        configuration.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
        
        return URLSession(configuration: configuration)
    }()

    
    // MARK: - * Main Logic --------------------
    
    override func get(_ urlString: String) -> Observable<UIImage> {
        
        guard let url = URL(string: urlString) else {
            return Observable.error(NetworkError.urlGeneration)
        }
        
        return Observable.create { observer in
            let task = Self.urlCache.session.dataTask(with: url) { data, response, error in
                logI("Image Cache:currentMemoryUsage= \(Self.urlCache.session.configuration.urlCache?.currentMemoryUsage ?? 0)")
                logI("Image Cache:currentDiskUsage= \(Self.urlCache.session.configuration.urlCache?.currentDiskUsage ?? 0)" )

                guard error == nil else {
                    observer.onError(NetworkError.generic(error!))
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    observer.onError(NetworkError.notConnected)
                    return
                }
                
                guard 200 ... 399 ~= statusCode else {
                    observer.onError(NetworkError.error(statusCode: statusCode, data: data))
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.withMessage("no data."))
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    observer.onError(NetworkError.withMessage("can't convert image."))
                    return
                }
                
                observer.onNext(image)
                observer.onCompleted()
            }
            
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
