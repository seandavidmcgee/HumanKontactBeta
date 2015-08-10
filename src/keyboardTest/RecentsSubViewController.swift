//
//  RecentsSubViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/3/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

struct RecentPeople {
    static var recents = recentRealm.objects(HKPerson)
}
let recentRealm = ABManager.recentRealm()

class RecentsSubViewController: UITableViewController, UITextFieldDelegate {
    var realmNotification: NotificationToken?
    var scrollView: UIScrollView!
    var currentController: UIViewController?
    var parentNavigationController : UINavigationController?
    var hkRecentSorted: Results<HKPerson>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if realmNotification == nil {
            realmNotification = realm.addNotificationBlock({ [weak self](notificationString, realm) -> Void in
                self?.tableView.reloadData()
                })
        }
        if let hkRecentSorted_ = RecentPeople.recents.sorted("created", ascending: false) as Results<HKPerson>! {
            hkRecentSorted = hkRecentSorted_
        }
        self.tableView!.bounds = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.tableView!.backgroundColor = UIColor.clearColor()
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView!.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "FriendTableViewCell")
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func avatarImage(index: Int) -> UIImage {
        var colorIndex = avatarProfileColor(index)
        var currentColor = avatarColors[colorIndex]
        var avatarImage = getImageWithColor(UIColor(hex: currentColor), size: CGSize(width: 150, height: 150))
        return avatarImage
    }
    
    func avatarProfileColor(value: Int) -> Int {
        let rems = value % 12
        return rems
    }
    
    func profilePhone(number: String) -> String {
        let rangeOfLabel = number.rangeOfString(":")
        var phoneNumber: String!
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            phoneNumber = number.substringFromIndex(labelIndex + 1)
        }
        return phoneNumber
    }
    
    func profilePhoneLabel(number: String) -> String {
        let rangeOfLabel = number.rangeOfString(":")
        var phoneLabel: String!
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            phoneLabel = label
        } else {
            phoneLabel = "phone"
        }
        return phoneLabel
    }
    
    func profileEmail(email: String) -> String {
        let rangeOfLabel = email.rangeOfString(":")
        var emailString: String!
        if let labelIndex = email.indexOfCharacter(":") {
            let index: String.Index = advance(email.startIndex, labelIndex)
            let label: String = email.substringToIndex(index)
            emailString = email.substringFromIndex(labelIndex + 1)
        } else {
            emailString = "\(email)"
        }
        return emailString
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshTable()
        self.tableView!.showsVerticalScrollIndicator = true
        self.tableView!.delaysContentTouches = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if contactsSearchController.active {
            controller.view.hidden = true
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(false)
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    func refreshTable() {
        recentRealm.refresh()
        self.tableView.reloadData()
    }
    
    internal func fetchRecents() {
        manager.copyRecords({ [weak self]() -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                recentPeople.removeAll(keepCapacity: false)
                self?.tableView.reloadData()
            })
            }, failure: { [weak self](message: String) -> () in
                let failAlert = UIAlertController.init(title: "Permission Required", message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
                    manager = nil
                    manager = ABManager()
                }
                failAlert.addAction(alertAction)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.presentViewController(failAlert, animated: false) { completion -> Void in }
                })
            })
    }
}
