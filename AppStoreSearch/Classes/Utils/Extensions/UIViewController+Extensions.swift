//
//  UIViewController+Extensions.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit

extension UIViewController {
    func addChild(_ parent: UIViewController, _ child: UIViewController) {
        guard child.parent == nil else { return }
        
        parent.children.first?.removeFromParent()
        
        parent.addChild(child)
        parent.view.addSubview(child.view)
        
        child.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
        child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
        child.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
        child.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true
        
        child.didMove(toParent: parent)
    }
}
