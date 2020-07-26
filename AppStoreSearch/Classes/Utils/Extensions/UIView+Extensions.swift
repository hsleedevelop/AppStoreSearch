//
//  UIView+Extensions.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 3, height: 3)
            layer.shadowOpacity = 0.4
            //layer.shadowRadius = shadowRadius
        }
    }
}

extension UIView {
    /// 해당하는 constraint를 찾아 반환함.
    func getConstraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        //first, find on super
        var constraint = superview?.constraints.filter({ $0.firstItem === self && $0.firstAttribute == attribute }).first
        constraint = constraint == nil ? superview?.constraints.filter({ $0.secondItem === self && $0.secondAttribute == attribute }).first : constraint
        
        //second, find on self
        constraint = constraint == nil ? self.constraints.reversed().filter({ $0.firstItem === self && $0.firstAttribute == attribute }).first : constraint
        return constraint
    }
    
    /// 현재 뷰의 뷰컨트롤러 인스턴스
    var parentViewControllerOfSelf: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
