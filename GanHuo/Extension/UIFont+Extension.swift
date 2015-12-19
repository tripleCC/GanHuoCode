//
//  UIFont+Extension.swift
//  WKCC
//
//  Created by tripleCC on 15/11/18.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

extension UIFont {
    class func lanTingHeiSFontName() -> String {
        return "FZLTXHK--GBK1-0"
    }
    
    class func lanTingHeiBFontName() -> String {
        return "FZLTZHK--GBK1-0"
    }
    
    class func baskervilleSFontName() -> String {
        return "Baskerville"
    }
    
    class func didotBFontName() -> String {
        return "Didot-Bold"
    }
    
    class func avenirBookFontName() -> String {
        return "Avenir-Book"
    }
    
    class func zapfinoName() -> String {
        return "Zapfino"
    }
    
    class func hiraMinProNW3Name() -> String {
        return "HiraMinProN-W3"
    }
    
    class func appleSDGothicNeoThinName() -> String {
        return "AppleSDGothicNeo-Thin"
    }
    
    class func appleSDGothicNeoUltraLight() -> String {
        return "AppleSDGothicNeo-UltraLight"
    }
    
    class func showAllFonts() -> [String] {
        var fontNamesSaver = [String]()
        let familyNames = self.familyNames()
        for familyName in familyNames {
            print("Family: \(familyName) \n")
            let fontNames = UIFont.fontNamesForFamilyName(familyName)
            for fontName in fontNames {
                print("\tFont: \(fontName) \n")
                fontNamesSaver.append(fontName)
            }
        }
        return fontNamesSaver
    }
    
    class func createAllTypeIcon() {
        let fontNames = UIFont.showAllFonts()
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        containerView.backgroundColor = UIColor.whiteColor()
        
        let circleView = UIView(frame: containerView.bounds)
        circleView.bounds.size.width -= 10
        circleView.bounds.size.height -= 10
        containerView.addSubview(circleView)
        circleView.center = containerView.center
        circleView.layer.cornerRadius = circleView.bounds.width * 0.5
        circleView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(1)
        
        let mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height * 0.7))
        mainLabel.center = containerView.center
        mainLabel.textColor = UIColor.whiteColor()
        containerView.addSubview(mainLabel)
        mainLabel.text = "huo"
        mainLabel.textAlignment = NSTextAlignment.Center
        
        for fontName in fontNames {
            mainLabel.font = UIFont(name: fontName, size: 22)
            let data = UIImagePNGRepresentation(UIImage(layer: containerView.layer))
            dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
                let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] + "\(fontName).png"
                print(path)
                data?.writeToFile(path, atomically: true)
            }
        }
    }
}