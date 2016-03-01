//
//  TPCSelectHeaderView.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/1.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

let kTitleButtonMaxVisibleCount: CGFloat = 5
class TPCSelectHeaderView: UIView {
    var titles: [String]! {
        didSet {
            addButtonItems()
            setupSubviewsFrame()
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.orangeColor()
        return view
    }()
    private var titleButtons = [UIButton]()
    private var disabledButton: UIButton! {
        didSet {
            disabledButton.enabled = false
        }
    }
    override init(frame: CGRect) {
       super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        scrollView.addSubview(indicatorView)
        
    }
    
    private func addButtonItems() {
        for title in titles {
            let button = UIButton(type: .Custom)
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.redColor(), forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Disabled)
            button.addTarget(self, action: "titleButtonOnClicked:", forControlEvents: .TouchUpInside)
            scrollView.addSubview(button)
            titleButtons.append(button)
        }
        disabledButton = titleButtons.first
    }

    func setupSubviewsFrame() {
        indicatorView.frame.size.height = 2.5
        indicatorView.frame.origin.y = scrollView.bounds.height - indicatorView.frame.height
        let buttonW = scrollView.bounds.size.width / kTitleButtonMaxVisibleCount
        let buttonH = scrollView.bounds.size.height
        for (idx, button) in titleButtons.enumerate() {
            button.frame.size = CGSize(width: buttonW, height: buttonH)
            button.frame.origin.x = CGFloat(idx) * buttonW
            if idx == 0 && disabledButton == button {
                button.titleLabel?.sizeToFit()
                indicatorView.frame.size.width = button.titleLabel!.frame.size.width
                indicatorView.center.x = button.center.x
            }
        }
        scrollView.contentSize = CGSize(width: CGFloat(titleButtons.count) * buttonW, height: 0)
    }
}
