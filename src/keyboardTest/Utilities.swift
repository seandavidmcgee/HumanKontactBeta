//
//  Utilities.swift
//  keyboardTest
//
//  Created by Sean McGee on 9/6/15.
//  Copyright (c) 2015 Kannuu. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import SwiftyUserDefaults

func mydelay(seconds seconds:Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
        completion()
    }
}

struct People {
    static var people = try! Realm().objects(HKPerson).sorted("fullName")
    static var names = try! Realm().objects(HKPerson).sorted("indexedOrder", ascending: true)
}

struct RecentPeople {
    static var recents = try! Realm().objects(HKPerson).filter("recent == true").sorted("recentIndex", ascending: false)
}

struct FavPeople {
    static var favorites = try! Realm().objects(HKPerson).filter("favorite == true").sorted("favIndex", ascending: true)
}

struct Lookup {
    static var lookupController: KannuuIndexController? = nil
}

extension DefaultsKeys {
    static let orient = DefaultsKey<String>("orient")
    static let sort = DefaultsKey<String>("sort")
    static let order = DefaultsKey<String>("order")
    static let backup = DefaultsKey<String>("backup")
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat(hex >> 16 & 0xFF) / 0xFF, green: CGFloat(hex >> 8 & 0xFF) / 0xFF, blue: CGFloat(hex & 0xFF) / 0xFF, alpha: 1)
    }
    
    convenience init(hexString: String) {
        var cString:String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if (cString.hasPrefix("0X")) {
            cString = (cString as NSString).substringFromIndex(2)
        }
        if (cString.characters.count != 6) {
            self.init(white: 0.0, alpha: 1.0)
        } else {
            var rgbValue: UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)
            
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0))
        }
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
     let border = CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        border.backgroundColor = color.CGColor;
        
        self.addSublayer(border)
    }
}

extension UIView {
    func snapshot(view: UIView!) -> UIImage! {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image
    }
}

extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
        
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
            
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, .Normal)
            
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextFillRect(context, rect)
            
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
            
        return newImage
    }
}

extension UIButton {
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsetsMake(-22, -22, -22, -22)
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
    }
}

extension UITableViewCell {
    func backgroundAddRecent(person: HKPerson) {
        do {
            let recentIndexCount = RecentPeople.recents.first?.recentIndex ?? Int(0.5)
            let realm = try Realm()
            realm.beginWrite()
            person.recent = true
            person.recentIndex = recentIndexCount + 1
            try realm.commitWrite()
            print("added \(person.fullName) to recents")
        } catch {
            print("Something went wrong!")
        }
    }
    
    func backgroundAddFavorite(person: HKPerson) {
        do {
            let favIndexCount = FavPeople.favorites.first?.favIndex ?? Int(0.5)
            let realm = try Realm()
            realm.beginWrite()
            person.favorite = true
            person.favIndex = favIndexCount + 1
            try realm.commitWrite()
            print("added \(person.fullName) to favorites")
        } catch {
            print("Something went wrong!")
        }
    }
    
    func backgroundRemoveFavorite(person: HKPerson) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            person.favorite = false
            try realm.commitWrite()
            print("removed \(person.fullName) from favorites")
        } catch {
            print("Something went wrong!")
        }
    }
}

extension UIViewController {
    func executeUserActivityPerson(hkPerson: String, activity: NSUserActivity) {
        switch activity.activityType {
        case ActivityKeys.ChoosePerson:
            if let person = try! Realm().objectForPrimaryKey(HKPerson.self, key: hkPerson) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
                
                backgroundAddRecent(person)
                
                var imageBG: UIImage!
                var image: UIImage!
                
                if person.avatar.length != 0 {
                    imageBG = UIImage(data: person.avatar)
                    image = imageBG
                    pickedInitials = ""
                } else {
                    imageBG = UIImage(named: "placeBG")
                    image = UIImage(data: person.avatarColor)
                    pickedInitials = person.initials
                }
                let name = person.fullName
                pickedPerson = hkPerson
                pickedName = name
                pickedBG = imageBG
                pickedImage = image
                
                // Phone Numbers
                if let _ = person.phoneNumbers.first as HKPhoneNumber! {
                    if person.phoneNumbers.count > 0 {
                        for phone in person.phoneNumbers {
                            let profilePhoneNumber = phone.formattedNumber
                            if let profileLabel = phone.label as String! {
                                let localPhone = [profileLabel: profilePhoneNumber]
                                phonesProfileArray.append(localPhone)
                            } else {
                                let profileLabel = "phone"
                                let localPhone = [profileLabel: profilePhoneNumber]
                                phonesProfileArray.append(localPhone)
                            }
                        }
                    }
                }
                
                // Emails
                
                if let _ = person.emails.first as HKEmail! {
                    if person.emails.count > 0 {
                        for email in person.emails {
                            let currentEmail = email as HKEmail!
                            let profileEmailString: String = profileEmail(currentEmail.email)
                            let localEmail = ["email": profileEmailString]
                            emailsProfileArray.append(localEmail)
                        }
                    }
                }
                
                let company = person.company
                pickedCompany = company
                
                let jobTitle = person.jobTitle
                pickedTitle = jobTitle
                
                vc.selectedPerson = pickedPerson
                vc.image = pickedImage
                vc.imageBG = pickedBG
                vc.nameLabel = pickedName
                vc.coLabel = pickedCompany
                vc.jobTitleLabel = pickedTitle
                vc.initials = pickedInitials
                
                self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                dispatch_async(dispatch_get_main_queue()) {
                    self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
                }
            } else {
                let message = "This person's profile is not currently available. Please try again."
                let alertView = UIAlertController(title: "Sorry!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
                }
                alertView.addAction(okAction)
                presentViewController(alertView, animated: true, completion: nil)
            }
        default:
            let message = "The connection to your other device may have been interrupted. Please try again."
            let alertView = UIAlertController(title: "Handoff Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alertView.addAction(okAction)
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func backgroundAddRecent(person: HKPerson) {
        do {
            let recentIndexCount = RecentPeople.recents.first?.recentIndex ?? Int(0.5)
            let realm = try Realm()
            realm.beginWrite()
            person.recent = true
            person.recentIndex = recentIndexCount + 1
            
            try realm.commitWrite()
            print("added \(person.fullName) to recents")
        } catch {
            print("Something went wrong!")
        }
    }
    
    func backgroundAddFavorite(person: HKPerson) {
        do {
            let favIndexCount = FavPeople.favorites.first?.favIndex ?? Int(0.5)
            let realm = try Realm()
            realm.beginWrite()
            person.favorite = true
            person.favIndex = favIndexCount + 1
            
            do {
                try realm.commitWrite()
            } catch {
                print("Something went wrong!")
            }
            print("added \(person.fullName) to favorites")
        } catch {
            print("Something went wrong!")
        }
    }
    
    func backgroundRemoveFavorite(person: HKPerson) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            person.favorite = false
            try realm.commitWrite()
            print("removed \(person.fullName) from favorites")
        } catch {
            print("Something went wrong!")
        }
    }
    
    func profilePhone(number: String) -> String {
        var phoneNumber: String!
        if let labelIndex = number.characters.indexOf(":") {
            phoneNumber = number.substringFromIndex(labelIndex.successor())
        }
        return phoneNumber
    }
    
    func profilePhoneLabel(number: String) -> String {
        var phoneLabel: String!
        if let labelIndex = number.characters.indexOf(":") {
            let label: String = number.substringToIndex(labelIndex)
            phoneLabel = label
        } else {
            phoneLabel = "phone:"
        }
        return phoneLabel
    }
    
    func profileEmail(email: String) -> String {
        var emailString: String!
        if let labelIndex = email.characters.indexOf(":") {
            emailString = email.substringFromIndex(labelIndex.successor())
        } else {
            emailString = "\(email)"
        }
        return emailString
    }
    
    func executeUserActivity(url: NSURL, activity: NSUserActivity) {
        switch activity.activityType {
        case ActivityKeys.ChooseCall:
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            } else {
                let message = "This phone number is not currently available. Please try again."
                let alertView = UIAlertController(title: "Sorry!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
                }
                alertView.addAction(okAction)
                presentViewController(alertView, animated: true, completion: nil)
            }
        case ActivityKeys.ChooseText:
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            } else {
                let message = "This phone number is not currently available. Please try again."
                let alertView = UIAlertController(title: "Sorry!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
                }
                alertView.addAction(okAction)
                presentViewController(alertView, animated: true, completion: nil)
            }
        case ActivityKeys.ChooseEmail:
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            } else {
                let message = "This email address is not currently available. Please try again."
                let alertView = UIAlertController(title: "Sorry!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
                }
                alertView.addAction(okAction)
                presentViewController(alertView, animated: true, completion: nil)
            }
        default:
            let message = "The connection to your other device may have been interrupted. Please try again."
            let alertView = UIAlertController(title: "Handoff Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alertView.addAction(okAction)
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
}

