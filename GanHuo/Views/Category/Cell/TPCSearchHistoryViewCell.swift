//
//  TPCSearchHistoryViewCell.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/20.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCSearchHistoryViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel! {
        didSet {
            contentLabel.font = UIFont(name: UIFont.avenirBookFontName(), size: TPCConfiguration.themeCellBFontSize)
            contentLabel.textColor = UIColor.grayColor()
            contentLabel.numberOfLines = 0
        }
    }
    
    var closeAction: ((String) -> Void)?
    
    
    var history: String? {
        didSet {
            if let history = history {
                contentLabel.text = history
            }
        }
    }
    @IBAction func closeButtonOnClicked(sender: AnyObject) {
        if let history = history {
            closeAction?(history)
        }
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
