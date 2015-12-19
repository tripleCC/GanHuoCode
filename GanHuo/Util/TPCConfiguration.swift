//
//  TPCConfiguration.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

enum TPCRuleType: String {
    case One = "天啦噜！表挡我看妹子！"
    case Two = "超过一行不显示"
    case Three = "最多显示5行"
    case Four = "全部显示"
}

struct TPCConfiguration {
    static let themeSFontName = UIFont.baskervilleSFontName()
    static let themeBFontName = UIFont.didotBFontName()
    static let themeCellSFontSize: CGFloat = 12.0
    static let themeCellBFontSize: CGFloat = 15.0
    static let themeTextColor = UIColor.lightGrayColor()
    static let themeSFont = UIFont(name: TPCConfiguration.themeSFontName, size: TPCConfiguration.themeCellSFontSize)
    static let themeBFont = UIFont(name: TPCConfiguration.themeBFontName, size: TPCConfiguration.themeCellBFontSize)
    static let navigationBarBackgroundColor = UIColor.whiteColor()
    static let navigationBarTitleFont = UIFont(name: TPCConfiguration.themeBFontName, size: 18.0)
    static let navigationBarTitleColor = UIColor.grayColor()
    
    static let technicalCellHeight: CGFloat = 400.0
    static let technicalCellLeftRightMargin: CGFloat = 10.0
    static let technicalBeautyImageViewHeight: CGFloat = 390.0
    static let technicalTableViewTopBottomMargin: CGFloat = 5.0
    static let technicalTableViewFooterViewHeight: CGFloat = 100
    static let technicalCellLabelFont = UIFont(name: UIFont.avenirBookFontName(), size: TPCConfiguration.themeCellSFontSize)
    static let technicalOriginScrollViewContentOffsetY = -TPCNavigationBarHeight - TPCConfiguration.technicalTableViewTopBottomMargin - TPCStatusBarHeight
    
    static let detailCellHeight: CGFloat = 40.0
    static let detailSectionHeaderHeight: CGFloat = 50.0
    static let detailHeaderImageViewHeight: CGFloat = TPCScreenWidth / (TPCScreenWidth - 20.0) * technicalBeautyImageViewHeight
    
    static let settingCellHeight: CGFloat = 50.0
    static let settingCellLableFont = UIFont(name: TPCConfiguration.themeSFontName, size: 14.0)
    static let settingContentRuleLabelFont = UIFont(name: UIFont.avenirBookFontName(), size: 10)
    
    
    static var (SYear, SMonth, SDay) = (2015, 5, 18)
    static let refreshingViewHW: CGFloat = 40.0
    
    static var allRules: [TPCRuleType] = [TPCRuleType.One, TPCRuleType.Two, TPCRuleType.Three, TPCRuleType.Four]
    
    static var technicalCellShowTextLineMax = 5
    static var loadDataCountOnce = 10
    static var selectedShowCategory = "iOS"
    static var allCategories = ["iOS", "Android", "App", "瞎推荐", "前端", "福利", "休息视频", "拓展资源"]
    static var contentRules: [TPCRuleType] = [TPCRuleType.Two, TPCRuleType.Three]
    static var imageAlpha: Float = 1.0
}

extension TPCConfiguration {
    static func setInitialize() {
        TPCConfiguration.loadDataCountOnce = TPCStorageUtil.fetchLoadDataNumberOnce().getLoadDataNumber()
        TPCConfiguration.selectedShowCategory = TPCStorageUtil.fetchSelectedShowCategory()
        TPCConfiguration.contentRules = TPCStorageUtil.fetchContentRules()
        let alpha = TPCStorageUtil.fetchImageAlpha()
        TPCConfiguration.imageAlpha = alpha  == 0 ? 1 : alpha
        TPCConfiguration.show()
    }
    
    static func show() {
        debugPrint("loadDataCountOnce", TPCConfiguration.loadDataCountOnce)
        debugPrint("selectedShowCategory", TPCConfiguration.selectedShowCategory)
        debugPrint("contentRules", TPCConfiguration.contentRules)
        debugPrint("imageAlpha", TPCConfiguration.imageAlpha)
    }
    
    static func checkBelowStartTime(year: Int, month: Int, day: Int) -> Bool {
        if TPCConfiguration.SYear > year {
            return true
        } else if TPCConfiguration.SYear < year {
            return false
        } else {
            if TPCConfiguration.SMonth > month {
                return true
            } else if TPCConfiguration.SMonth < month {
                return false
            } else {
                if TPCConfiguration.SDay > day {
                    return true
                } else if TPCConfiguration.SDay < day {
                    return false
                } else {
                    return false
                }
            }
        }
    }
}