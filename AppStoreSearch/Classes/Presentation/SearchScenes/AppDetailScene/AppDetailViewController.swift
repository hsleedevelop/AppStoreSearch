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
    private var disposeBag = DisposeBag()
    
    private var whatNewMoreRelay = BehaviorRelay<Bool>(value: false)
    private var screenshotRelay = PublishRelay<([String], Int)>()
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

        setupTableView()
        setupDataSource()
        setupRx()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         navigationController?.navigationBar.prefersLargeTitles = false
         navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         navigationController?.navigationBar.prefersLargeTitles = true
         navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
     }

    // MARK: - * Initialize --------------------
    private func setupTableView() {
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
    
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension //max height for what's new and description
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.register(.init(nibName: "AppDetailHeaderTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AppDetailHeaderTableViewCell")
        tableView.register(.init(nibName: "AppDetailWhatsNewTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AppDetailWhatsNewTableViewCell")
        tableView.register(.init(nibName: "AppDetailScreenshotsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AppDetailScreenshotsTableViewCell")
        tableView.register(.init(nibName: "AppDetailDescriptionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AppDetailDescriptionTableViewCell")
        tableView.register(.init(nibName: "AppDetailInformationCell", bundle: Bundle.main), forCellReuseIdentifier: "AppDetailInformationCell")
    }
    
    private func setupDataSource() {
        let configureCell: AppDetailDataSource.ConfigureCell = { [weak self] (dataSource, tableView, indexPath, rowItem) in
            guard dataSource.sectionModels.indices.contains(indexPath.section), let self = self else { return .init() }
            
            var cell: UITableViewCell?
            
            switch rowItem {
            case let .header(item):
                if let tcell = tableView.dequeueReusableCell(withIdentifier: "AppDetailHeaderTableViewCell") as? AppDetailHeaderTableViewCell {
                    tcell.configure(item)
                    cell = tcell
                }
            case let .whatsNew(item):
                if let tcell = tableView.dequeueReusableCell(withIdentifier: "AppDetailWhatsNewTableViewCell") as? AppDetailWhatsNewTableViewCell {
                    tcell.configure(item)
                    tcell.rx.moreClicked //observe more sequence
                        .drive(self.whatNewMoreRelay)
                        .disposed(by: tcell.disposeBag)
                    
                    cell = tcell
                }
            case let .preview(item):
                if let tcell = tableView.dequeueReusableCell(withIdentifier: "AppDetailScreenshotsTableViewCell") as? AppDetailScreenshotsTableViewCell {
                    tcell.configure(item)
                    tcell.rx.screenshopPressed
                        .map { AppDetailCoordinator.Flow.showScreenshots($0.0, $0.1) }
                        .bind(to: self.viewModel.flowRelay)
                        .disposed(by: tcell.disposeBag)
                    
                    cell = tcell
                }
            case let .description(item):
                if let tcell = tableView.dequeueReusableCell(withIdentifier: "AppDetailDescriptionTableViewCell") as? AppDetailDescriptionTableViewCell {
                    tcell.configure(item)
                    tcell.rx.moreClicked //observe more sequence
                        .drive(self.descriptionMoreRelay)
                        .disposed(by: tcell.disposeBag)
                    
                    cell = tcell
                }
            case let .information(item):
                if let tcell = tableView.dequeueReusableCell(withIdentifier: "AppDetailInformationCell") as? AppDetailInformationCell {
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
        navigationController?.rx.willShow.asObservable()
            .filter { $0.viewController is SearchViewController }
            .map { _ in .popup }
            .bind(to: viewModel.flowRelay)
            .disposed(by: disposeBag)
        
        Driver.merge(whatNewMoreRelay.asDriver(),
                     descriptionMoreRelay.asDriver())
        .drive(onNext: { [weak self] _ in
            self?.tableView.reloadData()
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
    }

    // MARK: - * Memory Manage --------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension AppDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        func nestedCalculateHeight(_ text: String, topMargin top: CGFloat) -> CGFloat {
            
            let width = UIScreen.main.bounds.size.width - 20 - 20 //label left, right margin
            var numberOfLines = text.lineCount(pointSize: 16, fixedWidth: width) //lineHeight == 16
            let adjustHeight: CGFloat = numberOfLines > 3 ? 5 + 28 : 0
            
            numberOfLines = numberOfLines > 3 ? 3 : numberOfLines
            return top + CGFloat(numberOfLines * 16) + adjustHeight + 20 //top margin + label height + bottom margin + button height + bottom margin
        }
        
        let section = dataSource.sectionModels[indexPath.section].items[indexPath.row]
        switch section {
        case .header:
            return 220
        case .preview:
            let adjustHeight: CGFloat = 20 + 20 + 20 + 20 //top margin + header label + label margin + bottom margin
            return Metric.screenshotRowHeight + adjustHeight
        case .whatsNew:
            if whatNewMoreRelay.value == false {
                return nestedCalculateHeight(releaseNotes, topMargin: 80)
            }
            return UITableView.automaticDimension
        case .description:
            if descriptionMoreRelay.value == false {
                return nestedCalculateHeight(appDescription, topMargin: 20)
            }
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
}



// MARK: - * Metric --------------------
extension AppDetailViewController {
    struct Metric {
        static let screenshotRowHeight: CGFloat = 300
    }
}
