//
//  FriendTableViewCell.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/17/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit
import Foundation
import Hokusai
import RealmSwift

class FriendTableViewCell: UITableViewCell, UIScrollViewDelegate {
    var person: HKPerson! = nil
    var photoImageView: UIImageView! = UIImageView()
    var backgroundClipView = UIView()
    var backgroundColorView = UIView()
    var initialsLabel: UILabel! = UILabel()
    var nameLabel: UILabel! = UILabel()
    var radius: CGFloat = 0
    var friendCardView: UIView! = UIView()
    var connectBtnX: CGFloat! = 0
    var homeCallBtn: UIButton! = UIButton()
    var workCallBtn: UIButton! = UIButton()
    var mobileCallBtn: UIButton! = UIButton()
    var mobileTxtBtn: UIButton! = UIButton()
    var iPhoneCallBtn: UIButton! = UIButton()
    var iPhoneTxtBtn: UIButton! = UIButton()
    var emailBtn: UIButton! = UIButton()
    var secondaryEmailBtn: UIButton! = UIButton()
    var homeCallBtnImage: UIImage! = UIImage(named:"CallHome")
    var workCallBtnImage: UIImage! = UIImage(named:"CallWork")
    var mobileCallBtnImage: UIImage! = UIImage(named:"CallMobile")
    var iPhoneCallBtnImage: UIImage! = UIImage(named:"CalliPhone")
    var mobileTxtBtnImage: UIImage! = UIImage(named:"Messaging")
    var iPhoneTxtBtnImage: UIImage! = UIImage(named:"MessageiPhone")
    var emailBtnImage: UIImage! = UIImage(named:"Email")
    var BitmapOverlay = UIImage(named: "BitmapOverlayBG")
    var cardImageView = UIImageView()
    var scrollview = UIScrollView()
    var containerView : UIView! = UIView()
    var containerChildren: CGFloat!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 74)
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        configureView()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        configureView()
    }
    
    func configureView() {
        // Initialization code
        friendCardView.frame = CGRect(x: 36, y: 0, width: self.frame.width - 36, height: self.frame.height)
        friendCardView.layer.cornerRadius = radius
        friendCardView.tag = 94
        friendCardView.layer.addBorder(.Bottom, color: UIColor(red: 245/255, green: 246/255, blue: 247/255, alpha: 0.4), thickness: 0.5)
        
        backgroundClipView.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
        backgroundClipView.clipsToBounds = true
        
        backgroundColorView.frame = CGRect(x: 0, y: 8, width: 52, height: 52)
        backgroundColorView.layer.cornerRadius = backgroundColorView.frame.width / 2.0
        backgroundColorView.clipsToBounds = true
        
        photoImageView.frame = CGRect(x: 0, y: 8, width: 52, height: 52)
        photoImageView.layer.cornerRadius = photoImageView!.frame.width / 2.0
        photoImageView.clipsToBounds = true
        photoImageView.tag = 200
        photoImageView.opaque = true
        photoImageView.layer.borderWidth = 2
        initialsLabel.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.width, height: photoImageView.frame.height)
        initialsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 21)!
        initialsLabel.textColor = UIColor.blackColor()
        initialsLabel.textAlignment = NSTextAlignment.Center
        photoImageView.addSubview(initialsLabel)
        backgroundClipView.addSubview(photoImageView)
        friendCardView.addSubview(backgroundColorView)
        friendCardView.sendSubviewToBack(backgroundColorView)
        friendCardView.addSubview(backgroundClipView)
        
        nameLabel.frame = CGRect(x: 74, y: 6.5, width: 221, height: 24)
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size: 17)!
        nameLabel.textColor = UIColor.whiteColor()
        friendCardView.addSubview(nameLabel)
        
        scrollview = UIScrollView(frame: CGRectMake(74, 32, friendCardView.frame.width - 74, 36))
        containerChildren = friendCardView.bounds.width
        scrollview.contentSize = CGSizeMake(containerChildren, scrollview.frame.height) // will be 2 times as wide as the cell
        scrollview.clipsToBounds = true
        scrollview.backgroundColor = UIColor.clearColor()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.delegate = self
        scrollview.scrollEnabled = false
        friendCardView.addSubview(scrollview)
        
        containerView.frame = CGRectMake(0, 0, 400, scrollview.frame.height)
        scrollview.addSubview(containerView)
        
        homeCallBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        homeCallBtn.setImage(homeCallBtnImage, forState: UIControlState.Normal)
        homeCallBtn.layer.cornerRadius = homeCallBtn.frame.width / 2.0
        homeCallBtn.contentMode = UIViewContentMode.ScaleAspectFit
        homeCallBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        homeCallBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        homeCallBtn.tag = 95
        homeCallBtn.hidden = true
        containerView.addSubview(homeCallBtn)
        
        workCallBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        workCallBtn.setImage(workCallBtnImage, forState: UIControlState.Normal)
        workCallBtn.layer.cornerRadius = workCallBtn.frame.width / 2.0
        workCallBtn.contentMode = UIViewContentMode.ScaleAspectFit
        workCallBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        workCallBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        workCallBtn.tag = 95
        workCallBtn.hidden = true
        containerView.addSubview(workCallBtn)
        
        mobileCallBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        mobileCallBtn.setImage(mobileCallBtnImage, forState: UIControlState.Normal)
        mobileCallBtn.layer.cornerRadius = mobileCallBtn.frame.width / 2.0
        mobileCallBtn.contentMode = UIViewContentMode.ScaleAspectFit
        mobileCallBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        mobileCallBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        mobileCallBtn.tag = 95
        mobileCallBtn.hidden = true
        containerView.addSubview(mobileCallBtn)
        
        mobileTxtBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        mobileTxtBtn.setImage(mobileTxtBtnImage, forState: UIControlState.Normal)
        mobileTxtBtn.layer.cornerRadius = mobileTxtBtn.frame.width / 2.0
        mobileTxtBtn.contentMode = UIViewContentMode.ScaleAspectFit
        mobileTxtBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        mobileTxtBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        mobileTxtBtn.tag = 98
        mobileTxtBtn.hidden = true
        containerView.addSubview(mobileTxtBtn)
        
        iPhoneCallBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        iPhoneCallBtn.setImage(iPhoneCallBtnImage, forState: UIControlState.Normal)
        iPhoneCallBtn.layer.cornerRadius = iPhoneCallBtn.frame.width / 2.0
        iPhoneCallBtn.contentMode = UIViewContentMode.ScaleAspectFit
        iPhoneCallBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        iPhoneCallBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        iPhoneCallBtn.tag = 95
        iPhoneCallBtn.hidden = true
        containerView.addSubview(iPhoneCallBtn)
        
        iPhoneTxtBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        iPhoneTxtBtn.setImage(iPhoneTxtBtnImage, forState: UIControlState.Normal)
        iPhoneTxtBtn.layer.cornerRadius = iPhoneTxtBtn.frame.width / 2.0
        iPhoneTxtBtn.contentMode = UIViewContentMode.ScaleAspectFit
        iPhoneTxtBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        iPhoneTxtBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        iPhoneTxtBtn.hidden = true
        iPhoneTxtBtn.tag = 98
        containerView.addSubview(iPhoneTxtBtn)
        
        emailBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        emailBtn.setImage(emailBtnImage, forState: UIControlState.Normal)
        emailBtn.layer.cornerRadius = emailBtn.frame.width / 2.0
        emailBtn.contentMode = UIViewContentMode.ScaleAspectFit
        emailBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        emailBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        emailBtn.tag = 99
        emailBtn.hidden = true
        containerView.addSubview(emailBtn)
        
        self.contentView.addSubview(friendCardView)
    }
    
    func emailActionSheet(emailUser: String) {
        let hokusai = Hokusai()
        var hkPerson = try! Realm().objectForPrimaryKey(HKPerson.self, key: emailUser)
        var emailsToSelect = hkPerson!.emails
        
        for email in emailsToSelect {
            // Add a button with a closure
            hokusai.addButton("\(email.email)") {
                self.emailPressed(email.email)
            }
        }
        
        // Add a button with a selector
        //hokusai.addButton("\(emailToSelect)", target: self, selector: Selector("button2Pressed"))
        
        // Set a font name. AvenirNext-DemiBold is the default. (Optional)
        hokusai.fontName = "HelveticaNeue-Light"
        
        // Select a color scheme. Just below you can see the dafault sets of schemes. (Optional)
        hokusai.colorScheme = HOKColorScheme.Karasu
        
        // Show Hokusai
        hokusai.show()
        
        // Selector for button 2
        func button2Pressed() {
            print("Oribe")
        }
        
        // Change a title for cancel button. Default is Cancel. (Optional)
        hokusai.cancelButtonTitle = "Done"
        
        // Add a callback for cancel button (Optional)
        hokusai.cancelButtonAction = {
            print("canceled")
        }
    }
    
    func didPressButton(sender: UIButton!) {
        var infoToSend: String!
        backgroundAddRecent(person)
        if (sender.tag == 95) {
            infoToSend = sender.titleLabel!.text!
            if (infoToSend != nil) {
                callNumber(infoToSend)
            }
        }
        if (sender.tag == 98) {
            infoToSend = sender.titleLabel!.text!
            if (infoToSend != nil) {
                textNumber(infoToSend)
            }
        }
        if (sender.tag == 99) {
            infoToSend = sender.titleLabel!.text!
            if (infoToSend != nil) {
                emailActionSheet(infoToSend)
            }
        }
    }
    
    var mobileIncluded: Bool! = false
    var workIncluded: Bool! = false
    var homeIncluded: Bool! = false
    var otherIncluded: Bool! = false
    var iPhoneIncluded: Bool! = false
    
    internal func phoneCell(number: String, label: String) {
            switch label {
            case "Home":
                homeIncluded = true
                homeCallBtn.setTitle(number, forState: UIControlState.Normal)
                homeCallBtn.hidden = false
            case "Work":
                //if homeIncluded == false && mobileIncluded == false && iPhoneIncluded == false {
                    //emailBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                //}
                workIncluded = true
                workCallBtn.setTitle(number, forState: UIControlState.Normal)
                workCallBtn.hidden = false
            case "iPhone":
                iPhoneIncluded = true
                iPhoneCallBtn.setTitle(number, forState: UIControlState.Normal)
                iPhoneCallBtn.hidden = false
                iPhoneTxtBtn.setTitle(number, forState: UIControlState.Normal)
                iPhoneTxtBtn.hidden = false
            case "Mobile":
                mobileIncluded = true
                mobileCallBtn.setTitle(number, forState: UIControlState.Normal)
                mobileCallBtn.hidden = false
                mobileTxtBtn.setTitle(number, forState: UIControlState.Normal)
                mobileTxtBtn.hidden = false
            default:
                break
            }
            self.dynamicActionButtons()
    }
    
    func dynamicActionButtons() {
        if homeIncluded == true && workIncluded == false && mobileIncluded == false && iPhoneIncluded == false {
            emailBtn.transform = CGAffineTransformMakeTranslation(60, 0)
        }
        if homeIncluded == false && workIncluded == true && mobileIncluded == false && iPhoneIncluded == false {
            emailBtn.transform = CGAffineTransformMakeTranslation(60, 0)
        }
        if homeIncluded == false && workIncluded == false && mobileIncluded == true && iPhoneIncluded == true {
            iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
            scrollview.showsHorizontalScrollIndicator = true
            scrollview.scrollEnabled = true
        }
        if homeIncluded == false && workIncluded == false && mobileIncluded == true && iPhoneIncluded == false {
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(120, 0)
        }
        if homeIncluded == false && workIncluded == false && mobileIncluded == false && iPhoneIncluded == true {
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(120, 0)
        }
        if homeIncluded == true && workIncluded == false && mobileIncluded == true && iPhoneIncluded == false {
            mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
        }
        if homeIncluded == false && workIncluded == true && mobileIncluded == false && iPhoneIncluded == true {
            iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
        }
        if homeIncluded == false && workIncluded == true && mobileIncluded == true && iPhoneIncluded == false {
            mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
        }
        if homeIncluded == false && workIncluded == true && mobileIncluded == true && iPhoneIncluded == true {
            mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
            scrollview.showsHorizontalScrollIndicator = true
            scrollview.scrollEnabled = true
        }
        if homeIncluded == true && workIncluded == false && mobileIncluded == true && iPhoneIncluded == true {
            mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
            scrollview.showsHorizontalScrollIndicator = true
            scrollview.scrollEnabled = true
        }
        if homeIncluded == true && workIncluded == true && mobileIncluded == false && iPhoneIncluded == false {
            workCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(120, 0)
        }
        if homeIncluded == true && workIncluded == true && mobileIncluded == true && iPhoneIncluded == false {
            workCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            mobileCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
            scrollview.showsHorizontalScrollIndicator = true
            scrollview.scrollEnabled = true
        }
        if homeIncluded == true && workIncluded == true && mobileIncluded == false && iPhoneIncluded == true {
            workCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
            scrollview.showsHorizontalScrollIndicator = true
            scrollview.scrollEnabled = true
        }
        if homeIncluded == true && workIncluded == true && mobileIncluded == true && iPhoneIncluded == true {
            workCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            mobileCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
            mobileTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
            iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(240, 0)
            iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(300, 0)
            emailBtn.transform = CGAffineTransformMakeTranslation(360, 0)
            containerChildren = friendCardView.bounds.width + 60
            scrollview.showsHorizontalScrollIndicator = true
            scrollview.scrollEnabled = true
        }
    }
    
    override func prepareForReuse() {
        homeCallBtn.hidden = true
        homeCallBtn.setTitle("", forState: UIControlState.Normal)
        workCallBtn.hidden = true
        workCallBtn.setTitle("", forState: UIControlState.Normal)
        workCallBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        iPhoneCallBtn.hidden = true
        iPhoneCallBtn.setTitle("", forState: UIControlState.Normal)
        iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        mobileCallBtn.hidden = true
        mobileCallBtn.setTitle("", forState: UIControlState.Normal)
        mobileCallBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        iPhoneTxtBtn.hidden = true
        iPhoneTxtBtn.setTitle("", forState: UIControlState.Normal)
        iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        mobileTxtBtn.hidden = true
        mobileTxtBtn.setTitle("", forState: UIControlState.Normal)
        mobileTxtBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        emailBtn.hidden = true
        emailBtn.setTitle("", forState: UIControlState.Normal)
        emailBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        secondaryEmailBtn.hidden = true
        secondaryEmailBtn.setTitle("", forState: UIControlState.Normal)
        secondaryEmailBtn.transform = CGAffineTransformMakeTranslation(0, 0)
        initialsLabel.text = ""
        phonesArray.removeAll(keepCapacity: false)
        emailsArray.removeAll(keepCapacity: false)
        
        mobileIncluded = false
        workIncluded = false
        homeIncluded = false
        otherIncluded = false
        iPhoneIncluded = false
    }
    
    internal func emailCell(person: HKPerson, emailCount: Int) {
        if emailCount != 0 {
            emailBtn.hidden = false
            let emailUser = person.uuid
            emailBtn.setTitle(emailUser, forState: UIControlState.Normal)
        } else {
            emailBtn.hidden = true
            
            if homeIncluded == false && workIncluded == false && mobileIncluded == true && iPhoneIncluded == true {
                scrollview.showsHorizontalScrollIndicator = false
                scrollview.scrollEnabled = false
            } else if homeIncluded == true && workIncluded == true && mobileIncluded == true && iPhoneIncluded == false {
                scrollview.showsHorizontalScrollIndicator = false
                scrollview.scrollEnabled = false
            } else if homeIncluded == true && workIncluded == true && mobileIncluded == false && iPhoneIncluded == true {
                scrollview.showsHorizontalScrollIndicator = false
                scrollview.scrollEnabled = false
            } else {
                return
            }
        }
    }
    
    private func callNumber(sender: AnyObject!) {
        do {
            let realm = RealmManager.setupRealmInApp()
            let totalCount = realm.objects(HKPerson).count
            let usageWeight: Double = Double(0.75) * (Double(totalCount - person.indexedOrder) / Double(totalCount))
            realm.beginWrite()
            person.flUsageWeight += usageWeight + Double(1 - (person.indexedOrder / totalCount))
            realm.commitWrite()
        } catch {
            print("Something went wrong!")
        }
        let phoneNumber: String! = sender as? String
        let strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber = cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (cleanNumber.utf16.count > 1){
            if let phoneCallURL:NSURL = NSURL(string: "tel://\(cleanNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL);
                }
            }
        } else {
            let alert = UIAlertController()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available."
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alert.addAction(okAction)
            window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func textNumber(phoneNumber:String) {
        do {
            let realm = RealmManager.setupRealmInApp()
            let totalCount = realm.objects(HKPerson).count
            let usageWeight: Double = Double(0.5) * (Double(totalCount - person.indexedOrder) / Double(totalCount))
            realm.beginWrite()
            person.flUsageWeight += usageWeight + Double(1 - (person.indexedOrder / totalCount))
            realm.commitWrite()
        } catch {
            print("Something went wrong!")
        }
        let strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber = cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (cleanNumber.utf16.count > 1){
            if let textMessageURL:NSURL = NSURL(string: "sms://\(cleanNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(textMessageURL)) {
                    application.openURL(textMessageURL);
                }
            }
        } else {
            let alert = UIAlertController()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available."
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alert.addAction(okAction)
            window!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func emailPressed(email:String) {
        do {
            let realm = RealmManager.setupRealmInApp()
            let totalCount = realm.objects(HKPerson).count
            let usageWeight: Double = Double(0.25) * (Double(totalCount - person.indexedOrder) / Double(totalCount))
            realm.beginWrite()
            person.flUsageWeight += usageWeight + Double(1 - (person.indexedOrder / totalCount))
            realm.commitWrite()
        } catch {
            print("Something went wrong!")
        }
        if let emailUrl:NSURL = NSURL(string: "mailto:\(email)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(emailUrl)) {
                application.openURL(emailUrl);
            }
        }
    }
}
