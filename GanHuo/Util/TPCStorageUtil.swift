//
//  TPCStorageUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/11/28.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

let TPCLoadDataNumberOnceKey = "TPCLoadDataNumberOnce"
let TPCCategoryDisplayAtHomeKey = "TPCCategoryDisplayAtHome"
let TPCAllCategoriesKey = "TPCAllCategories"
let TPCSetContentRulesAtHomeKey = "TPCSetContentRulesAtHome"
let TPCSetPictureTransparencyKey = "TPCSetPictureTransparency"
class TPCStorageUtil {
    static func setObject(value: AnyObject?, forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: defaultName)
    }
    
    static func objectForKey(defaultName: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(defaultName)
    }
    
    static func setFloat(value: Float, forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setFloat(value, forKey: defaultName)
    }
    
    static func floatForKey(defaultName: String) -> Float {
        return  NSUserDefaults.standardUserDefaults().floatForKey(defaultName)
    }
    
    static func setBool(value: Bool, forKey defaultName: String) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: defaultName)
    }
    
    static func boolForKey(defaultName: String) -> Bool {
        return  NSUserDefaults.standardUserDefaults().boolForKey(defaultName)
    }
    
    static func saveLoadDataNumberOnce(number: String) {
        setObject(number, forKey: TPCLoadDataNumberOnceKey)
    }
    static func fetchLoadDataNumberOnce() -> String {
        let number = objectForKey(TPCLoadDataNumberOnceKey)
        if let numberTemp = number as? String {
            return numberTemp
        }
        return "\(TPCConfiguration.loadDataCountOnce)个妹子"
    }
    
    static func saveSelectedShowCategory(category: String) {
        setObject(category, forKey: TPCCategoryDisplayAtHomeKey)
    }
    
    static func fetchSelectedShowCategory() -> String {
        let category = objectForKey(TPCCategoryDisplayAtHomeKey)
        if let categoryTemp = category as? String {
            return categoryTemp
        }
        return TPCConfiguration.selectedShowCategory
    }
    
    static func saveAllCategories(categories: [String]) {
        setObject(categories, forKey: TPCAllCategoriesKey)
    }
    
    static func fetchAllCategories() -> [String] {
        let categories = objectForKey(TPCCategoryDisplayAtHomeKey)
        let defaultCategories = TPCConfiguration.allCategories
        if let categoriesTemp = categories as? [String] {
            if categoriesTemp.count < defaultCategories.count {
                return defaultCategories
            }
            return categoriesTemp
        }
        return defaultCategories
    }
    
    static func saveContentRules(rules: [String]) {
        setObject(rules, forKey: TPCSetContentRulesAtHomeKey)
    }
    
    static func fetchRawContentRules() -> [String] {
        let rules = objectForKey(TPCSetContentRulesAtHomeKey)
        if let rulesTemp = rules as? [String] {
            return rulesTemp
        }
        return [TPCRuleType.Two.rawValue, TPCRuleType.Three.rawValue]
    }
    
    static func fetchContentRules() -> [TPCRuleType] {
        let ruleStrings = objectForKey(TPCSetContentRulesAtHomeKey)
        var ruleArray = [TPCRuleType]()
        if let rulesTemp = ruleStrings as? [String] {
            for rule in rulesTemp {
                switch rule {
                    case TPCRuleType.One.rawValue:
                        ruleArray.append(TPCRuleType.One)
                    case TPCRuleType.Two.rawValue:
                        ruleArray.append(TPCRuleType.Two)
                    case TPCRuleType.Three.rawValue:
                        ruleArray.append(TPCRuleType.Three)
                    case TPCRuleType.Four.rawValue:
                        ruleArray.append(TPCRuleType.Four)
                    default:
                        break
                }
            }
            return ruleArray
        }
        return [TPCRuleType.Two, TPCRuleType.Three]
    }
    
    static func saveImageAlpha(var imageAlpha: Float) {
        imageAlpha = imageAlpha == 0 ? -1 : imageAlpha
        setFloat(imageAlpha, forKey: TPCSetPictureTransparencyKey)
    }
    
    static func fetchImageAlpha() -> Float {
        var imageAlpha = floatForKey(TPCSetPictureTransparencyKey)
        imageAlpha = imageAlpha == 0 ? 1 : imageAlpha
        imageAlpha = imageAlpha == -1 ? 0 : imageAlpha
        
        return imageAlpha
    }
}