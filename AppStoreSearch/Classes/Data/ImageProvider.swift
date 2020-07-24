//
//  ImageProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ImageProviding {
    
}

///이미지 다운로드 제공
final class ImageProvider: ImageProviding {

    //MARK: * Singleton --------------------
    static let shared = ImageProvider()
    
    ///cache
    private let imageCache = NSCache<AnyObject, AnyObject>() //extract?
    
    private init() {
        imageCache.totalCostLimit = 20 * (1024 * 1024) //20 mega bytes
    }

    
    // MARK: - * Main Logic --------------------
    
    func get(_ urlString: String) -> Observable<UIImage> {
        
        guard let url = URL(string: urlString) else {
            return Observable.error(NetworkError.urlGeneration)
        }
        
        return Observable.create { observer in
            var task: URLSessionDataTask?
            
            let cachedImage = self.imageCache.object(forKey: urlString as AnyObject) as? UIImage
            if let image = cachedImage {//캐시에서 읽는 경우,
                observer.onNext(image)
                observer.onCompleted()
            } else {
                task = URLSession.shared.dataTask(with: url) { data, response, error in
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
                    
                    
                    self.imageCache.setObject(image as AnyObject, forKey: urlString as AnyObject) //캐시에 저장
                    observer.onNext(image)
                    observer.onCompleted()
                }
            }
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }

}
