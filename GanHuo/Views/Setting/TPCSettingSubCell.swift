//
//  TPCSettingSubCell.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCSettingSubCell: UITableViewCell {

    @IBOutlet weak var selectedButton: TPCSystemButton! {
        didSet {
            selectedButton.userInteractionEnabled = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textLabel?.font = TPCConfiguration.settingCellLableFont
        textLabel?.textColor = UIColor.grayColor()
        textLabel?.backgroundColor = UIColor.clearColor()
        selectionStyle = .None
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
