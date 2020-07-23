//
//  MatchesViewController.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/23.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import UIKit

class MatchesViewController: UIViewController {

    // MARK: - * properties --------------------


    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    

    // MARK: - * Initialize --------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAppearances()
        self.setupUI()
        self.prepareViewDidLoad()
    }


    private func setupAppearances() {

    }


    private func setupUI() {

    }


    func prepareViewDidLoad() {

    }

    // MARK: - * Main Logic --------------------


    // MARK: - * UI Events --------------------


    // MARK: - * Memory Manage --------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        #if DEBUG
        print("\(NSStringFromClass(type(of: self))) deinit")
        #endif
    }
}


extension MatchesViewController {

}
