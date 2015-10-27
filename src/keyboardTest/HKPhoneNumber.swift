//
//  HKPhoneNumber.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import RealmSwift

class HKPhoneNumber: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var number = ""
    dynamic var formattedNumber: String = ""
    dynamic var label = ""
    
    override class func primaryKey() -> String {
        return "uuid"
    }
}

class ABPhoneUtility: NSObject {
    class func normalizedPhoneStringFromString(phoneString: NSString?) -> NSString {
        let phoneNumber: String! = phoneString as? String
        let strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil)
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber = cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return cleanNumber.copy() as! NSString
    }
    
    class func normalizedPhoneLabelFromString(phoneString: NSString?) -> NSString {
        let phoneLabel: String! = phoneString as? String
        let strippedPhoneLabel = phoneLabel.stringByReplacingOccurrencesOfString("[^a-zA-Z ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil)
        var cleanLabel = strippedPhoneLabel.removeWhitespace()
        cleanLabel = cleanLabel.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return cleanLabel.copy() as! NSString
    }
}
