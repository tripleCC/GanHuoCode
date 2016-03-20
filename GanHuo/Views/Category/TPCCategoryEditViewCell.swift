//
//  TPCCategoryEditViewCell.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/17.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCCategoryEditViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel! {
        didSet {
            categoryLabel.font = UIFont(name: UIFont.avenirBookFontName(), size: TPCConfiguration.themeCellBFontSize)
            categoryLabel.textColor = UIColor.grayColor()
        }
    }
    
    @IBOutlet weak var selectButton: TPCSystemButton!
    var enable: Bool = false {
        didSet {
            selectButton.enable = enable
        }
    }
    var type: TPCCategoryEditType! {
        didSet {
            selectButton.hidden = type == .Edit
        }
    }
}
