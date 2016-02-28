//
//  TPCApplicationTitleView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/21.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCApplicationTitleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 0.7))
        mainLabel.text = "幹貨"
        mainLabel.textAlignment = NSTextAlignment.Center
        mainLabel.font = UIFont(name: UIFont.hiraMinProNW3Name(), size: 22.0)
        addSubview(mainLabel)
        
        let detailLabel = UILabel(frame: CGRect(x: 0, y: mainLabel.frame.maxY - frame.height * 0.1, width: frame.width, height: frame.height * 0.3))
        detailLabel.text = "g a n h u o"
        detailLabel.textAlignment = NSTextAlignment.Center
        detailLabel.font = UIFont(name: UIFont.hiraMinProNW3Name(), size: 8.0)
        addSubview(detailLabel)
        layer.saveImageWithName("ganhuo")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
