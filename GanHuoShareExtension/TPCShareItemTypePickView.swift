//
//  TPCShareItemTypePickView.swift
//  TPCShareextension
//
//  Created by tripleCC on 16/4/12.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

public class TPCShareItemTypePickView: UIView {
    var typesTitle: [String]! {
        didSet {
            pickView.reloadAllComponents()
            pickView.layoutIfNeeded()
        }
    }
    var selectedTitle: String {
        return typesTitle[pickView.selectedRowInComponent(0)]
    }
    private var pickView: UIPickerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        pickView = UIPickerView()
        pickView.delegate = self
        pickView.dataSource = self
        addSubview(pickView)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        pickView.frame = bounds
    }
}

extension TPCShareItemTypePickView: UIPickerViewDelegate {
    
    public func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes = [NSFontAttributeName : UIFont.systemFontOfSize(16),
                          NSForegroundColorAttributeName : UIColor.blackColor()]
        let string = NSAttributedString(string: typesTitle[row], attributes: attributes)
        return string
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}

extension TPCShareItemTypePickView: UIPickerViewDataSource {
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typesTitle.count
    }
}