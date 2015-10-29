//
//  SingletonManager.swift
//  keyboardTest
//
//  Created by Sean McGee on 9/7/15.
//  Copyright (c) 2015 Kannuu. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GlobalVariables {
    
    // These are the properties you can store in your singleton
    var keyboardFirst : Bool = true
    let avatarColors : Array<UInt32> = [0x2A93EB, 0x07E36D, 0xFF9403, 0x9E80FF, 0xACF728, 0xFF5968, 0x17BAF0, 0xF7F00E, 0xFA8EC7, 0xE41931, 0x04E5E0, 0xBD10E0]
    let nameColors : Array<String> = ["0x2A93EB", "0x07E36D", "0xFF9403", "0x9E80FF", "0xACF728", "0xFF5968", "0x17BAF0", "0xF7F00E", "0xFA8EC7", "0xE41931", "0x04E5E0", "0xBD10E0"]
    var searchControllerArray : [UIViewController] = []
    let controller = KeyboardViewController()
    let master = MasterSearchController()
    var lastModified = NSDate()
    var recordsModified = Int()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var myResults = [AnyObject]()
    var objectKeys = [AnyObject]()
    var sortOrdering = "alpha"
    var realm = RealmManager.setupRealmInApp()
    
    // Here is how you would get to it without there being a global collision of variables.
    // It is a globally accessable parameter that is specific to the class.
    
    class var sharedManager: GlobalVariables {
        struct Static {
            static let instance = GlobalVariables()
        }
        
        return Static.instance
    }
}
