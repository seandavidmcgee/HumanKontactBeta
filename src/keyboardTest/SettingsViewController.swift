//
//  SettingsViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/11/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsViewController: UITableViewController {
    var parentNavigationController : UINavigationController?
    var realmNotification: NotificationToken?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func scheduleLocalNotification(message: String) {
        var localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        localNotification.alertBody = "Would you like to call \(message)?"
        localNotification.alertAction = "Call"
        
        localNotification.category = "contactListActionCategory"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func handleModifyListNotification(notification: NSNotification) {
        if let message = notification.object as? String {
            self.scheduleLocalNotification(message)
        }
        self.tableView.becomeFirstResponder()
    }
    
    @IBAction func toggleRightDrawer(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender, animated: true)
    }
}
