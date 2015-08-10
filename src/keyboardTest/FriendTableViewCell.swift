//
//  FriendTableViewCell.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/17/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit
import Foundation

class FriendTableViewCell: UITableViewCell, UIScrollViewDelegate {
    var person: HKPerson! = nil
    var favPerson: HKFavorite! = nil
    var photoImageView: UIImageView! = UIImageView()
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
    var sourceTag: UIView = UIView()
    var BitmapOverlay = UIImage(named: "BitmapOverlayBG")
    var cardImageView = UIImageView()
    var scrollview = UIScrollView()
    var containerView : UIView! = UIView()
    var containerChildren: CGFloat!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let initialViewWidth = appDelegate.centerViewController.view.frame.width
        
        self.frame = CGRect(x: 0, y: 0, width: initialViewWidth, height: 74)
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        configureView()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        configureView()
    }
    
    func configureView() {
        // Initialization code
        friendCardView.frame = CGRect(x: 5, y: 10, width: self.frame.width-10, height: self.frame.height-10)
        
        cardImageView.image = BitmapOverlay
        cardImageView.frame = CGRect(x: 0, y: 0, width: friendCardView.frame.width, height: friendCardView.frame.height)
        cardImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cardImageView.alpha = 0.5
        cardImageView.clipsToBounds = true
        friendCardView.addSubview(cardImageView)
        
        friendCardView.layer.cornerRadius = radius
        friendCardView.tag = 94
        
        photoImageView.frame = CGRect(x: 14, y: 6, width: 42, height: 42)
        photoImageView.layer.cornerRadius = photoImageView!.frame.width / 2.0
        photoImageView.clipsToBounds = true
        photoImageView.tag = 200
        initialsLabel.frame = CGRect(x: 0, y: 0, width: photoImageView.frame.width, height: photoImageView.frame.height)
        initialsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 21)!
        initialsLabel.textColor = UIColor.whiteColor()
        initialsLabel.textAlignment = NSTextAlignment.Center
        photoImageView.addSubview(initialsLabel)
        friendCardView.addSubview(photoImageView)
        
        nameLabel.frame = CGRect(x: 74, y: 3, width: 221, height: 27)
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size: 17)!
        nameLabel.textColor = UIColor.whiteColor()
        friendCardView.addSubview(nameLabel)
        
        scrollview = UIScrollView(frame: CGRectMake(74, 28, friendCardView.bounds.width - 74, 36))
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
        
        sourceTag.frame = CGRect(x: 0, y: 0, width: 2, height: friendCardView.frame.height)
        sourceTag.backgroundColor = UIColor(red: 33/255, green: 192/255, blue: 100/255, alpha: 1.0)
        friendCardView.addSubview(sourceTag)
        
        self.contentView.addSubview(friendCardView)
    }
    
    func configureSecondaryBtns() {
        secondaryEmailBtn.frame = CGRect(x: connectBtnX, y: 0, width: 36, height: 36)
        secondaryEmailBtn.setImage(emailBtnImage, forState: UIControlState.Normal)
        secondaryEmailBtn.layer.cornerRadius = secondaryEmailBtn.frame.width / 2.0
        secondaryEmailBtn.contentMode = UIViewContentMode.ScaleAspectFit
        secondaryEmailBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        secondaryEmailBtn.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
        secondaryEmailBtn.tag = 99
        secondaryEmailBtn.hidden = true
        containerView.addSubview(secondaryEmailBtn)
    }
    
    func didPressButton(sender: UIButton!) {
        var infoToSend: String!
        recentPeople.append(person)
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
                emailPressed(infoToSend)
            }
        }
    }
    
    var mobileIncluded: Bool! = false
    var workIncluded: Bool! = false
    var homeIncluded: Bool! = false
    var otherIncluded: Bool! = false
    var iPhoneIncluded: Bool! = false
    
    internal func phoneCell(number: String) {
        let rangeOfLabel = number.rangeOfString(":")
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            let phoneNumber: String = number.substringFromIndex(labelIndex + 1)
            switch label {
            case "home":
                if mobileIncluded == true && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == true {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                    
                }
                homeIncluded = true
                homeCallBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                homeCallBtn.hidden = false
                emailBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            case "work":
                if homeIncluded == true {
                    workCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if mobileIncluded == true && iPhoneIncluded == true {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                workIncluded = true
                workCallBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                workCallBtn.hidden = false
                emailBtn.transform = CGAffineTransformMakeTranslation(60, 0)
            case "iPhone":
                if homeIncluded == false && workIncluded == false && otherIncluded == false {
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == false {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == false {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == false && workIncluded == false && otherIncluded == true {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == true {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == true {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == false {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == true {
                    iPhoneCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    iPhoneTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                iPhoneIncluded = true
                iPhoneCallBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                iPhoneCallBtn.hidden = false
                iPhoneTxtBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                iPhoneTxtBtn.hidden = false
            case "mobile":
                if homeIncluded == false && workIncluded == false && otherIncluded == false && iPhoneIncluded == false {
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == false && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == false && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(60, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                }
                if homeIncluded == false && workIncluded == false && otherIncluded == true && iPhoneIncluded == true {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                if homeIncluded == true && workIncluded == false && otherIncluded == true && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == false && iPhoneIncluded == true {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                if homeIncluded == false && workIncluded == true && otherIncluded == true && iPhoneIncluded == true {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(360, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == false && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(120, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == true && iPhoneIncluded == false {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(180, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                }
                if homeIncluded == true && workIncluded == true && otherIncluded == true && iPhoneIncluded == true {
                    mobileCallBtn.transform = CGAffineTransformMakeTranslation(240, 0)
                    mobileTxtBtn.transform = CGAffineTransformMakeTranslation(300, 0)
                    emailBtn.transform = CGAffineTransformMakeTranslation(360, 0)
                }
                mobileIncluded = true
                mobileCallBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                mobileCallBtn.hidden = false
                mobileTxtBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                mobileTxtBtn.hidden = false
            default:
                break
            }
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
    
    internal func emailCell(email: String, emailCount: Int) {
        if emailCount != 0 {
            var otherTranslate: CGFloat
                if emailCount == 1 {
                    emailBtn.hidden = false
                    emailBtn.setTitle(email, forState: UIControlState.Normal)
                } else if emailCount > 1 {
                    otherTranslate = 60 * CGFloat(emailCount)
                    emailBtn.hidden = false
                    emailBtn.setTitle(email, forState: UIControlState.Normal)
                }
            }
    }
    
    private func callNumber(sender: AnyObject!) {
        var phoneNumber: String! = sender as? String
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (count(cleanNumber.utf16) > 1){
            if let phoneCallURL:NSURL = NSURL(string: "tel://\(cleanNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL);
                }
            }
        } else {
            let alert = UIAlertView()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    private func textNumber(phoneNumber:String) {
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (count(cleanNumber.utf16) > 1){
            if let textMessageURL:NSURL = NSURL(string: "sms://\(cleanNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(textMessageURL)) {
                    application.openURL(textMessageURL);
                }
            }
        } else {
            let alert = UIAlertView()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available for text messaging."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    private func emailPressed(email:String) {
        if let emailUrl:NSURL = NSURL(string: "mailto:\(email)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(emailUrl)) {
                application.openURL(emailUrl);
            }
        }
    }
}
