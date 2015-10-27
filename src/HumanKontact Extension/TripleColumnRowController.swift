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

extension Contact: CustomStringConvertible {
    var description: String {
        return "Contact(\(name)) + Contact(\(initials)) + Contact(\(avatar)) + Contact(\(color))"
    }
}

func avatarName(firstName: String, lastName: String) -> String {
    var first: String = ""
    var last: String = ""
    if (firstName.characters.count != 0 && lastName.characters.count != 0) {
        let firstChar = firstName.characters.first!
        first = ("\(firstChar)").capitalizedString
        let lastChar = lastName.characters.first!
        last = ("\(lastChar)").capitalizedString
    } else if (firstName.characters.count != 0 && lastName.characters.count == 0) {
        let index = firstName.startIndex.advancedBy(2)
        let firstChar = firstName.substringToIndex(index)
        first = ("\(firstChar)").capitalizedString
        last = ""
    } else if (firstName.characters.count == 0 && lastName.characters.count != 0) {
        let index = lastName.startIndex.advancedBy(2)
        let firstChar = lastName.substringToIndex(index)
        first = ("\(firstChar)").capitalizedString
        last = ""
    } else {
        first = ""
        last = ""
    }
    return first + last
}

func avatarInitials(firstName: String, lastName: String) -> String {
    var first: String = ""
    var last: String = ""
    if (firstName.characters.count != 0 && lastName.characters.count != 0) {
        let firstChar = firstName.characters.first!
        first = ("\(firstChar)").capitalizedString
        let lastChar = lastName.characters.first!
        last = ("\(lastChar)").capitalizedString
    } else if (firstName.characters.count != 0 && lastName.characters.count == 0) {
        let index = firstName.startIndex.advancedBy(2)
        let firstChar = firstName.substringToIndex(index)
        first = ("\(firstChar)").capitalizedString
        last = ""
    } else if (firstName.characters.count == 0 && lastName.characters.count != 0) {
        let index = lastName.startIndex.advancedBy(2)
        let firstChar = lastName.substringToIndex(index)
        first = ("\(firstChar)").capitalizedString
        last = ""
    } else {
        first = ""
        last = ""
    }
    return first + last
}