//
//  TPCJSPatchManager.swift
//  JSPathManager
//
//  Created by tripleCC on 16/4/21.
//  Copyright © 2016年 tripleCC. All rights reserved.
//

import UIKit
import JSPatch
import Alamofire

class TPCJSPatchManager: NSObject {
    struct Static {
        static let TPCJSPatchManagerJSVersoinKey = "TPCJSPatchManagerJSVersoinKey"
        static let TPCJSPatchManagerFetchDateKey = "TPCJSPatchManagerFetchDateKey"
        static let TPCJSPatchFileName = "TPCJSPatchHotfix"
        static let TPCJSPatchFileDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    }
    
    private var jsVersion: String {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(Static.TPCJSPatchManagerJSVersoinKey) as? String ?? "0"
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Static.TPCJSPatchManagerJSVersoinKey)
        }
    }
    private var fetchDate: NSDate? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(Static.TPCJSPatchManagerFetchDateKey) as? NSDate
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Static.TPCJSPatchManagerFetchDateKey)
        }
    }
    
    private var jsScriptPath: String {
        return Static.TPCJSPatchFileDirectory + "/" + Static.TPCJSPatchFileName + ".js"
    }
    
    static let shareManager = TPCJSPatchManager()
    
    func start() {
        startWithJSName(Static.TPCJSPatchFileName)
    }
    
    private func startWithJSName(name: String) {
        do {
            let jsScript = try String(contentsOfFile: jsScriptPath)
            JPEngine.startEngine()
            JPEngine.evaluateScript(jsScript)
        } catch {
            print(error)
        }
    }
    
    func handleJSPatchStatusWithURLString(URLString: String, duration: NSTimeInterval) {
        let fetchStatusCompletion = { (version: String, jsPath: String) in
            self.fetchDate = NSDate()
            if version > self.jsVersion {
                self.jsVersion = version
                self.fetchJSPatchFileWithURLString(jsPath)
            }
        }
        func fetchJSPatchStatus() {
            fetchJSPatchStatusWithURLString(URLString, completion: fetchStatusCompletion)
        }
        
        if let fetchDate = fetchDate {
            if NSDate().timeIntervalSinceDate(fetchDate) > duration {
                fetchJSPatchStatus()
            }
        } else {
            fetchJSPatchStatus()
        }
    }
    
    private func fetchJSPatchStatusWithURLString(URLString: String, completion:((version: String, jsPath: String) -> Void)) {
        Alamofire.request(.GET, URLString)
                 .responseJSON(queue: dispatch_get_main_queue(), options: .AllowFragments, completionHandler: { (response) in
                    if let dataDict = response.result.value {
                        if let version = dataDict["version"] as? String ,
                            let filePath = dataDict["filePath"] as? String {
                            completion(version: version, jsPath: filePath)
                        }
                    }
                 })
    }
    
    private func fetchJSPatchFileWithURLString(URLString: String) {
        Alamofire.request(.GET, URLString)
                 .response(completionHandler: { (request, response, data, error) in
                    if let data = data {
                        if let jsScript = String(data: data, encoding: NSUTF8StringEncoding) {
                            JPEngine.evaluateScript(jsScript)
                            do {
                                try jsScript.writeToFile(self.jsScriptPath, atomically: true, encoding: NSUTF8StringEncoding)
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                 })
    }

}
