//
//  TPCSelectHeaderView.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/1.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

let kTitleButtonMaxVisibleCount: CGFloat = 5

protocol TPCSelectHeaderViewDelegate : class {
    func selectHeaderView(view: TPCSelectHeaderView, didSelectButton button: UIButton)
}

class TPCSelectHeaderView: UIView {
    var titles: [String]! {
        didSet {
            addButtonItems()
        }
    }
    var contentSize: CGSize {
        return scrollView.contentSize
    }
    var contentOffset: CGPoint {
        set {
            scrollView.setContentOffset(newValue, animated: true)
        }
        get {
            return scrollView.contentOffset
        }
    }
    weak var delegate: TPCSelectHeaderViewDelegate?
    var disabledButton: UIButton? {
        didSet {
            if oldValue != nil {
                oldValue!.enabled = true
                disabledButton!.enabled = false
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.indicatorView.frame.size.width = self.disabledButton!.titleLabel!.frame.size.width
                    self.indicatorView.center.x = self.disabledButton!.center.x
                })
            } else {
                disabledButton!.enabled = false
            }
            
        }
    }
    private var titleButtons = [UIButton]()
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGrayColor()
        return view
    }()
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(self.indicatorView)
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    override init(frame: CGRect) {
       super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(scrollView)
    }
    
    private func addButtonItems() {
        for title in titles {
            let button = UIButton(type: .Custom)
            button.contentMode = .Center
            button.titleLabel?.textAlignment = .Center
            button.titleLabel?.font = TPCConfiguration.themeSFont
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Disabled)
            button.addTarget(self, action: "titleButtonOnClicked:", forControlEvents: .TouchUpInside)
            button.backgroundColor = UIColor.clearColor()
            scrollView.addSubview(button)
            titleButtons.append(button)
            print(title)
        }
        disabledButton = titleButtons.first
    }

    func setupSubviewsFrame() {
        scrollView.frame = bounds
        indicatorView.frame.size.height = 1.5
        indicatorView.frame.origin.y = scrollView.bounds.height - indicatorView.frame.height
        let buttonW = scrollView.frame.size.width / kTitleButtonMaxVisibleCount
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
    
    func centerXOfButtonIndex(index: Int) -> CGFloat {
        return titleButtons[index].center.x
    }
    
    func setDisabledButtonWithButtonIndex(index: Int) {
        disabledButton = titleButtons[index]
    }
    
    func titleButtonOnClicked(sender: UIButton) {
        delegate?.selectHeaderView(self, didSelectButton: sender)
    }
}
