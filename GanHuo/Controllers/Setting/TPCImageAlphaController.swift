//
//  TPCImageAlphaController.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class TPCImageAlphaController: TPCViewController {
    @IBOutlet weak var alphaSlideView: UISlider! {
        didSet {
            alphaSlideView.addTarget(self, action: #selector(TPCImageAlphaController.alphaDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
            alphaSlideView.value = TPCConfiguration.imageAlpha
        }
    }
    @IBOutlet weak var tipLabel: UILabel! {
        didSet {
            tipLabel.font = UIFont(name: TPCConfiguration.themeSFontName, size: 16.0)
        }
    }
    @IBOutlet weak var ruleContainter: UIView! {
        didSet {
            ruleContainter.layer.shadowColor = UIColor.lightGrayColor().CGColor
            ruleContainter.layer.shadowRadius = 3
            ruleContainter.layer.shadowOpacity = 1
            ruleContainter.layer.shadowOffset = CGSize(width: 4, height: 4)
        }
    }
    @IBOutlet weak var alphaLabel: UILabel! {
        didSet {
            alphaLabel.font = TPCConfiguration.themeSFont
            alphaLabel.text = String(format: "透明度:%.02f", TPCConfiguration.imageAlpha)
        }
    }
    var callAction: ((item: Float) -> ())?
    var formatAlpha: String {
        return String(format: "透明度:%.02f", alphaSlideView.value)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ruleContainter.alpha = CGFloat(TPCConfiguration.imageAlpha)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        callAction?(item: alphaSlideView.value)
        postReloadTableView()
    }
    
    func alphaDidChange(sender: UISlider) {
        alphaLabel.text = formatAlpha
        ruleContainter.alpha = CGFloat(sender.value)
    }
}
