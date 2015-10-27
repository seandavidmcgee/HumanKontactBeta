//
//  HKWatchSimpleNote.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/21/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import RealmSwift

class SimpleNote: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var date = NSDate()//NSDate.distantPast() as! NSDate
    dynamic var text = ""
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
}
