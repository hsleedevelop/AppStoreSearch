//
//  MatchesViewController.swift
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

class MatchesViewController: UIViewController {
    // MARK: - * type definition --------------------
    typealias ViewModelType = MatchesViewModel
    typealias TermDataSource = RxTableViewSectionedReloadDataSource<TermSectionModel>
    
    // MARK: - * dependencies --------------------
    var viewModel: ViewModelType!
    
    // MARK: - * properties --------------------
    private let disposeBag = DisposeBag()
    
    private let termRelay = PublishRelay<String?>()
    private let searchRelay = PublishRelay<String>()
    private let viewReloadRelay = PublishRelay<Void>()
    
    private var dataSource: TermDataSource!
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    

    // MARK: - * LifeCycles --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupDataSource()
        setupRx()
        bindViewModel()
    }


    // MARK: - * Initialize --------------------
    private func setupTableView() {
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
    
        tableView.rowHeight = Metric.tableRowHeight
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    }
    
    private func setupDataSource() {
        let configureCell: TermDataSource.ConfigureCell = { (dataSource, tableView, indexPath, item) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") else {
                return .init()
            }
            cell.textLabel?.text = item
            cell.textLabel?.textColor = .darkText
            return cell
        }
        
        self.dataSource = .init(configureCell: configureCell)
    }
    
    private func setupRx() {
        Observable
        .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
        .do(onNext: { [weak self] ip, _ in  //TODO: refactor to bind curry
            self?.tableView.deselectRow(at: ip, animated: true)
        })
        .map { $0.1 }
        .bind(to: searchRelay)
        .disposed(by: disposeBag)
    }
    
    // MARK: - * Binding --------------------
    private func bindViewModel() {
        let input = ViewModelType.Input(search: searchRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.matches
            .map { [TermSectionModel(header: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

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
extension MatchesViewController {
    struct Metric {
        static let tableRowHeight: CGFloat = 44
    }
}

extension Reactive where Base: MatchesViewController {
    var deselectRow: Binder<IndexPath> {
        return Binder(self.base) { (view, value) in
            view.tableView.deselectRow(at: value, animated: true)
        }
    }
}
