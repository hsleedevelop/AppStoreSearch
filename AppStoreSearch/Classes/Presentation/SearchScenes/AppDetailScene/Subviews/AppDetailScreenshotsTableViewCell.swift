//
//  AppDetailScreenshotsTableViewCell.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AppDetailScreenshotsTableViewCell: UITableViewCell, AppPresentable {

    //MARK: * properties --------------------
    var app: SearchResultApp?
    private var disposeBag = DisposeBag()
    
    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.screenshot.queue", qos: DispatchQoS.default)
    private var workItems = [IndexPath: DispatchWorkItem]()

    private var dataSource: RxCollectionViewSectionedReloadDataSource<ScreenshotSectionModel>!
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .clear
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
            collectionView.scrollsToTop = false
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        //cancel all items
        self.workItems.forEach { $0.value.cancel() }
    }

    //MARK: * Main Logic --------------------
    func configure(_ app: SearchResultApp) {
        guard self.app != app else { return }
        
        self.app = app
        setupCollectionView()
        setupRx()
    }
    
    private func setupCollectionView() {
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            layout.itemSize = screenshotSize
        }
        
        //define datasource
        dataSource = RxCollectionViewSectionedReloadDataSource<ScreenshotSectionModel>(configureCell: { ds, cv, ip, item in
            guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "AppDetailScreenshotCollectionViewCell", for: ip)
                as? AppDetailScreenshotCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configure(item)
            
            return cell
        })
        
        //prefetching
        collectionView.rx.prefetchItems.asObservable()
            .subscribe(onNext: { [weak self] indexPaths in
                for ip in indexPaths {
                    guard ip.row < (self?.dataSource.sectionModels.first?.items.count ?? 0), let workItem = self?.workItems[ip] else {
                        return
                    }
                    self?.dispatchQueue.async(execute: workItem)
                }
            })
            .disposed(by: disposeBag)
        
        //cancel prefetching
        collectionView.rx.cancelPrefetchingForItems.asObservable()
            .subscribe(onNext: { [weak self] indexPaths in
                for ip in indexPaths {
                    if let workItem = self?.workItems[ip] {
                        print("workItem.cancel()")
                        workItem.cancel()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupRx() {
        
        ///make prefetching workItem for screeenshot collectionview cell
        func nestedGenerateWorkItem(_ screenshotUrl: String) -> DispatchWorkItem {
            return DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                ImageProvider.shared.get(screenshotUrl)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
        }
        
        Driver.just(app)
            .unwrap()
            .do(onNext: { [weak self] app in //make prefetching workItem
                self?.workItems = (app.screenshots ?? []).enumerated().reduce( [IndexPath: DispatchWorkItem]() ) {
                    var dict = $0
                    dict[IndexPath(item: $1.offset, section: 0)] = nestedGenerateWorkItem($1.element)
                    return dict
                }
                print("$0.screenshots?.enumerated().reduce(self?.workItems ?? [:]) \(self?.workItems.count ?? 0)")
            })
            .map { [ScreenshotSectionModel(items: $0.screenshots ?? [])] }
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
