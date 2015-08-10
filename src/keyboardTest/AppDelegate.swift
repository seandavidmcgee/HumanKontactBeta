//
//  AppDelegate.swift
//  keyboardTest
//
//  Created by Neetin Sharma on 3/11/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import KGFloatingDrawer
import RealmSwift
import PKHUD

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

var manager = ABManager()
let realm = ABManager.abRealm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let kKGDrawersStoryboardName = "Main"
    
    let kKGDrawerFavsViewControllerStoryboardId = "KGDrawerFavsViewControllerStoryboardId"
    let kKGDrawerSettingsViewControllerStoryboardId = "KGDrawerSettingsViewControllerStoryboardId"
    let kKGRightDrawerStoryboardId = "KGRightDrawerViewControllerStoryboardId"
    var message: String!
    var indexEntrySoFar: String!
    var lookupWatchController : KannuuIndexController? = nil
    var first: Bool = true
    var selection: String? = nil
    var contactNumber: String!
    var phoneCallURL: NSURL!
    var ab = RHAddressBook()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.checkPermission()
        
        var searchcontroller1 : UITableViewController = listResults
        searchcontroller1.title = "list"
        
        var searchcontroller2 : UIViewController = gridResults
        searchcontroller2.title = "grid"
        
        var searchcontroller3 : UITableViewController = recentResults
        searchcontroller3.title = "recents"
        
        var searchcontroller4 : UITableViewController = favResults
        searchcontroller4.title = "favorites"
        
        searchControllerArray = [searchcontroller3, searchcontroller1, searchcontroller2, searchcontroller4]
        recentsIndex = find(searchControllerArray, recentResults)!
        favoritesIndex = find(searchControllerArray, favResults)!
        
        self.registerHKNotification(application)
        
        // Override point for customization after application launch.
        
        //if let n = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            //delay(0.0) {
                //self.doAlert(n)
            //}
        //}
        
        //self.registerMyNotification(application)
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]!) -> Void) -> Bool {
        if let userInfo: NSDictionary = userActivity.userInfo {
            if let currentAction = userInfo["current"] as? NSURL {
                if let window = self.window {
                    window.rootViewController?.restoreUserActivityState(userActivity)
                    window.rootViewController?.executeUserActivity(currentAction, activity: userActivity)
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
            let alertView = UIAlertView(title: "Handoff Error", message: message, delegate: nil, cancelButtonTitle: "Dismiss")
            alertView.show()
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
    
    private func checkPermission() {
        let appPreviousLaunch = isAppAlreadyLaunchedOnce()
        if appPreviousLaunch == true {
            if let granted = manager.hasPermission() as Bool! {
                if People.people.count == 0 && granted == true {
                    self.listQueues(false)
                } else if People.people.count == 0 && granted == false {
                    self.requestAccessAfterDecline()
                } else {
                    self.listQueues(true)
                    println("checked")
                }
            }
        }
        else {
            self.requestAccess()
            println("granted")
        }
    }
    
    func requestAccessAfterDecline() {
        let message = "To utilize HumanKontact you must provide permission for the app to access your contacts. If you wish to provide permission please select 'Settings' below; however if choose 'Dismiss' HumanKontact will be disabled until permission has been granted."
        let failAlert = UIAlertController(title: "Permission Required", message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { action -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { action -> Void in
            UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
        }
        failAlert.addAction(alertAction)
        failAlert.addAction(dismissAction)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.window!.rootViewController!.presentViewController(failAlert, animated: false) { completion -> Void in }
        })
        println("not authorized")
    }
    
    func requestAccess() {
        manager.requestAuthorization { [weak self](isGranted, permissionError) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if isGranted {
                    self!.listQueues(false)
                    println("granted")
                } else {
                    let message = "To utilize HumanKontact you must provide permission for the app to access your contacts. If you wish to provide permission please select 'Settings' below; however if choose 'Dismiss' HumanKontact will be disabled until permission has been granted."
                    let failAlert = UIAlertController(title: "Permission Required", message: message, preferredStyle: .Alert)
                    let alertAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { action -> Void in
                        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                        UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
                    }
                    let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { action -> Void in
                        UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
                    }
                    failAlert.addAction(alertAction)
                    failAlert.addAction(dismissAction)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self?.window!.rootViewController!.presentViewController(failAlert, animated: false) { completion -> Void in
                        }
                    })
                    println("not authorized")
                }
            })
        }
    }
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let isAppAlreadyLaunchedOnce = defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            println("App already launched")
            return true
        } else {
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            println("App launched first time")
            return false
        }
    }
    
    func createIndex() {
        let dataItems = self.ab.people as! [RHPerson]
        let indexFilePath = indexFile
        var flName: String!
        var lfName: String!
        var indexController = KannuuIndexController(controllerMode: .Create, indexFilePath: indexFilePath, numberOfOptions: 9, numberOfBranchSelections: 999)
        for dictionary in dataItems {
            if (dictionary.compositeName != nil) {
                let fName = dictionary.firstName != nil ? dictionary.firstName : ""
                let lName = dictionary.lastName != nil ? dictionary.lastName : ""
                if fName == "" || lName == "" {
                    flName = fName + lName
                    lfName = lName + fName
                } else {
                    flName = fName + " " + lName
                    lfName = lName + " " + fName
                }
                var error : NSError? = nil
                indexController?.addIndicies([flName], forData: flName, priority: 0, error: &error)
                indexController?.addIndicies([lfName], forData: flName, priority: 1, error: &error)
            }
        }
        indexController = nil
        lookupController = KannuuIndexController(controllerMode: .Lookup, indexFilePath: indexFilePath, numberOfOptions: 9, numberOfBranchSelections: 999)
        objectKeys = lookupController!.options!
        let selections = lookupController!.branchSelecions!
        myResults += selections
    }
    
    internal var indexFile : String {
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.kannuu.humankontact")!
        let hkIndexPath = directory.path!.stringByAppendingPathComponent("HKIndex")
        return hkIndexPath
    }
    
    func listQueues(permission: Bool) {
        let masterQueue = TaskQueue()
        masterQueue.tasks += {
            self.createIndex()
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Retrieving contacts…")
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
            PKHUD.sharedHUD.show()
        }
        let nestedQueue = TaskQueue()
        nestedQueue.tasks += {_, next in
            if permission == false {
                self.beginSort()
                mydelay(seconds: 2.0) {
                    next(nil)
                }
            } else {
                mydelay(seconds: 0.0) {
                    next(nil)
                }
            }
        }
        nestedQueue.tasks += {_, next in
            self.beginFetch()
            mydelay(seconds: 2.0) {
                next(nil)
            }
        }
        nestedQueue.completions.append({_ in
            println("completed nested queue")
        })
        masterQueue.tasks += nestedQueue
        masterQueue.tasks += {
            println("master queue resumed");
        }
        masterQueue.run {_ in
            println("master queue completed");
        }
    }
    
    private func beginSort() {
        manager.sortedRecords({ [weak self]() -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println("sorted")
            })
            }, failure: { [weak self](message: String) -> () in
                let failAlert = UIAlertController.init(title: "Permission Required", message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
                    manager = nil
                    manager = ABManager()
                    self?.checkPermission()
                }
                failAlert.addAction(alertAction)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.window!.rootViewController!.presentViewController(failAlert, animated: false) { completion -> Void in }
                })
            })
        
    }
    
    private func beginFetch() {
        manager.indexRecords({ [weak self]() -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println("fetched")
                var timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self!, selector: Selector("dismissIndicator"), userInfo: nil, repeats: false)
            })
            }, failure: { [weak self](message: String) -> () in
                let failAlert = UIAlertController.init(title: "Permission Required", message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
                    manager = nil
                    manager = ABManager()
                    
                }
                failAlert.addAction(alertAction)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.window!.rootViewController!.presentViewController(failAlert, animated: false) { completion -> Void in }
                })
            })
    }
    
    func dismissIndicator() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("fadeFromSplash"), userInfo: nil, repeats: false)
        PKHUD.sharedHUD.hide(afterDelay: 1.0)
    }
    
    func fadeFromSplash() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = drawerViewController
        window!.makeKeyAndVisible()
    }
    
    func registerHKNotification(application:UIApplication) {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == UIUserNotificationType.None){
            // Specify the notification types.
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            // Specify the notification actions.
            var callListAction = UIMutableUserNotificationAction()
            callListAction.identifier = "callContact"
            callListAction.title = "Call"
            callListAction.activationMode = UIUserNotificationActivationMode.Background
            callListAction.destructive = false
            callListAction.authenticationRequired = false
            
            var textListAction = UIMutableUserNotificationAction()
            textListAction.identifier = "textContact"
            textListAction.title = "Message"
            textListAction.activationMode = UIUserNotificationActivationMode.Background
            textListAction.destructive = false
            textListAction.authenticationRequired = false
            
            var trashAction = UIMutableUserNotificationAction()
            trashAction.identifier = "trashAction"
            trashAction.title = "Decline"
            trashAction.activationMode = UIUserNotificationActivationMode.Background
            trashAction.destructive = true
            trashAction.authenticationRequired = false
            
            let actionsArray = NSArray(objects: callListAction, textListAction, trashAction)
            let actionsArrayMinimal = NSArray(objects: textListAction, callListAction)
            
            // Specify the category related to the above actions.
            var contactListActionCategory = UIMutableUserNotificationCategory()
            contactListActionCategory.identifier = "contactListActionCategory"
            contactListActionCategory.setActions(actionsArray as [AnyObject], forContext: UIUserNotificationActionContext.Default)
            contactListActionCategory.setActions(actionsArrayMinimal as [AnyObject], forContext: UIUserNotificationActionContext.Minimal)
            
            let categoriesForSettings = NSSet(objects: contactListActionCategory)
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as Set<NSObject>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
    func addWatchIndexLookup() {
        let indexFilePath = self.indexFile
        lookupWatchController = KannuuIndexController(controllerMode: .Lookup, indexFilePath: indexFilePath, numberOfOptions: 26, numberOfBranchSelections: 999)
    }
    
    func doAlert(n:UILocalNotification) {
        self.callNumber(self.message)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        println(notificationSettings.types.rawValue)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // Do something serious in a real app.
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        if first == true {
            self.addWatchIndexLookup()
        }
        first = false
        if let keyDictionary = userInfo as? [String: AnyObject] {
            if keyDictionary["keys"] != nil {
                var response = refreshBranches(998)
                let responseDictionary = ["keys" : response]
            
                reply(responseDictionary)
            }
            if keyDictionary["selections"] != nil {
                var selectionOptions = keyDictionary["selections"] as! String
                var selectionIndex = selectionOptions.substringFromIndex(selectionOptions.endIndex.predecessor().predecessor())
                selection = selectionOptions.substringToIndex(selectionOptions.endIndex.predecessor())
                var index: Int = selectionIndex.toInt()!
                
                var response = refreshBranches(index)
                selection = self.lookupWatchController!.entrySoFar
                let responseDictionary = ["selections" : response]
                
                reply(responseDictionary)
            }
            if keyDictionary["backkeys"] != nil {
                var response = refreshBranches(998)
                let responseDictionary = ["backkeys" : response]
                
                reply(responseDictionary)
            }
            if keyDictionary["clearkeys"] != nil {
                var response = refreshBranches(999)
                let responseDictionary = ["clearkeys" : response]
                
                reply(responseDictionary)
            }
            if keyDictionary["text"] != nil {
                message = keyDictionary["text"] as! String
                
                let response = "\(message), and the iPhone app has seen it."
                let responseDictionary = ["text" : response]
                
                reply(responseDictionary)
            }
        }
    }
    
    func refreshBranches(index: Int) -> [AnyObject] {
        if index != 998 && index != 999 {
            self.lookupWatchController!.selectOption(index)
        }
        if index == 998 {
            self.lookupWatchController?.back()
        }
        if index == 999 {
            self.lookupWatchController?.restart()
        }
        var keys = self.lookupWatchController!.options!
        return keys
    }
    
    func callNumber(sender: String) -> String {
        var phoneNumber = sender
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return cleanNumber
    }
    
    func textNumber(phoneNumber:String) {
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (count(cleanNumber.utf16) > 1){
            if let textMessageURL:NSURL = NSURL(string: "sms://\(cleanNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(textMessageURL)) {
                    application.openURL(textMessageURL);
                }
            }
        } else {
            let alert = UIAlertView()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available for text messaging."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    private var _drawerViewController: KGDrawerViewController?
    var drawerViewController: KGDrawerViewController {
        get {
            if let viewController = _drawerViewController {
                return viewController
            }
            return prepareDrawerViewController()
        }
    }
    
    func prepareDrawerViewController() -> KGDrawerViewController {
        let drawerViewController = KGDrawerViewController()
        var bgImage = UIImage(named: "bkg")
        var effectImage : UIImage!
        var blurringLevel : CGFloat = 5.0
        
        effectImage = bgImage!.applyBlurWithRadius(blurringLevel, tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), saturationDeltaFactor: 1.0, maskImage: nil)
        
        drawerViewController.centerViewController = drawerFavsViewController()
        drawerViewController.rightViewController = rightViewController()
        drawerViewController.backgroundImage = effectImage!
        
        _drawerViewController = drawerViewController
        
        return drawerViewController
    }
    
    private func drawerStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: kKGDrawersStoryboardName, bundle: nil)
        return storyboard
    }
    
    private func viewControllerForStoryboardId(storyboardId: String) -> UIViewController {
        let viewController: UIViewController = drawerStoryboard().instantiateViewControllerWithIdentifier(storyboardId) as! UIViewController
        return viewController
    }
    
    func drawerFavsViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGDrawerFavsViewControllerStoryboardId)
        return viewController
    }
    
    func drawerSettingsViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGDrawerSettingsViewControllerStoryboardId)
        return viewController
    }
    
    private func rightViewController() -> UIViewController {
        let viewController = viewControllerForStoryboardId(kKGRightDrawerStoryboardId)
        return viewController
    }
    
    func toggleRightDrawer(sender:AnyObject, animated:Bool) {
        _drawerViewController?.toggleDrawer(.Right, animated: true, complete: { (finished) -> Void in
            // do nothing
        })
    }
    
    private var _centerViewController: UIViewController?
    var centerViewController: UIViewController {
        get {
            if let viewController = _centerViewController {
                return viewController
            }
            return drawerSettingsViewController()
        }
        set {
            if let drawerViewController = _drawerViewController {
                drawerViewController.closeDrawer(drawerViewController.currentlyOpenedSide, animated: true) { finished in }
                if drawerViewController.centerViewController != newValue {
                    drawerViewController.centerViewController = newValue
                }
            }
            _centerViewController = newValue
        }
    }
    
    func call(phoneNumber:String){
        window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "tel://\(phoneNumber)")!){
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
        } else {
            println("fail")
        }
    }
}

