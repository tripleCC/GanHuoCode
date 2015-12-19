//
//  TPCShareManager.swift
//  WKCC
//
//  Created by tripleCC on 15/11/22.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
import MonkeyKing

let SINAAPPKEY = "3199956444"
let SINASECRET = "e1d432235af5294b6f2a461b5bbce02f"
let REDIRECTURL = "http://triplecc.github.io/"
class TPCShareManager {
    let account = MonkeyKing.Account.Weibo(appID: SINAAPPKEY, appKey: SINASECRET, redirectURL: REDIRECTURL)
    var accessToken: String?
    static let shareInstance = TPCShareManager()
    func shareInit() {
        MonkeyKing.registerAccount(account)
        if !account.isAppInstalled {
            MonkeyKing.OAuth(account, completionHandler: { (dictionary, response, error) -> Void in
                if let json = dictionary, accessToken = json["access_token"] as? String {
                    self.accessToken = accessToken
                }
                
                print("dictionary \(dictionary) error \(error)")
            })
        }
    }
    
    private func shareImage() {
        let message = MonkeyKing.Message.Weibo(.Default(info: (
            title: "Image",
            description: "Rabbit",
            thumbnail: nil,
            media: .Image(UIImage(named: "rabbit")!)
            ), accessToken: accessToken))
        
        MonkeyKing.shareMessage(message) { success in
            print("success: \(success)")
        }
    }
    private func shareText() {
        let message = MonkeyKing.Message.Weibo(.Default(info: (
            title: "Title",
            description: "Text",
            thumbnail: nil,
            media: nil
            ), accessToken: accessToken))
        
        MonkeyKing.shareMessage(message) { success in
            print("success: \(success)")
        }
    }
    private func shareURL() {
        let message = MonkeyKing.Message.Weibo(.Default(info: (
            title: "News",
            description: "Hello Yep",
            thumbnail: UIImage(named: "rabbit"),
            media: .URL(NSURL(string: "http://soyep.com")!)
            ), accessToken: accessToken))
        
        MonkeyKing.shareMessage(message) { success in
            print("success: \(success)")
        }
    }
    
    func shareSinaWithTitle(title: String, desc: String, image: UIImage? = nil, mediaURL: NSURL? = nil) {
        shareInit()
        
        let lMediaURL: MonkeyKing.Media?
        if image == nil && mediaURL == nil {
            lMediaURL = nil
        } else if image != nil && mediaURL == nil {
            lMediaURL = MonkeyKing.Media.Image(image!)
        } else {
            lMediaURL = MonkeyKing.Media.URL(mediaURL!)
        }
        
        debugPrint(title, desc, image)
        let message = MonkeyKing.Message.Weibo(.Default(info: (
            title: title,
            description: desc,
            thumbnail: image,
            media: lMediaURL
            ), accessToken: accessToken))

        MonkeyKing.shareMessage(message) { success in
            print("success: \(success)")
        }
    }
}