//
//  CALayer+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/12/14.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit
extension CALayer {
    func saveImageWithName(name: String) {
        let data = UIImagePNGRepresentation(UIImage(layer: self))
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] + "/\(name).png"
            debugPrint(path)
            data?.writeToFile(path, atomically: false)
        }
    }
}