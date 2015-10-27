//
//  HKIndex.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/27/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class HKIndex: Object {
    dynamic var globalIndex: Int = 0
    dynamic var sectionIndex: Int = 0
    dynamic var sectionTitle = ""
    
    override class func primaryKey() -> String {
        return "sectionTitle"
    }
}