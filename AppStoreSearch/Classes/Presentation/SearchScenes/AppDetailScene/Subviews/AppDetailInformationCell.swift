//
//  AppDetailInformationCell.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AppDetailInformationCell: UITableViewCell {//, AppPresentable {

    //MARK: * properties --------------------
    var disposeBag = DisposeBag()   //URL 오픈 시 사용할 수도..
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    //MARK: * Binding --------------------
    func configure(_ info: AppInformationType) {
        subjectLabel.text = info.subject
        contentLabel.text = info.content
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
