//
//  TPCTextParser.swift
//  WKCC
//
//  Created by tripleCC on 15/11/20.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import Foundation

class TPCTextParser {
    static let shareTextParser = {
        return TPCTextParser()
    }()
    
    func parseOriginString(string: String) -> String {
        guard string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 else { return string }
        let str = filterUnuseString(string)
        return str
    }
    
    private func filterUnuseString(string: String) -> String {
        var str = string as NSString
//        str.stringByReplacingOccurrencesOfString("\n", withString: "")
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return str as String
    }
}