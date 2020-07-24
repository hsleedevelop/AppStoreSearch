//
//  String+Extensions.swift
//  SearchAppstore
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 IRIVER LIMITED. All rights reserved.
//

import UIKit

extension String {
    
    /// 스트링 레인지를 정수 배열로 전달
    func indicesOf(string: String, options: String.CompareOptions = .caseInsensitive) -> [Int] {
        var indices = [Int]()
        var sIndex = self.startIndex
        
        while sIndex < self.endIndex,
            let range = self.range(of: string, options: options, range: sIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            sIndex = range.upperBound
        }
        
        return indices
    }
    
    /// 스트링의 레이블 적용시 라인수
    func lineCount(pointSize: CGFloat, weight: UIFont.Weight = .regular, fixedWidth: CGFloat = UIScreen.main.bounds.width) -> Int {
        guard self.isEmpty == false else {
            return 1
        }
        
        // 주어진 폰트에 대한 height를 구함.
        var lineCount = 0
        
        let tmpString = self as NSString
        let context = NSStringDrawingContext()
        
        let labelSize = CGSize(width: fixedWidth, height: 100000)
        
        let font = UIFont.systemFont(ofSize: pointSize, weight: weight)
        let r = tmpString.boundingRect(with: labelSize,
                                       options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                       attributes:[NSAttributedString.Key.font: font], context: context)
        
        // 라인 계산
        let charSize = font.lineHeight
        let rHeight = r.size.height
        lineCount = Int(rHeight / charSize)
        
        return lineCount
    }
}

