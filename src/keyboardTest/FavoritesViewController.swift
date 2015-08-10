//
//  FavoritesViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/11/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Alamofire
import PKHUD

var pickedImage : UIImage!
var pickedPerson: HKPerson = HKPerson()
var pickedBG : UIImage!
var pickedInitials : String?
var pickedName : String?
var pickedCompany : String?
var pickedTitle : String?
var myResults = [AnyObject]()
var objectKeys = [AnyObject]()
var lookupController : KannuuIndexController? = nil
var phonesArray = Array<Dictionary<String,String>>()
var emailsArray = Array<Dictionary<String,String>>()
var recentsPhonesArray = Array<Dictionary<String,String>>()
var recentsEmailsArray = Array<Dictionary<String,String>>()
var favsPhonesArray = Array<Dictionary<String,String>>()
var favsEmailsArray = Array<Dictionary<String,String>>()
var phonesProfileArray = Array<Dictionary<String,String>>()
var emailsProfileArray = Array<Dictionary<String,String>>()
var localLabelArray = Array<Dictionary<String,String>>()
var avatarView: DNVAvatarView!
var contactAvatar: DNVAvatar!
var avatarWidth: NSLayoutConstraint!
var parentNavigationController : UINavigationController?

//
// util function to delay code exection by given interval
//

func mydelay(#seconds:Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
        completion()
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat(hex >> 16 & 0xFF) / 0xFF, green: CGFloat(hex >> 8 & 0xFF) / 0xFF, blue: CGFloat(hex & 0xFF) / 0xFF, alpha: 1)
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        var r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        var g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        var b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }  
}

struct People {
    static var people = realm.objects(HKPerson)
}

@objc
class FavoritesViewController: UITableViewController, UITextFieldDelegate, UIScrollViewDelegate {
    var realmNotification: NotificationToken?
    var people: Results<HKPerson> = realm.objects(HKPerson)
    var scrollView: UIScrollView!
    var currentController: UIViewController?
    var parentNavigationController : UINavigationController?
    var textFieldInsideSearchBar = contactsSearchController.searchBar.valueForKey("searchField") as? UITextField
    var textField = normalSearchController.searchBar.valueForKey("searchField") as? UITextField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if realmNotification == nil {
            realmNotification = realm.addNotificationBlock({ [weak self](notificationString, realm) -> Void in
                self?.tableView.reloadData()
            })
        }
        self.tableView!.backgroundColor = UIColor.clearColor()
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView!.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "FriendTableViewCell")
        self.tableView!.bounds = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    deinit {
        realm.removeNotification(realmNotification!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshTable()
        self.tableView!.showsVerticalScrollIndicator = true
        self.tableView!.delaysContentTouches = false
        contactsSearchController.searchResultsUpdater = self
        normalSearchController.searchResultsUpdater = self
        
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        textFieldInsideSearchBar?.delegate = self
        
        if (keyboardButton.enabled == false) {
            keyboardButton.enabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getSkypeStatus() {
        var email = "toddviegut@gmail.com"
        let headers = [
            "Referer": "https://login.skype.com",
        ]
        let request = Alamofire.request(.GET, "https://login.skype.com/json/validator?email_repeat=\(email)&email=\(email)", headers: headers)
            .responseJSON { _, _, JSON, _ in
                println(JSON)
        }
    }
    
    func refreshTable() {
        realm.refresh()
        self.tableView.reloadData()
    }
    
    func backgroundAddRecent() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            recentResults.fetchRecents()
        }
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
}
