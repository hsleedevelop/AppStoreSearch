//
//  AppDetailHeaderTableViewCell.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Cosmos

final class AppDetailHeaderTableViewCell: UITableViewCell, AppPresentable {

    //MARK: * properties --------------------
    var app: SearchResultApp?
    private var disposeBag = DisposeBag()


    //MARK: * IBOutlets --------------------
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.cornerRadius = 25.0
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView! {
        didSet {
            ratingView.backgroundColor = .clear
            ratingView.settings.fillMode = .precise
            ratingView.settings.starSize = 20.0
            ratingView.settings.starMargin = 2.0
            
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
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var advisoryLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
        
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    //MARK: * Binding --------------------
    func configure(_ app: SearchResultApp) {
        self.app = app
        
        nameLabel.text = name
        sellerLabel.text = artistName
        genreLabel.text = genre
        ratingView.rating = rating
        ratingCountLabel.text = ratingCount + " Ratings"
        ratingLabel.text = ratingText
        rankLabel.text = "100" //제공안함.
        advisoryLabel.text = contentAdvisoryRating
        
        ImageProvider.shared.get(iconUrl)
            .asDriverOnErrorJustComplete()
            .drive(iconImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

