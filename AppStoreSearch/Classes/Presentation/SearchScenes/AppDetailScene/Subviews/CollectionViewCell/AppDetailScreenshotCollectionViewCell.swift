//
//  AppDetailScreenshotCollectionViewCell.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class AppDetailScreenshotCollectionViewCell: UICollectionViewCell {

    //MARK: * properties --------------------
    var screenshotURL: String?
    var index: Int?
    
    var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.isAccessibilityElement = true
    }
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var screenshotImageView: UIImageView! {
        didSet {
            screenshotImageView.accessibilityIdentifier = "screenshotImageView"
            screenshotImageView.cornerRadius = 10
            screenshotImageView.borderColor = .lightGray
            screenshotImageView.borderWidth = 0.5
            screenshotImageView.contentMode = .scaleAspectFill
        }
    }
    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        screenshotImageView.image = nil
    }

    //MARK: * Binding --------------------
    func configure(_ screenshotURL: String, index: Int) {
        self.screenshotURL = screenshotURL
        self.index = index
        
        bindRx()
    }
    
    private func bindRx() {
        guard let screenshotURL = screenshotURL else {
            return
        }
        
        ImageProvider.shared.get(screenshotURL)
            .asDriverOnErrorJustComplete()
            .drive(self.screenshotImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension Reactive where Base: AppDetailScreenshotCollectionViewCell {
    var screenshotPressed: Observable<Int> {
        guard let sequence = base.index.map(base.screenshotImageView.rx.tapGesture().when(.recognized).mapTo) else {
            return .empty()
        }
        return sequence
    }
}
