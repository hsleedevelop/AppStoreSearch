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

class AppListViewController: UIViewController {
    // MARK: - * type definition --------------------
    typealias ViewModelType = AppListViewModel
    typealias AppListDataSource = RxTableViewSectionedAnimatedDataSource<AppListSectionModel>
    
    // MARK: - * dependencies --------------------
    var viewModel: ViewModelType!
    
    // MARK: - * properties --------------------
    private let disposeBag = DisposeBag()
    
    private var searchRelay = PublishRelay<String>()
    private var noResultsRelay = PublishRelay<String>()
    
    private var dataSource: AppListDataSource!
    
    
    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.applist.queue", qos: DispatchQoS.default)
    private var workItems = [IndexPath: DispatchWorkItem]()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - * LifeCycles --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearances()
        setupUI()
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

    }

    private func setupUI() {

    }

    private func setupTableView() {
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
    
        tableView.rowHeight = Metric.tableRowHeight
        
        //tableView.register(AppListTableViewCell.self, forCellReuseIdentifier: "AppListTableViewCell")
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
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(SearchResultApp.self))
            .do(onNext: { [weak self] ip, _ in  //TODO: refactor to bind curry
                self?.tableView.deselectRow(at: ip, animated: true)
            })
            .map { $0.1 }
            .map { AppListCoordinator.Flow.detail($0) }
            .bind(to: viewModel.flowRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - * Binding --------------------
    private func bindViewModel() {
        ///make prefetching workItem for screenshots in uitableviewcell
        func nestedGenerateWorkItem(_ app: SearchResultApp) -> DispatchWorkItem {
            return DispatchWorkItem {
                app.screenshots?.enumerated().forEach({ [weak self] offset, screenshotUrl in
                    guard offset < 3, let self = self else { return }
                    ImageProvider.shared.get(screenshotUrl)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                })
            }
        }
        
        let output = viewModel.transform(input: .init())
        
        output.result
            .do(onNext: { [weak self] in
                if let response = $0.1, response.resultCount <= 0 {
                    self?.noResultsRelay.accept($0.0)
                }
            })
            .map { $0.1 }
            .unwrap() //refactor
            .filter { $0.resultCount > 0 }
            .distinctUntilChanged()
            .do(onNext: { [weak self] result in //make prefetching workItem
                self?.workItems = (result.results ?? []).enumerated().reduce([IndexPath: DispatchWorkItem]()) {
                    var dict = $0
                    dict[IndexPath(item: $1.offset, section: 0)] = nestedGenerateWorkItem($1.element)
                    return dict
                }
                
                logD("result.results?.enumerated().reduce(self?.workItems ?? [:]) \(self?.workItems.count ?? 0)")
            })
            .map { [AppListSectionModel(section: 0, items: $0.results ?? [])] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //no data
        noResultsRelay.asObservable()
//            .map { [unowned self] in (FlowCoordinator.Step.noResults($0), self.parent ?? self)  }
//            .bind(to: FlowCoordinator.shared.rx.flow)
//            .disposed(by: disposeBag)
    }

    // MARK: - * Main Logic --------------------


    // MARK: - * UI Events --------------------


    // MARK: - * Memory Manage --------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension Reactive where Base: AppListViewController {
    var deselectRow: Binder<IndexPath> {
        return Binder(self.base) { (view, value) in
            view.tableView.deselectRow(at: value, animated: true)
        }
    }
}
