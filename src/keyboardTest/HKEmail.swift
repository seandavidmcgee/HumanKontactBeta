//
//  HKEmail.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import RealmSwift

class HKEmail: Object {
    dynamic var email: String = ""
    
    override class func primaryKey() -> String {
        return "email"
    }
}
