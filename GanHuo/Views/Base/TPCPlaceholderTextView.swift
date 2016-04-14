//
//  TPCPlaceholderTextView.swift
//  GanHuo
//
//  Created by tripleCC on 16/4/14.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

class TPCPlaceholderTextView: UITextView {
    var placeholderLabel: UILabel!
    var textChangeCallBack: ((TPCPlaceholderTextView) -> Void)?
    var placeholderColor: UIColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22) {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            setNeedsLayout()
        }
    }
    
    var placeholderFont: UIFont = UIFont.systemFontOfSize(14) {
        didSet {
            placeholderLabel.font = font
            setNeedsLayout()
        }
    }
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupSubviews()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        configure()
    }
    
    private func configure() {
        alwaysBounceVertical = true
        placeholderLabel.font = UIFont.systemFontOfSize(14)
        placeholderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TPCPlaceholderTextView.textDidChange), name: UITextViewTextDidChangeNotification, object: self)
    }
    
    func textDidChange() {
        textChangeCallBack?(self)
        placeholderLabel.hidden = hasText()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setupSubviews() {
        placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        placeholderLabel.frame.origin = CGPoint(x: 4, y: 7)
        addSubview(placeholderLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame.size.width = frame.width - 2 * placeholderLabel.frame.origin.x
        placeholderLabel.sizeToFit()
    }
    
    

}
