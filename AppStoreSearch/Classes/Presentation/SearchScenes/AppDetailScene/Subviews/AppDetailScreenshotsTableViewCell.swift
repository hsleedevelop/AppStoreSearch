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

final class AppDetailScreenshotsTableViewCell: UITableViewCell, AppPresentable, UICollectionViewDelegate {
    // MARK: - * Type defines --------------------
    typealias ScreenshotDataSource = RxCollectionViewSectionedReloadDataSource<ScreenshotSectionModel>
    
    //MARK: * properties --------------------
    var app: SearchResultApp?
    var disposeBag = DisposeBag()
    
    fileprivate var screenShotPressRelay = PublishRelay<([String], Int)>()
    
    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.screenshot.queue", qos: DispatchQoS.default)
    private var workItems = [IndexPath: DispatchWorkItem]()

    private var dataSource: ScreenshotDataSource!
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        //cancel all items
        self.workItems.forEach { $0.value.cancel() }
    }
    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
        setupDataSource()
        updateCollectionViewLayout()
        
        setupRx()
        bindData()
    }

    //MARK: * Binding --------------------
    let bindDataRelay = PublishRelay<SearchResultApp>()
    func configure(_ app: SearchResultApp) {
        guard self.app != app else { return }
        self.app = app
        bindDataRelay.accept(app)
    }
    
    private func setupCollectionView() {
        collectionView.accessibilityIdentifier = "screenshotCollectionView"
        
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.scrollsToTop = false
        
        collectionView.register(.init(nibName: "AppDetailScreenshotCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AppDetailScreenshotCollectionViewCell")
    }
    
    private func setupDataSource() {
        dataSource = ScreenshotDataSource(configureCell: { [weak self] dataSource, collectionView, indexPath, item in
            guard let self = self, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppDetailScreenshotCollectionViewCell", for: indexPath)
                as? AppDetailScreenshotCollectionViewCell else { return .init() }
            
            cell.configure(item, index: indexPath.item)
            cell.rx.screenshotPressed
                .map { (dataSource.sectionModels.first?.items ?? [], $0 ) }
                .bind(to: self.screenShotPressRelay)
                .disposed(by: cell.disposeBag)
            
            return cell
        })
    }
    
    private func updateCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 180, height: 300)
            layout.invalidateLayout()
        }
        self.layoutIfNeeded()
    }
    
    private func setupRx() {
        //prefetching
        collectionView.rx.prefetchItems.asObservable()
            .subscribe(onNext: { [weak self] indexPaths in
                for ip in indexPaths {
                    guard self?.dataSource.sectionModels.first?.items.indices.contains(ip.row) == true, let workItem = self?.workItems[ip] else {
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
                        logD("workItem.cancel()")
                        workItem.cancel()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindData() {
        ///make prefetching workItem for screenshot collectionview cell
        func nestedGenerateWorkItem(_ screenshotURL: String, bag: DisposeBag) -> DispatchWorkItem {
            return DispatchWorkItem {
                ImageProvider.shared.get(screenshotURL)
                    .subscribe()
                    .disposed(by: bag)
            }
        }
        
        bindDataRelay.asDriverOnErrorJustComplete()
            .do(onNext: { [weak self] app in //make prefetching workItem
                guard let self = self else { return }
                self.workItems = (app.screenshots ?? []).enumerated().reduce( [IndexPath: DispatchWorkItem]() ) {
                    var dict = $0
                    dict[IndexPath(item: $1.offset, section: 0)] = nestedGenerateWorkItem($1.element, bag: self.disposeBag)
                    return dict
                }
                logD("$0.screenshots?.enumerated().reduce(self?.workItems ?? [:]) \(self.workItems.count)")
            })
            .map { [ScreenshotSectionModel(items: $0.screenshots ?? [])] }
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension Reactive where Base: AppDetailScreenshotsTableViewCell {
    var screenshotPressed: Observable<([String], Int)> {
        return base.screenShotPressRelay.asObservable()
    }
}
