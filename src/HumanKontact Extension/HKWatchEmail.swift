//
//  HKWatchEmail.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/20/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import Foundation
import Contacts
import RealmSwift

class HKEmail: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var email = ""
    dynamic var label = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
}
