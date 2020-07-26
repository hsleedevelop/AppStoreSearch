//
//  ScreenshotsViewController.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ScreenshotsViewController: UIViewController {
    // MARK: - * Type defines --------------------
    typealias ViewModelType = ScreenshotsViewModel
    
    enum SwipeDirection {
        case left, right
    }

    // MARK: - * Dependencies --------------------
    var viewModel: ViewModelType!
    
    // MARK: - * Properties --------------------
    private let disposeBag = DisposeBag()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: - * Life Cycles --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupCollectionView()
        updateCollectionViewLayout()
        
        bindViewModel()
    }
    
    // MARK: - * Initialize --------------------
    private func setupAppearance() {
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(closeButtonTouched))
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.isPagingEnabled = false
        
        collectionView.decelerationRate = .fast
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(.init(nibName: "ScreenshotsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ScreenshotsCollectionViewCell")
    }
    
    private func updateCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = CoverFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Metric.collectonViewLineSpacing
        layout.minimumInteritemSpacing = 0

        layout.sectionInset = UIEdgeInsets(top: 0, left: Metric.collectonViewMargin, bottom: 0, right: Metric.collectonViewMargin)
        
        let width = UIScreen.main.bounds.size.width - (Metric.collectonViewMargin * 4)
        let height = self.view.frame.height - 88 - 31 - 10 //navigationBar Height, Home Indicator Height, Margin
        layout.itemSize = CGSize(width: width, height: height)
        
        collectionView?.collectionViewLayout = layout
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(input: .init())
        
        output.screenshotURLsWithIndex
            .do(afterNext: { [weak self] item in
                DispatchQueue.main.async {
                    self?.collectionView.scrollToItem(at: .init(item: item.1, section: 0), at: .centeredHorizontally, animated: false)
                }
            })
            .map { $0.0 }
            .drive(collectionView.rx.items)  ({ (cv, item, screenshot) -> UICollectionViewCell in
                let indexPath = IndexPath(item: item, section: 0)
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "ScreenshotsCollectionViewCell", for: indexPath) as? ScreenshotsCollectionViewCell else {
                    return .init()
                }
                cell.configure(screenshot, index: 0)
                return cell
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - * UI Action --------------------
    @objc private func closeButtonTouched() {
        viewModel.coordinatorRelay.accept(.dismiss)
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
extension ScreenshotsViewController {
    struct Metric {
        static let collectonViewMargin: CGFloat = 20
        static let collectonViewLineSpacing: CGFloat = 20
    }
}


//https://stackoverflow.com/a/49617263/3374327
final class CoverFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            return latestOffset
        }

        // Page width used for estimating and calculating paging.
        let pageWidth = self.itemSize.width + (self.minimumLineSpacing / 2)

        // Make an estimation of the current page position.
        let approximatePage = collectionView.contentOffset.x / pageWidth

        // Determine the current page based on velocity.
        let currentPage = velocity.x == 0 ? round(approximatePage) : (velocity.x < 0.0 ? floor(approximatePage) : ceil(approximatePage))

        // Create custom flickVelocity.
        let flickVelocity = velocity.x * 0.3

        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)

        // Calculate newHorizontalOffset.
        let newHorizontalOffset = ((currentPage + flickedPages) * pageWidth) - collectionView.contentInset.left

        return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
    }
}
