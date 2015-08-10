//
//  Utilities.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/7/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation

func random(n: Int) -> Int {
    return Int(arc4random_uniform(UInt32(n)))
}

protocol Context {
    typealias DelType
    typealias ObjType
    var delegate: DelType? { get set }
    var object: ObjType? { get set }
}

//class SearchControllerContext: Context {
    //typealias DelType = SearchControllerDelegate
    //typealias ObjType = Contact
    //var delegate: DelType?
    //weak var object: ObjType?
//}

protocol SearchControllerDelegate  {
    func didSelectContact(contact: Contact)
}

struct People {
    static var people = realm.objects(HKPerson)
}

extension Array {
    /// Returns first `n` elements of the array
    /// (Less if the array doesn't have that many)
    
    func limit(n: Int) -> [Element] {
        precondition(n >= 0)
        if self.count <= n {
            return self
        } else {
            return Array(self[0..<n])
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if (cString.hasPrefix("0X")) {
            cString = (cString as NSString).substringFromIndex(2)
        }
        if (count(cString) != 6) {
            self.init(white: 0.0, alpha: 1.0)
        } else {
            var rgbValue: UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)
            
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0))
        }
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
    
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = find(self, char) {
            return distance(self.startIndex, idx)
        }
        return nil
    }
    
    func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

extension UInt {
    init?(_ string: String, radix: UInt) {
        let digits = "0123456789abcdefghijklmnopqrstuvwxyz"
        var result = UInt(0)
        for digit in string.lowercaseString {
            if let range = digits.rangeOfString(String(digit)) {
                let val = UInt(distance(digits.startIndex, range.startIndex))
                if val >= radix {
                    return nil
                }
                result = result * radix + val
            } else {
                return nil
            }
        }
        self = result
    }
}

extension WKInterfaceImage {
    
    
}

extension WKInterfaceController {
    
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
    
    func roundUp(value: Int, divisor: Int) -> Int {
        let rem = value % divisor
        return rem == 0 ? value : value + divisor - rem
    }
    
    func roundDown(value: Int, divisor: Int) -> Int {
        let rem = value % divisor
        if (value % 3 == 1)  {
            return rem == 0 ? value : value - divisor + 2
        } else {
            return rem == 0 ? value : value - divisor + 1
        }
    }
    
    func roundToFour(value: Int) -> Int{
        var fractionNum = Double(value) / 4.0
        roundedNum = Int(floor(fractionNum))
        return roundedNum * 4
    }
    
    func remFromFour(value: Int) -> Int{
        let rem = value % 4
        return rem
    }
    
    func avatarProfileColor(value: Int) -> Int {
        let rem = value % 3
        let rems = value % 12
        var index: Int!
        if rem == 0 {
            if value % 3 == 0 && value < 9 {
                index = value
            } else {
                index = rems
            }
        }
        if rem == 1 {
            if value % 3 == 1 && value < 9 {
                index = value
            } else {
                index = rems
            }
        }
        if rem == 2 {
            if value % 3 == 2 && value < 9 {
                index = value
            } else {
                index = rems
            }
        }
        return index
    }
}

extension SearchController {
    internal func setImageWithData(sender: WKInterfaceImage!, data: NSData) -> WKInterfaceImage? {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            sender.setImageData(data)
        }
        return sender
    }
    
    internal func populateTableAvatars(index: Int) {
        autoreleasepool({ () -> () in
            var colorIndex = avatarProfileColor(index)
            var hkPerson = People.people[Int(index)] as HKPerson

            contact = roundDown(index, divisor: 3) / 3
            if let hkAvatar = hkPerson.avatar as NSData! {
                if let person = contactsTable.rowControllerAtIndex(contactIndex) as? TripleColumnRowController {
                    if hkAvatar.length > 0 {
                        if index % 3 == 0 || index == 0 {
                            person.leftButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.leftButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.leftButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                        }
                        if index % 3 == 1 || index == 1 {
                            person.centerButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.centerButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.centerButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                        }
                        if index % 3 == 2 || index == 2 {
                            person.rightButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.rightButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.rightButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                        }
                    } else {
                        if index % 3 == 0 || index == 0 {
                            person.leftButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.leftButtonOutline.setBackgroundColor(.clearColor())
                            person.leftContactImage.setHidden(true)
                            person.leftButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.leftButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                            person.leftInitials.setText(avatarInitials(hkPerson.firstName, lastName: hkPerson.lastName))
                        }
                        if index % 3 == 1 || index == 1{
                            person.centerButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.centerButtonOutline.setBackgroundColor(.clearColor())
                            person.centerContactImage.setHidden(true)
                            person.centerButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.centerButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                            person.centerInitials.setText(avatarInitials(hkPerson.firstName, lastName: hkPerson.lastName))
                        }
                        if index % 3 == 2 || index == 2 {
                            person.rightButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.rightButtonOutline.setBackgroundColor(.clearColor())
                            person.rightContactImage.setHidden(true)
                            person.rightButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.rightButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                            person.rightInitials.setText(avatarInitials(hkPerson.firstName, lastName: hkPerson.lastName))
                        }
                    }
                }
            }
        })
    }
}

extension ResultsController {
    internal func setImageWithData(sender: WKInterfaceImage!, data: NSData) -> WKInterfaceImage? {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            sender.setImageData(data)
        }
        return sender
    }
    
    internal func populateTableAvatars(index: Int) {
        autoreleasepool({ () -> () in
            var colorIndex = avatarProfileColor(index)
            var hkPerson = People.people[Int(index)] as HKPerson
            contact = roundDown(index, divisor: 3) / 3
            if let hkAvatar = hkPerson.avatar as NSData! {
                if let person = contactsTable.rowControllerAtIndex(contactIndex) as? TripleColumnRowController {
                    if hkAvatar.length > 0 {
                        if index % 3 == 0 || index == 0 {
                            person.leftButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.leftButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.leftButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                        }
                        if index % 3 == 1 || index == 1 {
                            person.centerButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.centerButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.centerButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                        }
                        if index % 3 == 2 || index == 2 {
                            person.rightButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.rightButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.rightButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                        }
                    } else {
                        if index % 3 == 0 || index == 0 {
                            person.leftButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.leftButtonOutline.setBackgroundColor(.clearColor())
                            person.leftContactImage.setHidden(true)
                            person.leftButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.leftButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                            person.leftInitials.setText(avatarInitials(hkPerson.firstName, lastName: hkPerson.lastName))
                        }
                        if index % 3 == 1 || index == 1{
                            person.centerButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.centerButtonOutline.setBackgroundColor(.clearColor())
                            person.centerContactImage.setHidden(true)
                            person.centerButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.centerButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                            person.centerInitials.setText(avatarInitials(hkPerson.firstName, lastName: hkPerson.lastName))
                        }
                        if index % 3 == 2 || index == 2 {
                            person.rightButtonGroup.setBackgroundColor(UIColor(hex: hkPerson.nameColor))
                            person.rightButtonOutline.setBackgroundColor(.clearColor())
                            person.rightContactImage.setHidden(true)
                            person.rightButtonName.setText(avatarName(hkPerson.firstName, lastName: hkPerson.lastName))
                            person.rightButtonName.setTextColor(UIColor(hex: hkPerson.nameColor))
                            person.rightInitials.setText(avatarInitials(hkPerson.firstName, lastName: hkPerson.lastName))
                        }
                    }
                }
            }
        })
    }
}
