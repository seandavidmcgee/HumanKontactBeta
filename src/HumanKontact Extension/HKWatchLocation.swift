//
//  HKWatchLocation.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/21/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import RealmSwift
import Foundation

class Location: Object {
    dynamic var uuid = NSUUID().UUIDString
    
    dynamic var name           = ""
    dynamic var note           = ""
    dynamic var aptNo          = ""
    dynamic var floorNo        = ""
    dynamic var entranceNo     = ""
    dynamic var houseNo        = ""
    dynamic var street         = ""
    dynamic var city           = ""
    dynamic var province       = ""
    dynamic var postalCode     = ""
    dynamic var country: String = Location.currentCountry()
    
    dynamic var latitude       = 0.0
    dynamic var longitude      = 0.0
    
    class func currentCountry() -> String{
        let locale = NSLocale.currentLocale()
        let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String
        return locale.displayNameForKey(NSLocaleCountryCode, value: countryCode) ?? ""
    }
    
    dynamic var distance: CLLocationDistance = 0
    
    override static func ignoredProperties() -> [String] {
        return ["location", "coordinate"]
    }
    override class func primaryKey() -> String? {
        return "uuid"
    }
}
