//
//  AppListViewController.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/23.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources

class AppListViewController: UIViewController, Alertable {
    // MARK: - * type definition --------------------
    typealias ViewModelType = AppListViewModel
    typealias AppListDataSource = RxTableViewSectionedAnimatedDataSource<AppListSectionModel>
    
    // MARK: - * dependencies --------------------
    var viewModel: ViewModelType!
    
    // MARK: - * properties --------------------
    private let disposeBag = DisposeBag()
    private var searchRelay = PublishRelay<String>()
    private var dataSource: AppListDataSource!
    

    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.applist.queue", qos: DispatchQoS.default)
    private var workItems = [IndexPath: DispatchWorkItem]()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!

    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var forLabel: UILabel!
    
    // MARK: - * LifeCycles --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearances()
        setupTableView()

        setupDataSource()
        setupRx()
        bindViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //cancel all items
        self.workItems.forEach { $0.value.cancel() }
    }

    // MARK: - * Initialize --------------------
    private func setupAppearances() {
        noResultsView.isHidden = true
    }

    private func setupTableView() {
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
    
        tableView.rowHeight = Metric.tableRowHeight
    }
    
    private func setupDataSource() {
        let configureCell: AppListDataSource.ConfigureCell = { (dataSource, tableView, indexPath, item) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppListTableViewCell") as? AppListTableViewCell else {
                return .init()
            }
            cell.configure(item)
            return cell
        }
        
        self.dataSource = .init(animationConfiguration: .init(reloadAnimation: .fade), configureCell: configureCell)
    }
    
    private func setupRx() {
        //did select row
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(SearchResultApp.self))
            .do(onNext: { [weak self] ip, _ in  //TODO: refactor to bind curry
                self?.tableView.deselectRow(at: ip, animated: true)
            })
            .map { $0.1 }
            .map { AppListCoordinator.Flow.detail($0) }
            .bind(to: viewModel.flowRelay)
            .disposed(by: disposeBag)
        
        //prefetching
        tableView.rx.prefetchRows.asObservable()
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
        tableView.rx.cancelPrefetchingForRows.asObservable()
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
    
    // MARK: - * Binding --------------------
    private func bindViewModel() {
        ///make prefetching workItem for screenshots in uitableviewcell
        func nestedGenerateWorkItem(_ app: SearchResultApp, bag: DisposeBag) -> DispatchWorkItem {
            return DispatchWorkItem {
                app.screenshots?.enumerated().forEach({ offset, screenshotURL in
                    guard offset < 3 else { return }
                    ImageProvider.shared.get(screenshotURL)
                        .debug("get image", trimOutput: false)
                        .subscribe()
                        .disposed(by: bag)
                })
            }
        }
        
        let output = viewModel.transform(input: .init())
        
        output.result
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.tableView.isHidden = $0.1.count <= 0
                self.noResultsView.isHidden = !self.tableView.isHidden
            })
            .map { $0.1 }
            .do(onNext: { [weak self] result in //make prefetching workItem
                guard let self = self else { return }
                self.workItems = result.enumerated().reduce([IndexPath: DispatchWorkItem]()) {
                    var dict = $0
                    dict[IndexPath(item: $1.offset, section: 0)] = nestedGenerateWorkItem($1.element, bag: self.disposeBag)
                    return dict
                }
                logD("result.results?.enumerated().reduce(self?.workItems ?? [:]) \(self.workItems.count)")
            })
            .map { [AppListSectionModel(section: 0, items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.isLoading
            .map { !$0 }
            .drive(loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - * Memory Manage --------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

// MARK: - * Metric --------------------
extension AppListViewController {
    struct Metric {
        static let tableRowHeight: CGFloat = 300
    }
}
