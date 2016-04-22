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
        static let TPCJSPatchManagerAllowMaxCrashTime = 1
        static let TPCJSPatchManagerJSVersoinKey = "TPCJSPatchManagerJSVersoinKey"
        static let TPCJSPatchManagerFetchDateKey = "TPCJSPatchManagerFetchDateKey"
        static let TPCJSPatchManagerEvaluateJSFailTimeKey = "TPCJSPatchManagerEvaluateJSFailTimeKey"
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
    
    private var evaluateJSFailTime: Int {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(Static.TPCJSPatchManagerEvaluateJSFailTimeKey) as? Int ?? 0
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: Static.TPCJSPatchManagerEvaluateJSFailTimeKey)
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
        guard evaluateJSFailTime < Static.TPCJSPatchManagerAllowMaxCrashTime else { return }
        startWithJSName(Static.TPCJSPatchFileName)
    }
    
    private func recordFailTimeWithAction(action: (() -> Void)) {
        objc_sync_enter(self)
        evaluateJSFailTime += 1
        action()
        evaluateJSFailTime -= 1
        objc_sync_exit(self)
    }
    
    private func startWithJSName(name: String) {
        do {
            let jsScript = try String(contentsOfFile: jsScriptPath)
            JPEngine.startEngine()
            recordFailTimeWithAction {
                JPEngine.evaluateScript(jsScript)
            }
        } catch {
            print(error)
        }
    }
    
    func handleJSPatchStatusWithURLString(URLString: String, duration: NSTimeInterval) {
        let fetchStatusCompletion = { (version: String, jsPath: String) in
            self.fetchDate = NSDate()
            debugPrint(version, self.jsVersion)
            if Float(version) > Float(self.jsVersion) {
                TPCNetworkUtil.shareInstance.loadJSPatchFileWithURLString(jsPath, completion: { (jsScript) in
                    self.evaluateJSFailTime = 0
                    self.recordFailTimeWithAction {
                        JPEngine.evaluateScript(jsScript)
                    }
                    do {
                        try jsScript.writeToFile(self.jsScriptPath, atomically: true, encoding: NSUTF8StringEncoding)
                        self.jsVersion = version
                    } catch let error {
                        print(error)
                    }

                })
            }
        }
        func fetchJSPatchStatus() {
            TPCNetworkUtil.shareInstance.loadJSPatchStatusWithURLString(URLString, completion: fetchStatusCompletion)
        }
        
        if let fetchDate = fetchDate {
            if NSDate().timeIntervalSinceDate(fetchDate) > duration {
                fetchJSPatchStatus()
            }
        } else {
            fetchJSPatchStatus()
        }
    }
}
