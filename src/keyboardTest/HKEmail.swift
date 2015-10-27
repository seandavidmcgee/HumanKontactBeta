//
//  HKEmail.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import RealmSwift

class HKEmail: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var email = ""
    dynamic var label = kABHomeLabel as! String
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
}
