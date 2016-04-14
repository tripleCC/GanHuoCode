//
//  TPCShareViewTableViewCell.swift
//  TPCShareextension
//
//  Created by tripleCC on 16/4/12.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

public class TPCShareViewCell: UITableViewCell {

    var editCallBack: ((String) -> Void)?
    var item: TPCShareItem! {
        didSet {
            contentImageView.image = item.contentImage
            if item.type == .Display {
                inputTextField.hidden = true
                displayLabel.text = item.content
            } else {
                inputTextField.placeholder = item.placeholder
                inputTextField.hidden = false
                inputTextField.text = item.content
            }
            displayLabel.hidden = !inputTextField.hidden
        }
    }
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBAction func inputTextFieldChanged(sender: AnyObject) {
        if let content = inputTextField.text {
            editCallBack?(content)
        }
    }
    
    func beEditing() {
        if !inputTextField.hidden {
            inputTextField.becomeFirstResponder()
        } else {
            superview?.endEditing(true)
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
