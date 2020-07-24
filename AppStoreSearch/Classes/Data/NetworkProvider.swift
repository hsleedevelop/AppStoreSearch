//
//  NetworkProvider.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case withMessage(String?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}


protocol NetworkProvider {
    associatedtype T: API
    func request(api: T) -> Observable<Data>
}


extension NetworkProvider {
    /// - Parameter api: api path generic
    /// - Returns: response date
    func request(api: T) -> Observable<Data> {
        let url = api.url
        
        return Observable.create { observer in
            let request = NSMutableURLRequest(url: url)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
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
                    observer.onError(NetworkError.withMessage("no data"))
                    return
                }

                observer.onNext(data)
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
