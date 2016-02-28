//
//  TPCDetailViewCell.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCDetailViewCell: UITableViewCell {

    var technical: TPCTechnicalObject? {
        didSet {
            if let technical = technical {
                let attributedDescString = NSAttributedString(string: "•  " +  "\(technical.desc!)", attributes: [NSForegroundColorAttributeName : UIColor.darkGrayColor()])
                let attributedWhoString = NSAttributedString(string: " (via.\(technical.who!))", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
                let attributedText = NSMutableAttributedString(attributedString: attributedDescString)
                attributedText.appendAttributedString(attributedWhoString)
                contentLabel.attributedText = attributedText
            }
        }
    }
    
    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.font = TPCConfiguration.themeSFont
        contentLabel.textColor = UIColor.grayColor()
        contentLabel.numberOfLines = 0
        return contentLabel
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(contentLabel)
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.frame = contentView.bounds
    }

}
