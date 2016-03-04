//
//  TPCTechnicalCell.swift
//  WKCC
//
//  Created by tripleCC on 15/11/17.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import Kingfisher

class TPCTechnicalCell: UITableViewCell {
    var technicalDict: [String : [TPCTechnicalObject]]! {
        didSet {
            if let technical = technicalDict["福利"]?.first {
                beautyImageView.alpha = CGFloat(TPCConfiguration.imageAlpha)
                if technical.url == nil {
                    print(technical)
                }
                beautyImageView.kf_setImageWithURL(NSURL(string: technical.url!)!, placeholderImage: UIImage(), optionsInfo: [.Transition(.Fade(0.5))])
            }
            dispatchGlobal { 
                var descString = "  "
                for category in TPCConfiguration.allCategories {
                    if let technicals = self.technicalDict[category] {
                        let timeString = technicals.first!.publishedAt!
                        let index = timeString.startIndex.advancedBy("XXXX-XX-XX".lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                        descString += timeString.substringToIndex(index) + "\n ●"
                        break
                    }
                }
                if let technicals = self.technicalDict[TPCConfiguration.selectedShowCategory] {
                    if technicals.count > 0 {
                        var validDescCount = 0
                        for technical in technicals {
                            if (TPCConfiguration.contentRules.contains(TPCRuleType.Two) && TPCConfiguration.contentRules.contains(TPCRuleType.Three)) {
                                if technical.desc!.technicalCellLabelBoundingRect().size.width < TPCScreenWidth - 3 * TPCConfiguration.technicalCellLeftRightMargin {
                                    if validDescCount++ < TPCConfiguration.technicalCellShowTextLineMax {
                                        descString += technical.desc! + "\n ●"
                                    }
                                }
                            } else if (TPCConfiguration.contentRules.contains(TPCRuleType.Two)) {
                                if technical.desc!.technicalCellLabelBoundingRect().size.width < TPCScreenWidth - 3 * TPCConfiguration.technicalCellLeftRightMargin {
                                    descString += technical.desc! + "\n ●"
                                }
                            } else if (TPCConfiguration.contentRules.contains(TPCRuleType.Three)) {
                                if validDescCount++ < TPCConfiguration.technicalCellShowTextLineMax {
                                    descString += technical.desc! + "\n ●"
                                }
                            } else if (TPCConfiguration.contentRules.contains(TPCRuleType.Four)) {
                                descString += technical.desc! + "\n ●"
                            }
                        }
                    }
                }
                descString = descString.substringToIndex(descString.endIndex.advancedBy(-3))
                dispatchAMain() {
                    self.describeLabel.text = descString
                    self.describeLabel.subviews.first?.alpha = CGFloat(TPCConfiguration.imageAlpha)
                    self.describeLabel.layoutIfNeeded()
                }
            }
        }
    }
    
    @IBOutlet weak var beautyImageView: UIImageView! {
        didSet {
            beautyImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var describeLabel: UILabel! {
        didSet {
            describeLabel.font = TPCConfiguration.technicalCellLabelFont
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        beautyImageView.image = nil
//        describeLabel.text = nil
    }
    
    func createSubviewsMirrorForView(view: UIView) -> (beautyImageView: UIImageView, describeLabel: UIImageView) {
        let beautyImageViewF = contentView.convertRect(self.beautyImageView.frame, toView: view)
        let describeLabelF = contentView.convertRect(self.describeLabel.frame, toView: view)
        
        let beautyImageView = UIImageView(frame: beautyImageViewF)
        beautyImageView.image = UIImage(layer: self.beautyImageView.layer)
        
        let describeLabel = UIImageView(frame: describeLabelF)
        describeLabel.image = UIImage(layer: self.describeLabel.layer)
        return (beautyImageView, describeLabel)
    }
}
