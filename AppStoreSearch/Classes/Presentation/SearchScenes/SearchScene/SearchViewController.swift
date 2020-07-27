//
//  SearchViewController.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources

class SearchViewController: UIViewController {
    // MARK: - * type definition --------------------
    typealias ViewModelType = SearchViewModel
    typealias TermDataSource = RxTableViewSectionedAnimatedDataSource<TermSectionModel>
    
    // MARK: - * dependencies --------------------
    var viewModel: ViewModelType!
    var resultViewController: UIViewController!
    
    // MARK: - * properties --------------------
    private let disposeBag = DisposeBag()
    
    private let termRelay = PublishRelay<String?>()
    private let searchRelay = PublishRelay<String?>()
    private let viewWillAppearRelay = PublishRelay<Void>()
    
    private var dataSource: TermDataSource!
    
    private lazy var searchController: UISearchController = { [unowned self] in
        return UISearchController(searchResultsController: self.resultViewController)
    }()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!

    // MARK: - * LifeCycles --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearances()
        setupSearchController()
        setupTableView()
        
        self.setupDataSource()
        self.setupRx()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearRelay.accept(())
    }
    
    // MARK: - * Initialize --------------------
    private func setupAppearances() {
        title = "Search"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .systemBackground
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
    }

    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "App Store"
        
        searchController.obscuresBackgroundDuringPresentation = true
    }
    
    private func setupTableView() {
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
        
        tableView.sectionHeaderHeight = Metric.sectionHeaderHeight
        tableView.rowHeight = Metric.tableRowHeight
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    }
    
    private func setupDataSource() {
        let configureCell: TermDataSource.ConfigureCell = { (dataSource, tableView, indexPath, item) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") else {
                return .init()
            }
            cell.textLabel?.text = item
            cell.textLabel?.textColor = .blue
            return cell
        }
        
        let titleForHeaderInSection: TermDataSource.TitleForHeaderInSection = { (dataSource, section) in
            return dataSource.sectionModels[section].header
        }

        self.dataSource = .init(animationConfiguration: .init(reloadAnimation: .fade), configureCell: configureCell, titleForHeaderInSection: titleForHeaderInSection)
    }
    
    private func setupRx() {
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .do(onNext: { [weak self] ip, term in  //TODO: refactor to bind curry
                self?.tableView.deselectRow(at: ip, animated: true)

                self?.searchController.isActive = true
                self?.searchController.searchBar.text = term
            })
            .map { $0.1 }
            .bind(to: searchRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - * Binding --------------------
    private func bindViewModel() {
        
        let cancelSearch = searchController.searchBar.rx.cancelButtonClicked.asObservable()
        let fetchTerms = Observable.merge(viewWillAppearRelay.asObservable(), cancelSearch)
        
        let input = ViewModelType.Input(fetchTerms: fetchTerms,
                                        matchTerm: termRelay.asObservable().unwrap(),
                                        search: searchRelay.asObservable().unwrap(),
                                        cancelSearch: cancelSearch) //초기화
        let output = viewModel.transform(input: input)
        
        output.terms
            .map { [TermSectionModel(header: "최근 검색어", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.cancelSearch
            .drive(onNext: { [weak self] in
                self?.searchController.searchBar.resignFirstResponder()
            })
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

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return Validator.isValid(term: text) ? true : (range.length == 1 ? true : false)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //searchController.searchBar.text = ""
        return true
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        logD("updateSearchResults=\(searchController.searchBar.text ?? "")")
        termRelay.accept(searchController.searchBar.text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRelay.accept(searchController.searchBar.text)
    }
}

// MARK: - * Metric --------------------
extension SearchViewController {
    struct Metric {
        static let sectionHeaderHeight: CGFloat = 80
        static let tableRowHeight: CGFloat = 44
    }
}


extension Reactive where Base: SearchViewController {
    var deselectRow: Binder<IndexPath> {
        return Binder(self.base) { (view, value) in
            view.tableView.deselectRow(at: value, animated: true)
        }
    }
}
