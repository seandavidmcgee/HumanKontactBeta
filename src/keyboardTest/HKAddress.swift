//
//  HKAddress.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/20/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import RealmSwift

class Address: Location {
    
    dynamic var label = kABHomeLabel as! String
    
    var person: HKPerson? {
        // Inverse relationship
        let addresses = linkingObjects(HKPerson.self, forProperty: "addresses")
        return addresses.first
    }
}

