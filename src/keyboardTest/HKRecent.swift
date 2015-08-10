//
//  HKRecent.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class HKRecent : Object {
    dynamic var fullName = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var avatar: NSData! = NSData()
    dynamic var initials = ""
    dynamic var jobTitle = ""
    dynamic var company = ""
    dynamic var created = NSDate()
    
    dynamic var phoneNumbers = List<HKPhoneNumber>()
    dynamic var emails = List<HKEmail>()
    
    override class func primaryKey() -> String {
        return "fullName"
    }
    var image: UIImage? {
        get {
            if let img = UIImage(data: avatar) {
                return img
            }
            avatar = UIImagePNGRepresentation(UIImage(named: "placeholder"))
            return UIImage(data: avatar)
        }
    }
}
