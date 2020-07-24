//
//  AppDetailViewController.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources

class AppDetailViewController: UIViewController, AppPresentable {
    
    // MARK: - * type definition --------------------
    typealias ViewModelType = AppDetailViewModel
    typealias AppDetailDataSource = RxTableViewSectionedAnimatedDataSource<AppDetailSectionModel>
    
    // MARK: - * dependencies --------------------
    var viewModel: ViewModelType!
    
    // MARK: - * properties --------------------
    private let disposeBag = DisposeBag()
    
    private var whatNewMoreRelay = BehaviorRelay<Bool>(value: false)
    private var descriptionMoreRelay = BehaviorRelay<Bool>(value: false)
    
    private var dataSource: AppDetailDataSource!
    
    
    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.applist.queue", qos: DispatchQoS.default)
    private var workItems = [IndexPath: DispatchWorkItem]()
    
    // MARK: - * Computed Variables --------------------
    var app: SearchResultApp? {
        get {
            viewModel.app
        }
        set(v) {
            guard let v = v else { return }
            viewModel.app = v
        }
    }
    
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
    
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Metric.tableRowHeight //max height for what's new and description
    }
    
    private func setupDataSource() {
        let configureCell: AppDetailDataSource.ConfigureCell = { [weak self] (ds, tv, ip, model) in
            guard ds.sectionModels.count > ip.section, let self = self else { return .init() }
            
            var cell: UITableViewCell?
            
            switch model {
            case let .header(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailHeaderTableViewCell") as? AppDetailHeaderTableViewCell {
                    tcell.configure(item)
                    cell = tcell
                }
            case let .whatsNew(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailWhatsNewTableViewCell") as? AppDetailWhatsNewTableViewCell {
                    tcell.configure(item)
                    tcell.rx.moreClicked //observe more sequence
                        .drive(self.whatNewMoreRelay)
                        .disposed(by: self.disposeBag)
                    
                    cell = tcell
                }
            case let .preview(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailScreenshotsTableViewCell") as? AppDetailScreenshotsTableViewCell {
                    tcell.configure(item)
                    cell = tcell
                }
            case let .description(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailDescriptionTableViewCell") as? AppDetailDescriptionTableViewCell {
                    tcell.configure(item)
                    tcell.rx.moreClicked //observe more sequence
                        .drive(self.descriptionMoreRelay)
                        .disposed(by: self.disposeBag)
                    
                    cell = tcell
                }
            case let .information(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailInformationCell") as? AppDetailInformationCell {
                    tcell.configure(item)
                    cell = tcell
                }
            }
            
            return cell ?? UITableViewCell()
        }
        
        let titleForHeaderInSection: AppDetailDataSource.TitleForHeaderInSection = { (dataSource, section) in
            return dataSource[section].identity == "information" ? "Information" : ""
        }
        
        self.dataSource = .init(animationConfiguration: .init(reloadAnimation: .fade), configureCell: configureCell, titleForHeaderInSection: titleForHeaderInSection)
    }
    
    private func setupRx() {
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(SearchResultApp.self))
            .do(onNext: { [weak self] ip, _ in  //TODO: refactor to bind curry
                self?.tableView.deselectRow(at: ip, animated: true)
            })
            .map { $0.1 }
            .map { AppDetailCoordinator.Flow.showCarousel($0) }
            .bind(to: viewModel.flowRelay)
            .disposed(by: disposeBag)
        
        Driver.merge(whatNewMoreRelay.asDriver(),
                     descriptionMoreRelay.asDriver())
        .drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - * Binding --------------------
    private func bindViewModel() {
        
        let output = viewModel.transform(input: .init())
            
        output.selectedApp
            .map { [weak self] app -> [AppDetailSectionModel] in
                guard let self = self else { return [] }
                let top = [AppDetailSectionModel(items: [.header(app)]),
                           AppDetailSectionModel(items: [.whatsNew(app)]),
                           AppDetailSectionModel(items: [.preview(app)]),
                           AppDetailSectionModel(items: [.description(app)])]
                
                let bottom = [AppDetailSectionModel(items: self.informations.map {.information($0)} )]
                return top + bottom
        }
        .drive(tableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        //no data
//        noResultsRelay.asObservable()
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
extension AppDetailViewController {
    struct Metric {
        static let tableRowHeight: CGFloat = 600
    }
}

extension Reactive where Base: AppDetailViewController {
    var deselectRow: Binder<IndexPath> {
        return Binder(self.base) { (view, value) in
            view.tableView.deselectRow(at: value, animated: true)
        }
    }
}
