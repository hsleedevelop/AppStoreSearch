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
    
    private lazy var searchController: UISearchController = {
        return UISearchController(searchResultsController: resultViewController)
    }()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    

    // MARK: - * LifeCycles --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearances()
        setupSearchController()
        setupTableView()
        
        setupDataSource()
        setupRx()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearRelay.accept(())
    }
    
    // MARK: - * Initialize --------------------
    private func setupAppearances() {
        title = "Search"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        
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
        tableView.backgroundColor = .white
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
        //검색어 입력
//        searchController.searchBar.rx.text.orEmpty
//            .filter { [unowned self] in !$0.isEmpty && self.searchController.searchBar.isFirstResponder }
//            .distinctUntilChanged()
//            .bind(to: termRelay)
//            .disposed(by: disposeBag)

        //검색 클릭 시
//        searchController.searchBar.rx.searchButtonClicked
//            .map ({ [unowned self] in
//                self.searchController.searchBar.text ?? ""
//            })
//            .bind(to: searchRelay)
//            .disposed(by: disposeBag)

        //검색 캔슬, 검색 입력 종료 시
//        Observable.merge(searchController.searchBar.rx.cancelButtonClicked.map { _ in true },
//                         searchController.searchBar.rx.textDidEndEditing.map { _ in false },
//                         searchController.searchBar.rx.text.orEmpty.map {_ in false }) //검색 시 메인 리스트 바로 갱신하기 위해 추가,
//        Observable.merge(searchController.searchBar.rx.cancelButtonClicked.map { _ in true }) //검색 시 메인 리스트 바로 갱신하기 위해 추가,
////            .throttle(1.2, latest: false, scheduler: MainScheduler.instance) //캔슬버튼, 텍스트 종료 이벤트가 약간의 딜레이로 들어옴.
////            .do(onNext: { [unowned self] _ in
////                self.viewReloadRelay.accept(())
////            })
//            .filter { $0 } //차일드 뷰 날릴 지 여부
//            .map {  }
//            .bind(to: viewModel.flowRelay)
//            .disposed(by: disposeBag)
//

//        tableView.rx.itemSelected
//            .do(onNext: { [weak self] ip in
//                self?.rx.deselectRow.onNext(ip)
//                self?.searchController.isActive = true
//            })
//            .map { [unowned self] in self.dataSource.sectionModels[$0.section].items[$0.row] }
//            .subscribe(onNext: { [weak self] in
//                self?.searchRelay.accept($0)
//            })
//            .disposed(by: disposeBag)

        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .do(onNext: { [weak self] ip, term in  //TODO: refactor to bind curry
                //self?.searchController.isActive = true
                self?.tableView.deselectRow(at: ip, animated: true)
                self?.searchController.searchBar.becomeFirstResponder()
                self?.searchController.searchBar.text = term
            })
            .map { $0.1 }
            .bind(to: searchRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - * Binding --------------------
    
    private func bindViewModel() {
        
        let searchCancel = searchController.searchBar.rx.cancelButtonClicked.asObservable()
        let fetchTerms = Observable.merge(viewWillAppearRelay.asObservable(), searchCancel)
        
        let input = ViewModelType.Input(fetchTerms: fetchTerms,
                                        term: termRelay.asObservable().unwrap(),
                                        search: searchRelay.asObservable().unwrap(),
                                        searchCancel: searchCancel) //초기화
        let output = viewModel.transform(input: input)
        
        output.terms
            .map { [TermSectionModel(header: "최근 검색어", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        //output1 = history matching
//        output.matches
//            .map { [unowned self] in (FlowCoordinator.Step.matches(self.termRelay.value, $0, self.searchRelay), self.resultVc) }
//            .drive(FlowCoordinator.shared.rx.flow)
//            .disposed(by: disposeBag)
        
        //output2 - fetch and push
//        searchRelay.asObservable()
//            .do(onNext: { [unowned self] in
//                self.searchController.searchBar.text = $0
//                self.searchController.searchBar.resignFirstResponder()
//            })
//            .filter { !$0.isEmpty }
//            .delay(0.01, scheduler: MainScheduler.instance)
//
//            .map { [unowned self] in (FlowCoordinator.Step.appList($0), self.resultVc) }
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

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return Validator.isValid(term: text) ? true : (range.length == 1 ? true : false)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.text = ""
        return true
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        logD("updateSearchResults=\(searchController.searchBar.text ?? "")")
        termRelay.accept(searchController.searchBar.text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRelay.accept(self.searchController.searchBar.text)
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
