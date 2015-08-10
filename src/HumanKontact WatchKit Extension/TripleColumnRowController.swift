//
//  TripleColumnRowController.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

struct Contact {
    //let id: String
    var name: String
    var initials: String
    var avatar: NSData
    var color: UIColor
    
    init(name: String, initials: String, avatar: NSData, color: UIColor) {
        self.name = name
        self.initials = initials
        self.avatar = avatar
        self.color = color
    }
}

extension Contact: Printable {
    var description: String {
        return "Contact(\(name)) + Contact(\(initials)) + Contact(\(avatar)) + Contact(\(color))"
    }
}

func contactList() -> [Contact] {
    let realm = ABWatchManager.abRealm()
    var people: Results<HKPerson>
    people = realm.objects(HKPerson).sorted("fullName", ascending: true)
    var contactIndex: Int = Int()
    var avatarColors : Array<UInt32> = [0x2A93EB, 0x07E36D, 0xFF9403]
    var hkPerson0 = people[0] as HKPerson
    var hkPerson1 = people[1] as HKPerson
    var hkPerson2 = people[2] as HKPerson
    var contactName0 = avatarName(hkPerson0.firstName, hkPerson0.lastName)
    var contactName1 = avatarName(hkPerson1.firstName, hkPerson1.lastName)
    var contactName2 = avatarName(hkPerson2.firstName, hkPerson2.lastName)
    var contactInit0 = avatarInitials(hkPerson0.firstName, hkPerson0.lastName)
    var contactInit1 = avatarInitials(hkPerson1.firstName, hkPerson1.lastName)
    var contactInit2 = avatarInitials(hkPerson2.firstName, hkPerson2.lastName)
    
    return [
        //Contact(name: "\(contactName0)", initials: "\(contactInit0)", avatar: hkPerson0.avatar , color: UIColor(hex: avatarColors[0])),
        //Contact(name: "\(contactName1)", initials: "\(contactInit1)", avatar: hkPerson1.avatar , color: UIColor(hex: avatarColors[1])),
        //Contact(name: "\(contactName2)", initials: "\(contactInit2)", avatar: hkPerson2.avatar , color: UIColor(hex: avatarColors[2]))
    ]
}

    func avatarName(firstName: String, lastName: String) -> String {
        var first: String = ""
        var last: String = ""
        if (count(firstName) > 5 && count(firstName) != 0 && count(lastName) != 0) {
            first = firstName[0]
            last = lastName[0]
        } else if (count(firstName) <= 5 && count(firstName) != 0 && count(lastName) != 0) {
            first = "\(firstName) "
            last = lastName[0]
        } else if (count(firstName) != 0 && count(lastName) == 0) {
            first = "\(firstName)"
        } else {
            first = ""
            last = ""
        }
        return first + last
    }
    
    func avatarInitials(firstName: String, lastName: String) -> String {
        var first: String = ""
        var last: String = ""
        if (count(firstName) != 0 && count(lastName) != 0) {
            first = firstName[0]
            last = lastName[0]
        } else if (count(firstName) != 0 && count(lastName) == 0) {
            first = firstName[0]
            last = firstName[1]
        } else {
            first = ""
            last = ""
        }
        return first + last
}