//
//  HKPhoneNumber.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import RealmSwift

class HKPhoneNumber: Object {
    dynamic var formattedNumber: String = ""
    
    override class func primaryKey() -> String {
        return "formattedNumber"
    }
}
