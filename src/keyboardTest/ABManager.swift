//
//  ABManager.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import RealmSwift

class ABManager : NSObject, NilLiteralConvertible {
    var ab = RHAddressBook()
    var indexedRHPeople: [RHPerson] = [RHPerson]()
    var indexedRHPeopleSort: [AnyObject]! = []
    var hkPersonIndex: Int = 0
    var hkColorIndex: Int = 0
    
    required init(nilLiteral: ()) {
        super.init()
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "addressBookDidChange:",
            name: RHAddressBookExternalChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    class func abRealm() -> Realm {
        // Switch return statements for in-memory vs. persisted Realms
        //return Realm(inMemoryIdentifier: "OSTABManagerRealm")
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.kannuu.humankontact")!
        let realmPath = directory.path!.stringByAppendingPathComponent("default.realm")
        Realm.defaultPath = realmPath
        return Realm(path: Realm.defaultPath)
    }
    
    class func recentRealm() -> Realm {
        // Switch return statements for in-memory vs. persisted Realms
        //return Realm(inMemoryIdentifier: "OSTABManagerRealm")
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.kannuu.humankontact")!
        let realmPath = directory.path!.stringByAppendingPathComponent("recent.realm")
        Realm.defaultPath = realmPath
        return Realm(path: Realm.defaultPath)
    }
    
    class func favoriteRealm() -> Realm {
        // Switch return statements for in-memory vs. persisted Realms
        //return Realm(inMemoryIdentifier: "OSTABManagerRealm")
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.kannuu.humankontact")!
        let realmPath = directory.path!.stringByAppendingPathComponent("favorite.realm")
        Realm.defaultPath = realmPath
        return Realm(path: Realm.defaultPath)
    }
    
    func addressBookDidChange(notification: NSNotification) {
        println("address book changed via notification: \(notification)")
        indexRecords(nil, failure: nil)
        copyRecords(nil, failure: nil)
        favoriteRecords(nil, failure: nil)
    }
    
    func hasPermission() -> Bool {
        if RHAddressBook.authorizationStatus() == RHAuthorizationStatus.Authorized {
            return RHAddressBook.authorizationStatus() == RHAuthorizationStatus.Authorized
        }
        return RHAddressBook.authorizationStatus() == RHAuthorizationStatus.Denied
    }
    
    func sortedRecords(success:(()->())?, failure:((message: String)->())?) {
        if hasPermission() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for index in 0..<myResults.count {
                    var name = myResults[index] as! String
                    var filteredIndexArray : [AnyObject]! = self.ab.peopleWithName(name)
                    self.indexedRHPeopleSort.append(filteredIndexArray[0])
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    println("success")
                    success?()
                })
            })
        } else {
            failure?(message: "To utilize HumanKontact you must provide permission for the app to access your contacts under Settings > Privacy > Contacts.")
        }
    }
    
    func indexRecords(success:(()->())?, failure:((message: String)->())?) {
        if hasPermission() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let backgroundRealm = ABManager.abRealm()
                let people = self.indexedRHPeopleSort as! [RHPerson]
                backgroundRealm.write({ () -> Void in
                    for rhPerson in people {
                        self.writeRecord(realm: backgroundRealm, rhPerson: rhPerson, recent: false, fav: false, color: nil, name: nil)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("success")
                        success?()
                        self.hkPersonIndex = 0
                        self.hkColorIndex = 0
                    })
                })
            })
        } else {
            failure?(message: "To utilize HumanKontact you must provide permission for the app to access your contacts under Settings > Privacy > Contacts.")
        }
    }
    
    func copyRecords(success:(()->())?, failure:((message: String)->())?) {
        if hasPermission() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let backgroundRealm = ABManager.recentRealm()
                let people = recentPeople as [HKPerson]
                backgroundRealm.write({ () -> Void in
                    for hkPerson in people {
                        var recentPerson = self.ab.peopleWithName(hkPerson.fullName) as! [RHPerson]
                        self.writeRecord(realm: backgroundRealm, rhPerson: recentPerson[0], recent: true, fav: false, color: hkPerson.avatarColor, name: hkPerson.nameColor)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("success")
                        success?()
                        self.hkPersonIndex = 0
                        self.hkColorIndex = 0
                    })
                })
            })
        } else {
            failure?(message: "To utilize HumanKontact you must provide permission for the app to access your contacts under Settings > Privacy > Contacts.")
        }
    }
    
    func favoriteRecords(success:(()->())?, failure:((message: String)->())?) {
        if hasPermission() {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let backgroundRealm = ABManager.favoriteRealm()
                let people = favPeople as [HKPerson]
                backgroundRealm.write({ () -> Void in
                    for hkPerson in people {
                        var favPerson = self.ab.peopleWithName(hkPerson.fullName) as! [RHPerson]
                        self.writeRecord(realm: backgroundRealm, rhPerson: favPerson[0], recent: false, fav: true, color: hkPerson.avatarColor, name: hkPerson.nameColor)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("success")
                        success?()
                        self.hkPersonIndex = 0
                        self.hkColorIndex = 0
                    })
                })
            })
        } else {
            failure?(message: "To utilize HumanKontact you must provide permission for the app to access your contacts under Settings > Privacy > Contacts.")
        }
    }
    
    private func writeRecord(#realm: Realm, rhPerson: RHPerson, recent: Bool, fav: Bool, color: NSData!, name: String!) {
        var rlmPhoneNumbers = List<HKPhoneNumber>()
        if rhPerson.phoneNumbers.count != 0 {
            let rhPhoneNumbers = rhPerson.phoneNumbers.values as Array?
            for (index, rhNumber) in enumerate(rhPhoneNumbers!) {
                let formattedNumString = rhNumber as! String
                var phoneNumber = HKPhoneNumber()
                var rhIndex: UInt = UInt(index)
                if let label = rhPerson.phoneNumbers.localizedLabelAtIndex(rhIndex) {
                    phoneNumber.formattedNumber = label + ":" + formattedNumString
                } else {
                    phoneNumber.formattedNumber = "phone:" + formattedNumString
                }
                rlmPhoneNumbers.append(phoneNumber)
            }
        }
        var rlmEmails = List<HKEmail>()
        if rhPerson.emails.count != 0 {
            let rhEmails = rhPerson.emails.values as Array?
            for rhEmail in rhEmails! {
                let emailString = rhEmail as! String
                var email = HKEmail()
                email.email = emailString
                rlmEmails.append(email)
            }
        }
        
        var hkPerson = HKPerson()
        hkPerson.fullName = rhPerson.compositeName
        hkPerson.firstName = rhPerson.firstName != nil ? rhPerson.firstName : ""
        hkPerson.lastName = rhPerson.lastName != nil ? rhPerson.lastName : ""
        hkPerson.initials = profileInitials(hkPerson.firstName, lastName: hkPerson.lastName)
        hkPerson.jobTitle = rhPerson.jobTitle != nil ? rhPerson.jobTitle : ""
        hkPerson.company = rhPerson.organization != nil ? rhPerson.organization : ""
        hkPerson.phoneNumbers = rlmPhoneNumbers
        hkPerson.emails = rlmEmails
        if recent == true || fav == true {
            hkPerson.avatarColor = color!
            hkPerson.nameColor = name!
        } else {
            hkPerson.avatarColor = avatarImage(hkPersonIndex)
            hkPerson.nameColor = nameColor(hkColorIndex)
        }
        hkPerson.created = NSDate(timeIntervalSinceNow: 0)
        if rhPerson.hasImage {
            var data: NSData = rhPerson.thumbnailData
            hkPerson.avatar = data
        }
        
        // TODO: Enforce that this happens in the expected thread and transaction
        if recent == true {
            recentRealm.add(hkPerson, update: true)
        } else if fav == true {
            favRealm.add(hkPerson, update: true)
        } else {
            realm.add(hkPerson, update: true)
        }
        hkPersonIndex++
        hkColorIndex++
    }
    
    func profileInitials(firstName: String, lastName: String) -> String {
        var first: String = ""
        var last: String = ""
        if (count(firstName) != 0 && count(lastName) != 0) {
            first = firstName[0]
            first = first.capitalizedString
            last = lastName[0]
            last = last.capitalizedString
        } else if (count(firstName) != 0 && count(lastName) == 0) {
            first = firstName[0]
            first = first.capitalizedString
            last = firstName[1]
        } else if (count(firstName) == 0 && count(lastName) != 0) {
            first = lastName[0]
            first = first.capitalizedString
            last = lastName[1]
        } else {
            first = ""
            last = ""
        }
        return first + last
    }
    
    func requestAuthorization(completion:(isGranted: Bool, permissionError: NSError?)->()) {
        ab.requestAuthorizationWithCompletion { (granted, error) -> Void in
            completion(isGranted: granted, permissionError: error);
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> NSData {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        var imageData: NSData = UIImagePNGRepresentation(image)
        UIGraphicsEndImageContext()
        return imageData
    }
    
    func avatarImage(index: Int) -> NSData {
        var colorIndex = avatarProfileColor(index)
        var currentColor = avatarColors[colorIndex]
        var avatarImage = getImageWithColor(UIColor(hex: currentColor), size: CGSize(width: 150, height: 150))
        return avatarImage
    }
    
    func nameColor(index: Int) -> String {
        var colorIndex = avatarProfileColor(index)
        var currentColor = nameColors[colorIndex]
        var hexString = currentColor
        return hexString
    }
    
    func avatarProfileColor(value: Int) -> Int {
        let rems = value % 12
        return rems
    }
}
