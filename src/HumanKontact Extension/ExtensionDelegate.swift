//
//  ExtensionDelegate.swift
//  HumanKontact Extension
//
//  Created by Sean McGee on 10/5/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import WatchConnectivity

var lookupWatchController : KannuuIndexController? = nil

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    var session : WCSession!
    var fileCount = 0
    var recentsDelegate: SearchController?
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if session.reachable == false {
            print("not reachable")
            return
        }
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        let filemgr = NSFileManager.defaultManager()
        let indexFilePath = self.indexFile
        
        if filemgr.fileExistsAtPath(docsDir + "/default.realm") {
            lookupWatchController = KannuuIndexController(controllerMode: .Lookup, indexFilePath: indexFilePath, numberOfOptions: 26, numberOfBranchSelections: 999)
        }
    }

    func applicationDidBecomeActive() {

    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    internal var indexFile : String {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let hkIndexPath = documentsURL.path!.stringByAppendingPathComponent("HKIndex")
        return hkIndexPath
    }
    
    // Received message from iPhone
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        // Reply handler, received message
        let recentValue = message["recent"]
        if recentValue != nil {
            let recordKey = recentValue as? String
            self.addRecent(recordKey!)
            // Send a reply
            replyHandler(["reply": "Recent added"])
        }
        
        let value = message["complete"] as? String
        if value == "Realm" {
            print(value!)
            // Send a reply
            replyHandler(["reply": "Realm added"])
        }
    }
    
    func addRecent(key: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addRecentSubTask(key)
        })
    }
    
    func addRecentSubTask(key: String) {
        let person = peopleRealm.objectForPrimaryKey(HKPerson.self, key: key)
        var recentIndexCount = Int()
        if People.contacts.count > 0 {
            recentIndexCount = People.contacts.first!.recentIndex
        } else {
            recentIndexCount = 0
        }
        
        do {
            let realm = ABWatchManager.peopleRealm()
            realm.beginWrite()
            person!.recent = true
            person!.recentIndex = recentIndexCount + 1
            try realm.commitWrite()
            recentsDelegate?.reloadTableData(false)
        } catch let error as NSError {
            print("Error moving file: \(error.description)")
        }
    }
    
    func sendRecentToPhone(record: String) {
        let msg = ["recent": record]
        session.sendMessage(msg, replyHandler: { (replyMessage) -> Void in
            // Reply handler - present the reply message on screen
            let value = replyMessage["reply"] as? String
            if value == "Recent added" {
                print(value!)
            }
            }) { (error:NSError) -> Void in
                print(error.localizedDescription)
        }
    }
    
    func requestToPhone() {
        let msg = ["request": "Realm"]
            
        session.sendMessage(msg, replyHandler: { (replyMessage) -> Void in
            // Reply handler - present the reply message on screen
            let value = replyMessage["reply"] as? String
            if value == "Realm sent" {
                print(value!)
            }
            }) { (error:NSError) -> Void in
                print(error.localizedDescription)
        }
    }
    
    // Received file from iPhone

    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("Received File: \(file)")
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        let filemgr = NSFileManager.defaultManager()
        let fileName = file.fileURL.pathComponents!.last!
        print(fileName)
        
        do {
            if !filemgr.fileExistsAtPath(docsDir + "/\(fileName)") {
                try filemgr.moveItemAtPath(file.fileURL.path!, toPath: docsDir + "/\(fileName)")
                fileCount++
                continueToSearch()
            } else {
                try filemgr.removeItemAtPath(docsDir + "/\(fileName)")
                try filemgr.moveItemAtPath(file.fileURL.path!, toPath: docsDir + "/\(fileName)")
                fileCount++
                continueToSearch()
            }
        } catch let error as NSError {
            print("Error moving file: \(error.description)")
        }
    }
    
    func continueToSearch() {
        if fileCount >= 7 {
            let indexFilePath = self.indexFile
            lookupWatchController = KannuuIndexController(controllerMode: .Lookup, indexFilePath: indexFilePath, numberOfOptions: 26, numberOfBranchSelections: 999)
            WKExtension.sharedExtension().rootInterfaceController!.pushControllerWithName("Search", context: nil)
        }
    }
}
