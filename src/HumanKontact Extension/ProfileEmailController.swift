//
//  ProfileEmailController.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/20/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

class ProfileEmailController: WKInterfaceController {
    @IBOutlet weak var profileBG: WKInterfaceGroup!
    @IBOutlet weak var contactType: WKInterfaceLabel!
    @IBOutlet weak var contactAvatar: WKInterfaceImage!
    @IBOutlet weak var contactFirstName: WKInterfaceLabel!
    @IBOutlet weak var contactLastName: WKInterfaceLabel!
    @IBOutlet weak var contactInitials: WKInterfaceLabel!
    @IBOutlet weak var contactInitialsGroup: WKInterfaceGroup!
    @IBOutlet weak var contactInitialsAvatar: WKInterfaceGroup!
    @IBOutlet weak var contactEmail: WKInterfaceButton!
    @IBOutlet weak var contactEmailLabel: WKInterfaceLabel!
    @IBOutlet weak var contactAvatarGroup: WKInterfaceGroup!
    @IBOutlet weak var emailSecondGroup: WKInterfaceGroup!
    
    var firstName: String! = ""
    var lastName: String! = ""
    var avatar: NSData!
    var initials: String!
    var color: UIColor!
    var emails: List<HKEmail>!
    var profileEmailString: String!
    var secondProfileEmailString: String!
    var person: String!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        firstName = (context as! NSDictionary)["firstName"] as? String
        lastName = (context as! NSDictionary)["lastName"] as? String
        avatar = (context as! NSDictionary)["avatar"] as? NSData
        initials = (context as! NSDictionary)["initials"] as? String
        color = (context as! NSDictionary)["color"] as? UIColor
        emails = ((context as! NSDictionary)["email"] as? List<HKEmail>)!
        person = (context as! NSDictionary)["person"] as? String
        
        contactName()
        avatarView()
        profileEmails()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func emailContact() {
        forwardEmail(profileEmailString)
        //presentControllerWithName("Handoff", context: nil)
    }
    
    @IBAction func secondEmailContact() {
        forwardEmail(secondProfileEmailString)
        //presentControllerWithName("Handoff", context: nil)
    }
    
    @IBAction func goToPersonOnPhone() {
        forwardPerson(person)
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
    
    func forwardEmail(forwardText: String) {
        if let emailURL = NSURL(string: "sms://\(forwardText)") {
            let application = WKExtension.sharedExtension()
            application.openSystemURL(emailURL)
        }
    }
    
    func forwardPerson(forwardPerson: String) {
        let personProfile = forwardPerson
        updateUserActivity(ActivityKeys.ChoosePerson, userInfo: ["person": personProfile], webpageURL: nil)
    }
    
    func profileEmails() {
        if let hkEmail = emails.first as HKEmail! {
            if emails.count > 1 {
                self.emailSecondGroup.setHidden(false)
                for (index, email) in emails.enumerate() {
                    if index == 0 {
                        profileEmailString = profileEmail(email.email)
                    }
                    if index == 1 {
                        secondProfileEmailString = profileEmail(email.email)
                    }
                    self.contactEmailLabel.setText(profileEmailString)
                }
            } else {
                let currentEmail = hkEmail.email
                profileEmailString = profileEmail(currentEmail)
                self.contactEmailLabel.setText(profileEmailString)
            }
        } else {
            self.contactEmailLabel.setText("")
        }
    }
    
    func profileEmail(email: String) -> String {
        var emailString: String!
        if let labelIndex = email.characters.indexOf(":") {
            let label: String = email.substringToIndex(labelIndex)
            self.contactType.setText(label)
            emailString = email.substringFromIndex(labelIndex.successor())
        } else {
            self.contactType.setText("email")
            emailString = "\(email)"
        }
        return emailString
    }
}