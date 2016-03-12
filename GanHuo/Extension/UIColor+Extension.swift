//
//  UIColor+Extension.swift
//  GanHuo
//
//  Created by tripleCC on 16/3/2.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit

extension UIColor {
    static func randomColor() -> UIColor {
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
    }
    
    var r: CGFloat {
        let r = UnsafeMutablePointer<CGFloat>()
        self.getRed(r, green: UnsafeMutablePointer<CGFloat>(), blue: UnsafeMutablePointer<CGFloat>(), alpha: UnsafeMutablePointer<CGFloat>())
        return r.memory
    }
    
    var g: CGFloat {
        let g = UnsafeMutablePointer<CGFloat>()
        self.getRed(UnsafeMutablePointer<CGFloat>(), green: g, blue: UnsafeMutablePointer<CGFloat>(), alpha: UnsafeMutablePointer<CGFloat>())
        return g.memory
    }
    
    var b: CGFloat {
        let b = UnsafeMutablePointer<CGFloat>()
        self.getRed(UnsafeMutablePointer<CGFloat>(), green: UnsafeMutablePointer<CGFloat>(), blue: b, alpha: UnsafeMutablePointer<CGFloat>())
        return b.memory
    }
    
    var a: CGFloat {
        return CGColorGetAlpha(self.CGColor)
    }
    
    var rgbValue: Int {
        let r = UnsafeMutablePointer<CGFloat>()
        let g = UnsafeMutablePointer<CGFloat>()
        let b = UnsafeMutablePointer<CGFloat>()
        let a = UnsafeMutablePointer<CGFloat>()
        self.getRed(r, green: g, blue: b, alpha: a)
        let red = r.memory * 255
        let green = g.memory * 255
        let blue = b.memory * 255
        return (Int(red) << 16) + (Int(green) << 8) + Int(blue)
    }
    
    var rgbaValue: Int {
        let r = UnsafeMutablePointer<CGFloat>()
        let g = UnsafeMutablePointer<CGFloat>()
        let b = UnsafeMutablePointer<CGFloat>()
        let a = UnsafeMutablePointer<CGFloat>()
        self.getRed(r, green: g, blue: b, alpha: a)
        let red = r.memory * 255
        let green = g.memory * 255
        let blue = b.memory * 255
        let alpha = a.memory * 255
        return (Int(red) << 24) + (Int(green) << 16) + (Int(blue) << 8) + Int(alpha)
    }
    
    convenience init(rgbValue: Int) {
        self.init(red: (CGFloat((rgbValue & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(rgbValue & 0xFF)) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgbaValue: Int) {
        self.init(red: (CGFloat((rgbaValue & 0xFF000000) >> 24)) / 255.0, green: (CGFloat((rgbaValue & 0xFF0000) >> 16)) / 255.0, blue: (CGFloat((rgbaValue & 0xFF00) >> 8)) / 255.0, alpha: (CGFloat(rgbaValue & 0xFF)) / 255.0)
    }
    
    convenience init(rgbValue: Int, alpha: CGFloat) {
        self.init(red: (CGFloat((rgbValue & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(rgbValue & 0xFF)) / 255.0, alpha: alpha)
    }
    
    convenience init(hexString: String) {
        let (r, g, b, a) = hexStrToRGBA(hexString)
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

func hexStrToRGBA(var str: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a:CGFloat) {
    let set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    str = str.stringByTrimmingCharactersInSet(set).uppercaseString
    if str.hasPrefix("#") {
        str = str.substringFromIndex(str.startIndex.successor())
    } else if str.hasPrefix("0X") {
        str = str.substringFromIndex(str.startIndex.advancedBy(2))
    }
    
    let length = str.characters.count
    guard length == 3 || length == 4 || length == 6 || length == 8 else {
        return(0, 0, 0, 0)
    }
    
    func hexStrToInt(str: String) -> Int {
        return Int(str) ?? 0
    }
    
    if length < 5 {
        let r =  CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex, end: str.startIndex.successor())))) / 255.0
        let g = CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex.successor(), end: str.startIndex.advancedBy(2))))) / 255.0
        let b = CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex.advancedBy(2), end: str.startIndex.advancedBy(3))))) / 255.0
        var a: CGFloat
        if length == 4 {
            a = CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex.advancedBy(3), end: str.startIndex.advancedBy(4))))) / 255.0
        } else {
            a = 1
        }
        return (r, g, b, a)
    } else {
        let r =  CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex, end: str.startIndex.advancedBy(2))))) / 255.0
        let g = CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex.advancedBy(2), end: str.startIndex.advancedBy(4))))) / 255.0
        let b = CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex.advancedBy(4), end: str.startIndex.advancedBy(6))))) / 255.0
        var a: CGFloat
        if length == 8 {
            a = CGFloat(hexStrToInt(str.substringWithRange(Range(start: str.startIndex.advancedBy(6), end: str.startIndex.advancedBy(8))))) / 255.0
        } else {
            a = 1
        }
        return (r, g, b, a)
    }
}