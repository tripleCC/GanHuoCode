//
//  TPCInAppSearchUtil.swift
//  GanHuo
//
//  Created by tripleCC on 16/6/30.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class TPCInAppSearchUtil {
    static func indexedItemWithTitle(title: String, contentDescription content: String, uniqueIdentifier identifier: String) {
        dispatch_async(dispatch_get_global_queue(0, 0)) { 
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeData as String)
            // Add metadata that supplies details about the item.
            attributeSet.title = title
            attributeSet.contentDescription = content
            attributeSet.thumbnailData = UIImagePNGRepresentation(UIImage(named: "ganhuo")!)
            
            // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
            let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: "ganhuo+"+identifier, attributeSet: attributeSet)
            
            // Add the item to the on-device index.
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { error in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
//                    print("Item indexed.")
                }
            }            
        }
    }
    
    static func indexedItemWithType(type: String, who: String, contentDescription content: String, uniqueIdentifier identifier: String) {
        indexedItemWithTitle("\(type) via.\(who)", contentDescription: content, uniqueIdentifier: identifier)
    }
}