//
//  TPCLoadMoreReusableView.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/4.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCLoadMoreReusableView: UICollectionReusableView {
    lazy var noMoreDataFooterView: TPCNoMoreDataFooterView = {
        return TPCNoMoreDataFooterView.noMoreDataFooterView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(noMoreDataFooterView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(noMoreDataFooterView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        noMoreDataFooterView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
}
