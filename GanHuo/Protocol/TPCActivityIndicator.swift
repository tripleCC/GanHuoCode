//
//  TPCRefresh.swift
//  GanHuo
//
//  Created by tripleCC on 16/1/23.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

public protocol TPCActivityIndicator {
    func addAnimation()
    func removeAnimation()
    func endForAnimation()
    func addLayersWithSize(size: CGSize, tintColor: UIColor)
    func prepareForAnimationWithScale(var scale: CGFloat)
}
