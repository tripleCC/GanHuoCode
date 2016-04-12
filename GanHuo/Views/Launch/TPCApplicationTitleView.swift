//
//  TPCApplicationTitleView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/21.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCApplicationTitleView: UIView {
    private var mainLabel: UILabel!
    private var detailLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        mainLabel = UILabel()
        mainLabel.text = "幹貨"
        mainLabel.textAlignment = NSTextAlignment.Center
        mainLabel.font = UIFont(name: UIFont.hiraMinProNW3Name(), size: 22.0)
        addSubview(mainLabel)
        
        detailLabel = UILabel()
        detailLabel.text = "g a n h u o"
        detailLabel.textAlignment = NSTextAlignment.Center
        detailLabel.font = UIFont(name: UIFont.hiraMinProNW3Name(), size: 8.0)
        addSubview(detailLabel)
        layer.saveImageWithName("ganhuo")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 0.7)
        detailLabel.frame = CGRect(x: 0, y: mainLabel.frame.maxY - frame.height * 0.1, width: frame.width, height: frame.height * 0.3)
    }
}
