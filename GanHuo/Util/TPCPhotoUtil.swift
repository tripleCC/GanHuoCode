//
//  TPCPhotoUtil.swift
//  WKCC
//
//  Created by tripleCC on 15/12/12.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import Photos

class TPCPhotoUtil {
    static var album: PHAssetCollection?
    static func authorize() -> Bool {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        return PHAuthorizationStatus.Restricted != authorizationStatus && PHAuthorizationStatus.Denied != authorizationStatus
    }
    
    static func createAlbum(title title: String, completion: ((album: PHAssetCollection) -> ())? = nil) {
        let smartAlbums = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        smartAlbums.enumerateObjectsUsingBlock({ (o, i, finish) -> Void in
//            debugPrint(o.localizedTitle!)
            if o.localizedTitle == title {
                album = o as? PHAssetCollection
                finish.memory = true
            } else {
                album = nil
            }
        })
        guard album == nil else {
            completion?(album: album!)
            return
        }
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(title)
            }, completionHandler: { (success, error) -> Void in
                if !success {
                    debugPrint("保存失败\(error)")
                } else {
                    let smartAlbums = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
                    album = smartAlbums.lastObject as? PHAssetCollection
                    completion?(album: album!)
                    debugPrint(album)
                }
        })
    }
    
    static func saveImage(image: UIImage, completion: ((success: Bool) -> ())? = nil) {
        guard authorize() else {
            completion?(success: false)
            return
        }
        completion?(success: true)
        createAlbum(title: "幹貨", completion: { (album: PHAssetCollection) -> () in
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                debugPrint(album, assetChangeRequest.placeholderForCreatedAsset)
                if let placeholder = assetChangeRequest.placeholderForCreatedAsset {
                    let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: album)
                    let enumeration: NSArray = [placeholder]
                    assetCollectionChangeRequest?.addAssets(enumeration)
                }
                }, completionHandler: nil)
        })
    }
}
