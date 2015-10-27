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
    var recentsDelegate: RecentsDelegate?
    var fileCount = 0
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if session.reachable == false {
            self.showAlertControllerWithStyle(WKAlertControllerStyle.Alert)
            
            return
        }
    }

    func applicationDidBecomeActive() {
        
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
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
        let recentIndexCount = People.contacts.count
        
        do {
            peopleRealm.beginWrite()
            person!.recent = true
            person!.recentIndex = recentIndexCount + 1
            recentsDelegate?.timelineQueue()
            try peopleRealm.commitWrite()
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
    
    private func showAlertControllerWithStyle(style: WKAlertControllerStyle!) {
        let cancelAction = WKAlertAction(
            title: "Okay",
            style: WKAlertActionStyle.Cancel) { () -> Void in
                print("Destructive")
        }
        
        let actions = [cancelAction]
        InterfaceController().presentAlertControllerWithTitle(
            "Loading Contacts from iPhone",
            message: "Please open HumanKontact on your iPhone to sync your contacts for the first time.",
            preferredStyle: style,
            actions: actions)
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
        if fileCount > 6 {
            InterfaceController().proceedToSearch()
        }
    }
}
