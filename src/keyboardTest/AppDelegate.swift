//
//  AppDelegate.swift
//  keyboardTest
//
//  Created by Neetin Sharma on 3/11/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import AudioToolbox
import LNRSimpleNotifications
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var walkthrough:MMPlayStandPageViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics()])
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        print(Defaults[.orient])
        
        if Defaults[.orient] == "" {
            Defaults[.orient] = "right"
        }
        
        if Defaults[.sort] == "" {
            Defaults[.sort] = "flName"
        }
        
        if Defaults[.order] == "" {
            Defaults[.order] = "alpha"
        }
        
        if Defaults[.backup] == "" {
            Defaults[.backup] = "yes"
        }
        
        let settings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        walkthrough = main.instantiateViewControllerWithIdentifier("playstand") as? MMPlayStandPageViewController
        
        setupRealmInApp()
        
        let contactsImage = UIImage(named: "Contacts")
        let contacts = contactsImage?.imageWithColor(UIColor.whiteColor())
        
        LNRSimpleNotifications.sharedNotificationManager.notificationsPosition = LNRNotificationPosition.Bottom
        LNRSimpleNotifications.sharedNotificationManager.notificationsBackgroundColor = UIColor(red: 251/255, green: 33/255, blue: 85/255, alpha: 1.0)
        LNRSimpleNotifications.sharedNotificationManager.notificationsTitleTextColor = UIColor.whiteColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsTitleFont = UIFont(name: "AvenirNext-Regular", size: 17)!
        LNRSimpleNotifications.sharedNotificationManager.notificationsBodyTextColor = UIColor.whiteColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsBodyFont = UIFont(name: "AvenirNext-Regular", size: 15)!
        LNRSimpleNotifications.sharedNotificationManager.notificationsSeperatorColor = UIColor.clearColor()
        LNRSimpleNotifications.sharedNotificationManager.notificationsIcon = contacts
        
        let alertSoundURL: NSURL? = NSBundle.mainBundle().URLForResource("click", withExtension: "wav")
        if let _ = alertSoundURL {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(alertSoundURL!, &mySound)
            LNRSimpleNotifications.sharedNotificationManager.notificationSound = mySound
        }
        
        return true
    }
    
    func setupRealmInApp() {
        func fileInDocumentsDirectory(filename: String) -> String {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = documentsURL.URLByAppendingPathComponent(filename)
            return fileURL.path!
        }
        
        let realmPath: String = fileInDocumentsDirectory("default.realm")
        Realm.Configuration.defaultConfiguration.path = realmPath
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if let userInfo: NSDictionary = userActivity.userInfo {
            if let currentAction = userInfo["current"] as? NSURL {
                if let window = self.window {
                    window.rootViewController?.restoreUserActivityState(userActivity)
                    window.rootViewController?.executeUserActivity(currentAction, activity: userActivity)
                }
                return true
            }
            if let currentPerson = userInfo["person"] as? String {
                if let window = self.window {
                    window.rootViewController?.restoreUserActivityState(userActivity)
                    window.rootViewController?.executeUserActivityPerson(currentPerson, activity: userActivity)
                }
                return true
            }
        }
        return false
    }
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    func application(application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: NSError) {
        if error.code != NSUserCancelledError {
            let message = "The connection to your other device may have been interrupted. Please try again. \(error.localizedDescription)"
            let alertView = UIAlertController(title: "Handoff Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alertView.addAction(okAction)
            window!.rootViewController!.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

