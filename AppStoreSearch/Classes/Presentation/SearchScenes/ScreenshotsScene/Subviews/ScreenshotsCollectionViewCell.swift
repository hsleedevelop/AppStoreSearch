//
//  ScreenshotsCollectionViewCell.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/25.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

///Common CollectionView
final class ScreenshotsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - * Properties --------------------
    private var screenshotURL: String!
    private var disposeBag = DisposeBag()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - * Initialize --------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        imageView.image = nil
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = false
    }
    
    //MARK: * Binding --------------------
    func configure(_ screenshotURL: String, index: Int) {
        self.screenshotURL = screenshotURL

        bindRx()
    }
    
    private func bindRx() {
        guard let screenshotURL = screenshotURL else {
            return
        }
        
        ImageProvider.shared.get(screenshotURL)
            .asDriverOnErrorJustComplete()
            .drive(self.imageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
