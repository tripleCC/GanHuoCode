//
//  TPCGradientLabel.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCGradientLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(image: UIImage(named: "layer"))
        imageView.frame = bounds
        insertSubview(imageView, atIndex: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 透明层即使覆盖再label上面，还是有突出效果
        let imageView = UIImageView(image: UIImage(named: "layer"))
        imageView.frame = bounds
        insertSubview(imageView, atIndex: 0)
        
        // UIImageView > CALayer.content ~ CAGradientLayer
        //        let shadowLayer = CALayer()
        //        shadowLayer.bounds = bounds
        //        shadowLayer.contents = UIImage(named: "layer")?.CGImage
        //        layer.insertSublayer(shadowLayer, atIndex: 0)
    }
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor];
        gradientLayer.opacity = 0.5
        gradientLayer.frame = self.bounds
        gradientLayer.saveImageWithName("layer")
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override var text: String? {
        didSet {
//            self.layer.sublayers?.first?.opacity = 0.5
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.first?.frame = self.bounds
    }
}
