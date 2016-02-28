//
//  TPCDetailHeaderView.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCDetailHeaderView: UITableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = TPCConfiguration.themeBFont
        titleLabel.textColor = UIColor.darkGrayColor()
        return titleLabel
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()
        return containerView
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = "  \(title!)"
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        containerView.addSubview(titleLabel)
        addSubview(containerView)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = contentView.bounds
        titleLabel.frame = containerView.bounds
    }
}
