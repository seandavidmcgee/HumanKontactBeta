//
//  SettingsViewExtensions.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension SettingsViewController: UITableViewDataSource
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}

extension SettingsViewController: UITableViewDelegate
{
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : HKContactCell = tableView.dequeueReusableCellWithIdentifier(HKContactCell.cellID, forIndexPath: indexPath) as! HKContactCell
        
        return cell
    }
}

class HKContactCell: UITableViewCell {

    @IBOutlet weak var skype: UIButton!
    @IBOutlet weak var hkFriendCardView: UIView!
    @IBOutlet weak var hkCardImageView: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var hkAvatarInitials: UILabel!
    @IBOutlet weak var hkNameLabel: UILabel!
    @IBOutlet weak var hkConnectScrollView: UIScrollView!
    @IBOutlet weak var hkConnectContainer: UIView!
    @IBOutlet weak var hkSourceView: UIView!
    @IBOutlet weak var homeCall: UIButton!
    @IBOutlet weak var workCall: UIButton!
    @IBOutlet weak var otherCall: UIButton!
    @IBOutlet weak var iPhoneCall: UIButton!
    @IBOutlet weak var mobileCall: UIButton!
    @IBOutlet weak var iPhoneTxt: UIButton!
    @IBOutlet weak var mobileTxt: UIButton!
    @IBOutlet weak var primaryEmail: UIButton!
    @IBOutlet weak var secondaryEmail: UIButton!
    
    var mobileIncluded: Bool! = false
    var workIncluded: Bool! = false
    var homeIncluded: Bool! = false
    var otherIncluded: Bool! = false
    var iPhoneIncluded: Bool! = false
    
    @IBAction func skypeCall(sender: UIButton) {
        println("pressed")
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "skype://sean.david.mcgee?call")!){
                UIApplication.sharedApplication().openURL(NSURL(string: "skype://sean.david.mcgee?call")!)
            } else {
                println("fail")
            }
    }
    
    static let cellID = "HKContactCellIdentifer"
    
    internal func phoneCell(number: String) {
        let rangeOfLabel = number.rangeOfString(":")
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            let phoneNumber: String = number.substringFromIndex(labelIndex + 1)
            switch label {
            case "home":
                if mobileIncluded == true && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                homeIncluded = true
                homeCall.setTitle(phoneNumber, forState: UIControlState.Normal)
                homeCall.hidden = false
            case "work":
                if homeIncluded == true {
                    workCall.transform = CGAffineTransformMakeTranslation(60, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                workIncluded = true
                workCall.setTitle(phoneNumber, forState: UIControlState.Normal)
                workCall.hidden = false
            case "main":
                if homeIncluded == true && workIncluded == false {
                    otherCall.transform = CGAffineTransformMakeTranslation(60, 0)
                }
                if homeIncluded == true && workIncluded == true {
                    otherCall.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                otherIncluded = true
                otherCall.setTitle(phoneNumber, forState: UIControlState.Normal)
                otherCall.hidden = false
            case "phone":
                if homeIncluded == true && workIncluded == false {
                    otherCall.transform = CGAffineTransformMakeTranslation(60, 0)
                }
                if homeIncluded == true && workIncluded == true {
                    otherCall.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                otherIncluded = true
                otherCall.setTitle(phoneNumber, forState: UIControlState.Normal)
                otherCall.hidden = false
            case "iPhone":
                if homeIncluded == false && workIncluded == false && otherIncluded == false {
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(60, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == false {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == false {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == false && workIncluded == false && otherIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(120, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(120, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == false {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(120, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == true {
                    iPhoneCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    iPhoneTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                iPhoneIncluded = true
                iPhoneCall.setTitle(phoneNumber, forState: UIControlState.Normal)
                iPhoneCall.hidden = false
                iPhoneTxt.setTitle(phoneNumber, forState: UIControlState.Normal)
                iPhoneTxt.hidden = false
            case "mobile":
                if homeIncluded == false && workIncluded == false && otherIncluded == false && iPhoneIncluded == false {
                    mobileTxt.transform = CGAffineTransformMakeTranslation(60, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == false && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == false && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == false && workIncluded == false && otherIncluded == true && iPhoneIncluded == true {
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == true && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == false && iPhoneIncluded == true {
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == true && iPhoneIncluded == true {
                    mobileCall.transform = CGAffineTransformMakeTranslation(240, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == false && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == true && iPhoneIncluded == false {
                    mobileCall.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == true && iPhoneIncluded == true {
                    mobileCall.transform = CGAffineTransformMakeTranslation(240, 0)
                    mobileTxt.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                mobileIncluded = true
                mobileCall.setTitle(phoneNumber, forState: UIControlState.Normal)
                mobileCall.hidden = false
                mobileTxt.setTitle(phoneNumber, forState: UIControlState.Normal)
                mobileTxt.hidden = false
            default:
                break
            }
        }
    }
    override func prepareForReuse() {
        homeCall.hidden = true
        homeCall.setTitle("", forState: UIControlState.Normal)
        workCall.hidden = true
        workCall.setTitle("", forState: UIControlState.Normal)
        workCall.transform = CGAffineTransformMakeTranslation(0, 0)
        otherCall.hidden = true
        otherCall.setTitle("", forState: UIControlState.Normal)
        otherCall.transform = CGAffineTransformMakeTranslation(0, 0)
        iPhoneCall.hidden = true
        iPhoneCall.setTitle("", forState: UIControlState.Normal)
        iPhoneCall.transform = CGAffineTransformMakeTranslation(0, 0)
        mobileCall.hidden = true
        mobileCall.setTitle("", forState: UIControlState.Normal)
        mobileCall.transform = CGAffineTransformMakeTranslation(0, 0)
        iPhoneTxt.hidden = true
        iPhoneTxt.setTitle("", forState: UIControlState.Normal)
        iPhoneTxt.transform = CGAffineTransformMakeTranslation(0, 0)
        mobileTxt.hidden = true
        mobileTxt.setTitle("", forState: UIControlState.Normal)
        mobileTxt.transform = CGAffineTransformMakeTranslation(0, 0)
        primaryEmail.hidden = true
        primaryEmail.setTitle("", forState: UIControlState.Normal)
        primaryEmail.transform = CGAffineTransformMakeTranslation(0, 0)
        secondaryEmail.hidden = true
        secondaryEmail.setTitle("", forState: UIControlState.Normal)
        secondaryEmail.transform = CGAffineTransformMakeTranslation(0, 0)
        
        mobileIncluded = false
        workIncluded = false
        homeIncluded = false
        otherIncluded = false
        iPhoneIncluded = false
    }
    internal func emailCell(email: String, count: Int) {
        if count != 0 {
            var connections = hkConnectContainer.subviews.count
            var visibleCount: Int = 0
            var primaryTranslate: CGFloat
            var otherTranslate: CGFloat
            for index in 0..<connections {
                var buttons = hkConnectContainer.subviews
                var button: UIButton = buttons[index] as! UIButton
                if (!button.hidden) {
                    visibleCount++
                }
                if count == 1 {
                    primaryTranslate = 60 * CGFloat(visibleCount - 2)
                    primaryEmail.hidden = false
                    primaryEmail.setTitle(email, forState: UIControlState.Normal)
                    primaryEmail.transform = CGAffineTransformMakeTranslation(primaryTranslate, 0)
                    skype.setTitle(email, forState: UIControlState.Normal)
                    skype.hidden = false
                    skype.transform = CGAffineTransformMakeTranslation(60 * CGFloat(visibleCount - 1), 0)
                } else if count > 1 {
                    primaryTranslate = 60 * CGFloat(visibleCount - 2)
                    otherTranslate = 60 * CGFloat(visibleCount - 1)
                    primaryEmail.hidden = false
                    primaryEmail.setTitle(email, forState: UIControlState.Normal)
                    primaryEmail.transform = CGAffineTransformMakeTranslation(primaryTranslate, 0)
                    secondaryEmail.hidden = false
                    secondaryEmail.setTitle(email, forState: UIControlState.Normal)
                    secondaryEmail.transform = CGAffineTransformMakeTranslation(otherTranslate, 0)
                }
            }
        }
    }
    internal func avatarCell(image: UIImage!) {
        avatarImage.image = image
        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2.0
        avatarImage.clipsToBounds = true
    }
}