//
//  HKWatchAddress.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/21/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import Foundation
import Contacts
import RealmSwift

class Address: Location {
    
    dynamic var label = ""
    
    var person: HKPerson? {
        // Inverse relationship
        let addresses = linkingObjects(HKPerson.self, forProperty: "addresses")
        return addresses.first
    }
}
