//
//  TPCLinkButton.swift
//  GanHuo
//
//  Created by tripleCC on 15/12/24.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCLinkButton: UIButton {
    @IBInspectable var title: String?
    @IBInspectable var link: String?
    
    private var bottomLayer: CALayer!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContents()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContents()
    }
    
    init(title: String, link: String) {
        super.init(frame: CGRectZero)
        self.title = title
        self.link = link
    }
    
    private func setupContents() {
        titleLabel?.font = UIFont(name: TPCConfiguration.themeSFontName, size: TPCConfiguration.themeCellBFontSize)
        setTitleColor(TPCConfiguration.themeTextColor, forState: .Normal)
        
        bottomLayer = CALayer()
        bottomLayer.backgroundColor = TPCConfiguration.themeTextColor.CGColor
        layer.addSublayer(bottomLayer)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomLayer.frame = CGRect(x: 2, y: bounds.height - 7, width: bounds.width - 2, height: 0.5)
    }
}
