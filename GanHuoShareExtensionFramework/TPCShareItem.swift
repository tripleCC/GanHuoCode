//
//  TPCShareItem.swift
//  TPCShareextension
//
//  Created by tripleCC on 16/4/12.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

public enum TPCShareItemType: Int {
    case Input
    case Display
}

public class TPCShareItem {
    var placeholder: String!
    var content: String!
    var contentImage: UIImage!
    var clickAction: ((String) -> Void)?
    var type: TPCShareItemType!
    
    init(placeholder: String = "", content: String? = "", contentImage: UIImage, type: TPCShareItemType = .Input, clickAction: ((String) -> Void)? = nil) {
        self.placeholder = placeholder
        self.content = content
        self.contentImage = contentImage
        self.type = type
        self.clickAction = clickAction
    }
}