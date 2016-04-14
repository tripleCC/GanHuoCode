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
        let r = UnsafeMutablePointer<CGFloat>(nil)
        self.getRed(r, green: UnsafeMutablePointer<CGFloat>(nil), blue: UnsafeMutablePointer<CGFloat>(nil), alpha: UnsafeMutablePointer<CGFloat>(nil))
        return r.memory
    }
    
    var g: CGFloat {
        let g = UnsafeMutablePointer<CGFloat>(nil)
        self.getRed(UnsafeMutablePointer<CGFloat>(nil), green: g, blue: UnsafeMutablePointer<CGFloat>(nil), alpha: UnsafeMutablePointer<CGFloat>(nil))
        return g.memory
    }
    
    var b: CGFloat {
        let b = UnsafeMutablePointer<CGFloat>(nil)
        self.getRed(UnsafeMutablePointer<CGFloat>(nil), green: UnsafeMutablePointer<CGFloat>(nil), blue: b, alpha: UnsafeMutablePointer<CGFloat>(nil))
        return b.memory
    }
    
    var a: CGFloat {
        return CGColorGetAlpha(self.CGColor)
    }
    
    var rgbValue: Int {
        let r = UnsafeMutablePointer<CGFloat>(nil)
        let g = UnsafeMutablePointer<CGFloat>(nil)
        let b = UnsafeMutablePointer<CGFloat>(nil)
        let a = UnsafeMutablePointer<CGFloat>(nil)
        self.getRed(r, green: g, blue: b, alpha: a)
        let red = r.memory * 255
        let green = g.memory * 255
        let blue = b.memory * 255
        return (Int(red) << 16) + (Int(green) << 8) + Int(blue)
    }
    
    var rgbaValue: Int {
        let r = UnsafeMutablePointer<CGFloat>(nil)
        let g = UnsafeMutablePointer<CGFloat>(nil)
        let b = UnsafeMutablePointer<CGFloat>(nil)
        let a = UnsafeMutablePointer<CGFloat>(nil)
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
    
    convenience init(rgbaValue: Int64) {
        self.init(red: (CGFloat((rgbaValue & 0xFF000000) >> 24)) / 255.0, green: (CGFloat((rgbaValue & 0xFF0000) >> 16)) / 255.0, blue: (CGFloat((rgbaValue & 0xFF00) >> 8)) / 255.0, alpha: (CGFloat(rgbaValue & 0xFF)) / 255.0)
    }
    
    convenience init(rgbValue: Int, alpha: CGFloat) {
        self.init(red: (CGFloat((rgbValue & 0xFF0000) >> 16)) / 255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8)) / 255.0, blue: (CGFloat(rgbValue & 0xFF)) / 255.0, alpha: alpha)
    }
}