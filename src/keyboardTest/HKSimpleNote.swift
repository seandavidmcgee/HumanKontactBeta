//
//  HKSimpleNote.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/20/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import UIKit
import RealmSwift

class SimpleNote: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var date = NSDate()//NSDate.distantPast() as! NSDate
    dynamic var text = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
}
