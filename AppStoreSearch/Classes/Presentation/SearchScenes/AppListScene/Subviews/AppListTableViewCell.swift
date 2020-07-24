//
//  AppListTableViewCell.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Cosmos

final class AppListTableViewCell: UITableViewCell, AppPresentable {

    //MARK: * properties --------------------
    var app: SearchResultApp?
    private var disposeBag = DisposeBag()

    //MARK: * IBOutlets --------------------
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.cornerRadius = 15.0
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel! {
        didSet {
            genreLabel.textColor = .gray
        }
    }
    @IBOutlet weak var ratingView: CosmosView! {
        didSet {
            ratingView.backgroundColor = .clear
            ratingView.settings.fillMode = .precise
            ratingView.settings.starSize = 14.0
            ratingView.settings.starMargin = 1.0
            
            ratingView.settings.updateOnTouch = false
            
            ratingView.settings.filledColor = .gray
            ratingView.settings.emptyBorderColor = .gray
            ratingView.settings.filledBorderColor = .gray
        }
    }
    @IBOutlet weak var getButton: UIButton! {
        didSet {
            getButton.cornerRadius = 15
        }
    }
    
    @IBOutlet var screenshotsImageViews: [UIImageView]! {
        didSet {
            screenshotsImageViews.forEach { imageView in
                imageView.cornerRadius = 10
                imageView.borderColor = .lightGray
                imageView.borderWidth = 0.5
                imageView.contentMode = .scaleAspectFill
            }
        }
    }

    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    //MARK: * Main Logic --------------------
    func configure(_ app: SearchResultApp) {
        self.app = app
        selectionStyle = .none
        
        nameLabel.text = name
        genreLabel.text = genre
        ratingView.rating = rating
        ratingView.text = ratingCount
        
        ImageProvider.shared.get(iconUrl)
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
        
        screenshotsImageViews.enumerated().forEach { offset, imageView in
            guard offset < (screenshotsUrls?.count ?? 0), let screenshotUrl = screenshotsUrls?[offset] else {
                imageView.isHidden = true
                return
            }
            
            ImageProvider.shared.get(screenshotUrl)
                .observeOn(MainScheduler.instance)
                .do(onNext: { [weak imageView] _ in
                    imageView?.isHidden = false
                    }, onError: { [weak imageView] error in
                        logW(error)
                        imageView?.isHidden = true
                })
                .bind(to: imageView.rx.image)
                .disposed(by: disposeBag)
        }
    }
}
