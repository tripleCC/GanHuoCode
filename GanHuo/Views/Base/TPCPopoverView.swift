//
//  TPCPopoverView.swift
//  TPCPopoverView
//
//  Created by tripleCC on 15/11/16.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

let TPCPopViewDefaultCellHeight: CGFloat = 30.0
private let TPCPopViewDefaultFrame = CGRect(x: 0, y: 0, width: 100, height: 60)
private let TPCPopViewDefaultThemeColor = UIColor.whiteColor()
private let TPCPopViewDefaultFont = UIFont.systemFontOfSize(12)
private let TPCPopViewDefaultTextColor = UIColor.grayColor()
private let TPCPopViewDefaultBottomLineColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)

enum TPCPopoverViewFadeDirection {
    case LeftTop
    case RightTop
    case Center
}

@objc protocol TPCPopoverViewDataSource: NSObjectProtocol {
    func popoverView(popoverView: TPCPopoverView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    func popoverView(popoverView: TPCPopoverView, numberOfRowsInSection:Int) -> Int
    optional func numberOfSectionsInPopoverView(popoverView: TPCPopoverView) -> Int
    optional func popoverView(popoverView: TPCPopoverView, heightForRowAtIndexPath: NSIndexPath) -> CGFloat
}

@objc protocol TPCPopoverViewDelegate: NSObjectProtocol {
    optional func popoverView(popoverView: TPCPopoverView, didSelectRowAtIndexPath indexPath: NSIndexPath)
}

class TPCPopoverViewCell: UITableViewCell {
    private lazy var bottomLineView: UIView = {
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = TPCPopViewDefaultBottomLineColor
        return bottomLineView
    }()
    
    var hideBottomLine = true {
        willSet {
            bottomLineView.hidden = newValue
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = TPCPopViewDefaultThemeColor
        textLabel?.font = TPCPopViewDefaultFont
        textLabel?.textAlignment = NSTextAlignment.Left
        textLabel?.textColor = TPCPopViewDefaultTextColor
        selectionStyle = UITableViewCellSelectionStyle.None
        contentView.addSubview(bottomLineView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        bottomLineView.frame = CGRect(x: 0, y: contentView.bounds.height - 1, width: contentView.bounds.width - 10, height: 0.5)
    }
}

class TPCIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        TPCPopViewDefaultThemeColor.setFill()
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: rect.width / 2, y: 0))
        path.addLineToPoint(CGPoint(x: 0, y: rect.height))
        path.addLineToPoint(CGPoint(x: rect.width, y: rect.height))
        path.addLineToPoint(CGPoint(x: rect.width / 2, y: 0))
        path.fill()
    }
}

private let reuseIdentifier = "popoverViewCellIdentifier"
class TPCPopoverView: UIView {
    weak var dataSource: TPCPopoverViewDataSource?
    weak var delegate: TPCPopoverViewDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.registerClass(TPCPopoverViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tableView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView(frame: TPCPopViewDefaultFrame)
        containerView.backgroundColor = TPCPopViewDefaultThemeColor
        containerView.layer.cornerRadius = 5.0
        return containerView
    }()
    
    private var messages: [String]? {
        didSet {
            tableView.frame = CGRectInset(containerView.bounds, 5, 5)
            tableView.reloadData()
        }
    }
    
    private var clickAction: ((row: Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        addSubview(containerView)
        containerView.addSubview(tableView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func dismiss() {
        containerView.transform = CGAffineTransformIdentity
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0
            self.containerView.transform = CGAffineTransformMakeScale(0.001, 0.001)
            }) { (finished) -> Void in
                self.clickAction = nil
                self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismiss()
    }
}

extension TPCPopoverView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let result = dataSource?.numberOfSectionsInPopoverView?(self) {
            return result
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let result = dataSource?.popoverView(self, numberOfRowsInSection: section) {
            return result
        } else {
            return messages?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let result = dataSource?.popoverView?(self, heightForRowAtIndexPath: indexPath) {
            return result;
        } else {
            return TPCPopViewDefaultCellHeight
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let result = dataSource?.popoverView(self, cellForRowAtIndexPath: indexPath) {
            return result
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! TPCPopoverViewCell
            cell.textLabel?.text = messages![indexPath.row]
            print(indexPath.row, messages?.count)
            cell.hideBottomLine = (indexPath.row == (messages?.count ?? 0) - 1) || (messages?.count == 1)
            return cell;
        }
    }
}

extension TPCPopoverView: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let _ = delegate?.popoverView?(self, didSelectRowAtIndexPath: indexPath) else {
            clickAction?(row: indexPath.row)
            dismiss()
            return
        }
    }
}

extension TPCPopoverView {
    private func setupIndicatorView() {
        let indicatorView = TPCIndicatorView(frame: CGRectZero)
        if containerView.layer.anchorPoint.x < 0.5 {
            indicatorView.frame = CGRect(x: 5, y: -8, width: 16, height: 9)
        } else if containerView.layer.anchorPoint.x > 0.5 {
            indicatorView.frame = CGRect(x: containerView.bounds.width - 21, y: -8, width: 16, height: 9);
        } else {
            indicatorView.frame = CGRect(x: containerView.bounds.width / 2 - 8, y: -8, width: 16, height: 9)
        }
        containerView .addSubview(indicatorView)
    }
    
    private class func showMessages(messages: [String]?, containerFrame: CGRect, anchorPoint:CGPoint, clickAction: ((row: Int) -> ())?, dataSource: TPCPopoverViewDataSource?, delegate: TPCPopoverViewDelegate?) {
        var trueFrame = containerFrame
        trueFrame.origin.x -= containerFrame.width * (0.5 - anchorPoint.x)
        trueFrame.origin.y -= containerFrame.height * (0.5 - anchorPoint.y)
        let popoverView = TPCPopoverView(frame: UIScreen.mainScreen().bounds)
        popoverView.containerView.frame = trueFrame
        popoverView.containerView.layer.anchorPoint = anchorPoint
        popoverView.setupIndicatorView()
        popoverView.messages = messages
        popoverView.clickAction = clickAction
        popoverView.delegate = delegate
        popoverView.dataSource = dataSource
        UIApplication.sharedApplication().keyWindow?.addSubview(popoverView)
        popoverView.alpha = 0
        popoverView.containerView.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            popoverView.alpha = 1.0
            popoverView.containerView.transform = CGAffineTransformIdentity
            
            }, completion: nil)
    }
    
    private class func showMessages(messages: [String]?, containerFrame: CGRect, fadeDirection: TPCPopoverViewFadeDirection, clickAction: ((row: Int) -> ())?, dataSource: TPCPopoverViewDataSource?, delegate: TPCPopoverViewDelegate?) {
        var trueFrame = containerFrame
        var anchorPoint = CGPointZero
        if fadeDirection == TPCPopoverViewFadeDirection.LeftTop {
            anchorPoint = CGPoint(x: (5 + 16 / 2) / containerFrame.width, y: -8 / containerFrame.height)
            trueFrame.origin.x -= 5 + 16 / 2
        } else if fadeDirection == TPCPopoverViewFadeDirection.RightTop {
            anchorPoint = CGPoint(x: 1.0 - (5 + 16 / 2) / containerFrame.size.width, y: -8 / containerFrame.height)
            trueFrame.origin.x += 5 + 16 / 2 - containerFrame.width
        } else if fadeDirection == TPCPopoverViewFadeDirection.Center {
            anchorPoint = CGPoint(x: 0.5, y: -8 / containerFrame.height)
            trueFrame.origin.x -= containerFrame.width / 2
        }
        trueFrame.origin.y += 8
        
        showMessages(messages, containerFrame: trueFrame, anchorPoint: anchorPoint, clickAction: clickAction, dataSource: dataSource, delegate: delegate)
    }
    
    private class func showMessages(messages: [String], containerSize: CGSize, fromView: UIView, fadeDirection: TPCPopoverViewFadeDirection, clickAction: ((row: Int) -> ())?, dataSource: TPCPopoverViewDataSource?, delegate: TPCPopoverViewDelegate?) {
        let frame = CGRect(x: fromView.center.x, y: fromView.frame.maxY + fromView.frame.height * 0.5, width: containerSize.width, height: containerSize.height + 10)
        showMessages(messages, containerFrame: frame, fadeDirection: fadeDirection, clickAction: clickAction, dataSource: dataSource, delegate: delegate)
    }
    
    class func showMessages(messages: [String], containerFrame: CGRect, fadeDirection: TPCPopoverViewFadeDirection, clickAction: (row: Int) -> ()) {
        showMessages(messages, containerFrame: containerFrame, fadeDirection: fadeDirection, clickAction: clickAction, dataSource: nil, delegate: nil)
    }

    class func showMessages(messages: [String], containerSize: CGSize, fromView: UIView, fadeDirection: TPCPopoverViewFadeDirection, clickAction: (row: Int) -> ()) {
        showMessages(messages, containerSize: containerSize, fromView: fromView, fadeDirection: fadeDirection, clickAction: clickAction, dataSource: nil, delegate: nil)
    }
    
    class func showWithContainerSize(containerSize: CGSize, fromView: UIView, fadeDirection: TPCPopoverViewFadeDirection, dataSource: TPCPopoverViewDataSource, delegate: TPCPopoverViewDelegate) {
        showMessages([], containerSize: containerSize, fromView: fromView, fadeDirection: fadeDirection, clickAction: nil, dataSource: dataSource, delegate: delegate)
    }
}




