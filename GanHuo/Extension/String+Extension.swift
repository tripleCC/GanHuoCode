//
//  String+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/11/20.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

extension String {
    public func technicalCellLabelBoundingRect() -> CGRect {
        let str = self as NSString
        let attributes = [NSFontAttributeName : TPCConfiguration.technicalCellLabelFont!]
        return str.boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width, height: 10), options: NSStringDrawingOptions.UsesFontLeading, attributes: attributes, context: nil)
    }
    
    public func heightWithFont(font: UIFont, width: CGFloat) -> CGFloat {
        let str = self as NSString
        let attributes = [NSFontAttributeName : font]
        return str.boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil).size.height
    }
    
    public func ruleLabelBoundingRect() -> CGRect {
        let str = self as NSString
        let attributes = [NSFontAttributeName : TPCConfiguration.settingContentRuleLabelFont!]
        return str.boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width, height: 10), options: NSStringDrawingOptions.UsesFontLeading, attributes: attributes, context: nil)
    }
    
    public func getLoadDataNumber() -> Int {
        let index = self.endIndex.advancedBy(-"个妹子".length)
        let number = Int(self.substringToIndex(index))
        return number ?? 5
    }
}