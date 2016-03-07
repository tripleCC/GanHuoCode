//
//  TPCCategoryViewCell.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/5.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCategoryViewCell: UITableViewCell {
    var ganhuo: GanHuoObject! {
        didSet {
            contentLabel.text = ganhuo.desc
            readedView.readed = ganhuo.read?.boolValue ?? false
        }
    }
    @IBOutlet weak var readedView: TPCMarkReadView!
    @IBOutlet weak var contentLabel: UILabel! {
        didSet {
            contentLabel.font = UIFont(name: UIFont.avenirBookFontName(), size: TPCConfiguration.themeCellBFontSize)
            contentLabel.textColor = UIColor.grayColor()
            contentLabel.numberOfLines = 0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        contentView.backgroundColor = UIColor.randomColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
