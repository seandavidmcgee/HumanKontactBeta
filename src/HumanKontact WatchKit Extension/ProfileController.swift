//
//  ProfileController.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/9/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

class ProfileController: WKInterfaceController {
    @IBOutlet weak var profileBG: WKInterfaceGroup!
    @IBOutlet weak var contactType: WKInterfaceLabel!
    @IBOutlet weak var contactAvatar: WKInterfaceImage!
    @IBOutlet weak var contactFirstName: WKInterfaceLabel!
    @IBOutlet weak var contactLastName: WKInterfaceLabel!
    @IBOutlet weak var contactInitials: WKInterfaceLabel!
    @IBOutlet weak var contactInitialsGroup: WKInterfaceGroup!
    @IBOutlet weak var contactInitialsAvatar: WKInterfaceGroup!
    @IBOutlet weak var contactPhone: WKInterfaceLabel!
    @IBOutlet weak var contactCall: WKInterfaceGroup!
    @IBOutlet weak var contactText: WKInterfaceGroup!
    @IBOutlet weak var contactAvatarGroup: WKInterfaceGroup!
    
    var firstName: String!
    var lastName: String!
    var avatar: NSData!
    var initials: String!
    var color: UIColor!
    var phones: List<HKPhoneNumber>!
    var phoneString: String!
    var profilePhoneString: String!
    var profilePhoneLabelString: String!
    var currentPage: Int = 1
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        firstName = (context as! NSDictionary)["firstName"] as? String
        lastName = (context as! NSDictionary)["lastName"] as? String
        avatar = (context as! NSDictionary)["avatar"] as? NSData
        initials = (context as! NSDictionary)["initials"] as? String
        color = (context as! NSDictionary)["color"] as? UIColor
        phones = ((context as! NSDictionary)["phone"] as? List<HKPhoneNumber>)!
        
        contactName()
        avatarView()
        profilePhones()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func callPhone() {
        forwardCall(profilePhoneString)
        presentControllerWithName("Handoff", context: nil)
    }
    
    @IBAction func textPhone() {
        forwardText(profilePhoneString)
        presentControllerWithName("Handoff", context: nil)
    }
    
    func contactName() {
        if firstName != nil && lastName != nil {
            self.contactFirstName.setText(firstName)
            self.contactLastName.setText(lastName)
            self.contactFirstName.setTextColor(color)
            self.contactLastName.setTextColor(color)
        } else if firstName != nil && lastName == nil {
            self.contactFirstName.setText(firstName)
            self.contactFirstName.setTextColor(color)
        } else {
            self.contactLastName.setText(lastName)
            self.contactLastName.setTextColor(color)
        }
    }
    
    func avatarView() {
        if avatar != nil {
            self.contactAvatarGroup.setBackgroundColor(color)
            self.contactAvatar.setImageData(avatar)
            self.contactAvatar.setHidden(false)
            self.contactInitialsGroup.setHidden(true)
        } else {
            self.contactAvatarGroup.setHidden(true)
            self.contactInitialsAvatar.setHidden(false)
            self.contactInitialsAvatar.setBackgroundColor(color)
            self.contactInitials.setText(initials)
        }
    }
    
    func forwardCall(forwardText: String) {
        var contactNumber = callNumber(forwardText)
        var phoneCallURL = NSURL(string: "tel://\(contactNumber)")!
        updateUserActivity(ActivityKeys.ChooseCall, userInfo: ["current": phoneCallURL], webpageURL: nil)
    }
    
    func forwardText(forwardText: String) {
        var contactNumber = callNumber(forwardText)
        var phoneCallURL = NSURL(string: "sms://\(contactNumber)")!
        updateUserActivity(ActivityKeys.ChooseText, userInfo: ["current": phoneCallURL], webpageURL: nil)
    }
    
    func callNumber(sender: String) -> String {
        var phoneNumber = sender
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return cleanNumber
    }
    
    func profilePhones() {
        if let hkPhone = phones.first as HKPhoneNumber! {
            phoneString = hkPhone.formattedNumber
            profilePhoneString = profilePhone(phoneString)
            profilePhoneLabelString = profilePhoneLabel(phoneString)
                switch profilePhoneLabelString {
                    case "mobile":
                        contactCall.setBackgroundImageNamed("WatchMobile")
                        contactText.setBackgroundImageNamed("WatchMessage")
                    case "work":
                        contactCall.setBackgroundImageNamed("WatchWork")
                    case "home":
                        contactCall.setBackgroundImageNamed("WatchHome")
                    case "main":
                        contactCall.setBackgroundImageNamed("WatchHome")
                    case "iPhone":
                        contactCall.setBackgroundImageNamed("WatchiPhone")
                        contactText.setBackgroundImageNamed("WatchMessageiPhone")
                    default:
                        contactCall.setBackgroundImageNamed("WatchHome")
                }
            self.contactType.setText(profilePhoneLabelString)
            self.contactPhone.setText(profilePhoneString)
        } else {
            self.contactPhone.setText("")
        }
    }
    
    func profilePhone(number: String) -> String {
        let rangeOfLabel = number.rangeOfString(":")
        var phoneNumber: String!
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            phoneNumber = number.substringFromIndex(labelIndex + 1)
        }
        return phoneNumber
    }
    
    func profilePhoneLabel(number: String) -> String {
        let rangeOfLabel = number.rangeOfString(":")
        var phoneLabel: String!
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            phoneLabel = label
        } else {
            phoneLabel = "phone"
        }
        return phoneLabel
    }
}