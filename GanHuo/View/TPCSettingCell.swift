//
//  TPCSettingCell.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCSettingCell: UITableViewCell {
    var setItem: TPCSetItem? {
        didSet {
            if let setItem = setItem {
                accessoryType = setItem.accessoryType
                textLabel?.text = setItem.title
                textLabel?.textAlignment = setItem.textAlignment
                detailTextLabel?.text = setItem.detailTitle
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        textLabel?.font = TPCConfiguration.settingCellLableFont
        textLabel?.textColor = UIColor.grayColor()
        detailTextLabel?.font = TPCConfiguration.settingCellLableFont
        detailTextLabel?.textColor = UIColor.lightGrayColor()
        selectionStyle = .Gray
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
