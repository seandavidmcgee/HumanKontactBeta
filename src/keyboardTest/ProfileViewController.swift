//
//  ProfileViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 4/26/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics
import RealmSwift

let offset_HeaderStop:CGFloat = 122.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 54.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 45.0 // The distance between the bottom of the Header and the top of the White Label

class ProfileViewController: UIViewController, UIScrollViewDelegate, SwiftPromptsProtocol {
    var prompt = SwiftPromptsView()
    var image:UIImage? = nil
    var imageBG:UIImage? = nil
    var initials: String! = nil
    var nameLabel:String! = nil
    var coLabel:String! = nil
    var jobTitleLabel:String! = nil
    var FlatHKDark = UIColor(red: 13/255, green: 10/255, blue: 23/255, alpha: 1.0)
    let control = GlobalVariables.sharedManager
    var phoneY = CGFloat()
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var avatarImage:UIImageView!
    @IBOutlet var header:UIView!
    @IBOutlet var baseLabel: UILabel!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var companyHeaderLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var profileBGImageView: UIImageView = UIImageView()
    var personHeader: UIImageView = UIImageView()
    var headerImageView:UIImageView = UIImageView()
    var headerBlurImageView:UIImageView = UIImageView()
    var favIcon: UIButton!
    var profileFieldY: CGFloat = 303
    var emailFieldY = CGFloat()
    var fieldCount: Int = 0
    var emailCount: Int = 0
    var profileFieldArray: [String?] = []
    var visibleFields: CGFloat = 0
    var profileField: UIView!
    var emailField: UIView!
    var jobField: UIView!
    var profileDynamicField: UIView!
    var profilePhone: String!
    var profileEmail: String!
    var initialsLabel: UILabel! = UILabel()
    let favImage = UIImage(named: "Favs")
    let favAdded = UIImage(named: "love")
    var favIncluded: Bool! = false
    var selectedPerson: String!
    var person: HKPerson?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "Dismiss")
        profileBGImageView = UIImageView(frame: self.view.frame)
        profileBGImageView.image = UIImage(named: "BitmapOverlayBG")
        profileBGImageView.alpha = 0.5
        profileBGImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(profileBGImageView)
        self.view.sendSubviewToBack(profileBGImageView)
        let back = UIButton(frame: CGRect(x: -25, y: 32, width: 112, height: 22))
        back.setImage(image, forState: UIControlState.Normal)
        back.layer.zPosition = 3
        back.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(back)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        scrollView.delegate = self
        
        //Favorites
        favIcon = UIButton(frame: CGRect(x: (self.view.frame.width - 42), y: 22, width: 32, height: 32))
        favIcon.layer.zPosition = 3
        favIcon.hidden = true
        favoritesButton.layer.zPosition = 4
        favoritesButton.layer.cornerRadius = 15
        favoritesButton.clipsToBounds = true
        
        if FavPeople.favorites.count > 0 {
            for fav in FavPeople.favorites {
                if fav.fullName == nameLabel {
                    favIcon.setImage(favAdded, forState: UIControlState.Normal)
                    favIcon.tintColor = .whiteColor()
                    favIncluded = true
                    favIcon.addTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
                    favoritesButton.backgroundColor = .whiteColor()
                    favoritesButton.setTitle("Favorite", forState: .Normal)
                    favoritesButton.setTitleColor(UIColor(hex: 0xFB2155), forState: .Normal)
                    favoritesButton.titleLabel!.text = "Favorite"
                    favoritesButton.titleLabel?.textColor = UIColor(hex: 0xFB2155)
                    favoritesButton.addTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
                }
            }
        }
        
        if !favIncluded {
            favIcon.addTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
            favIcon.setImage(favImage, forState: UIControlState.Normal)
            favIcon.tintColor = UIColor(hex: 0xFB2155)
            favoritesButton.addTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
        }
        self.view.addSubview(favIcon)
        
        // Header - Image
        let headerSizeOffset: CGFloat = header.frame.width * 0.0833
        let headerYOffset: CGFloat = header.frame.height * 0.1136
        
        personHeader = UIImageView(frame: CGRect(x: -headerSizeOffset, y: headerYOffset, width: header.frame.width - headerSizeOffset, height: header.frame.height - headerSizeOffset))
        personHeader.image = imageBG?.blurredImageWithRadius(20, iterations: 20, tintColor: UIColor(red: 0, green: 0, blue: 13/255, alpha: 0.3))!
        personHeader.contentMode = .ScaleAspectFill
        
        headerImageView = UIImageView(frame: personHeader.frame)
        headerImageView.contentMode = .ScaleAspectFit
        headerImageView.alpha = 0.7
        headerImageView.addSubview(personHeader)
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        header.backgroundColor = UIColor(gradientStyle: .LeftToRight, withFrame: header.frame, andColors: [UIColor(hex: 0x172445), UIColor(hex: 0x3E6D8E)])
        header.clipsToBounds = true
        
        let profileImageView: UIImageView! = UIImageView(frame: avatarImage.bounds)
        profileImageView.image = image
        profileImageView.contentMode = .ScaleAspectFill
        initialsLabel.frame = CGRect(x: 0, y: 0, width: profileImageView.frame.width, height: profileImageView.frame.height)
        if (initials != nil) {
            initialsLabel.text = initials
        }
        initialsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 28)!
        initialsLabel.textColor = UIColor.blackColor()
        initialsLabel.textAlignment = NSTextAlignment.Center
        profileImageView.addSubview(initialsLabel)
        avatarImage.insertSubview(profileImageView!, atIndex: 0)
        
        if phonesProfileArray.count != 0 {
            createProfileFieldsBG()
        }
        
        person = try! Realm().objectForPrimaryKey(HKPerson.self, key: selectedPerson!)
        let personColor = person!.nameColor
        
        for phone in phonesProfileArray {
            // Grab each key, value pair from the person dictionary
            for (key,value) in phone {
                profilePhone = "\(key): \(value)"
                createPhoneFields(profilePhone, color: personColor)
                createFacetimeFields(key, value: value, color: personColor)
                visibleFields++
            }
        }
        if emailsProfileArray.count != 0 {
            createProfileEmailsBG()
        }
        for email in emailsProfileArray {
            // Grab each key, value pair from the person dictionary
            for (key,value) in email {
                profileEmail = "\(key): \(value)"
                createEmailFields(profileEmail, color: personColor)
                visibleFields++
            }
        }
        if (jobTitleLabel != nil && jobTitleLabel != "") {
            createProfileJobsBG()
            createJobFields("Job Title: \(jobTitleLabel)", color: personColor)
            visibleFields++
        }
        //createProfileFieldsBG()
        headerLabel.text = nameLabel
        baseLabel.text = nameLabel
        companyLabel.text = coLabel
        companyHeaderLabel.text = coLabel
        phonesArray.removeAll(keepCapacity: false)
        emailsArray.removeAll(keepCapacity: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        profileFieldArray.removeAll(keepCapacity: false)
        phonesProfileArray.removeAll(keepCapacity: false)
        emailsProfileArray.removeAll(keepCapacity: false)
        promptPhonesArray.removeAll(keepCapacity: false)
        promptEmailsArray.removeAll(keepCapacity: false)
    }
    
    func createProfileFieldsBG() {
        profileField = UIView(frame: CGRect(x: 0, y: profileFieldY, width: self.view.frame.width, height: CGFloat((44 * phonesProfileArray.count) + 30)))
        profileField.backgroundColor = UIColor(red: 0, green: 0, blue: 13/255, alpha: 0.5)
        profileField.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: profileField.bounds, cornerRadius: 0)
        
        profileField.layer.masksToBounds = false
        profileField.layer.shadowColor = UIColor(hex: 0x00000d).CGColor
        profileField.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileField.layer.shadowRadius = 5.0
        profileField.layer.shadowOpacity = 0.5
        profileField.layer.shadowPath = shadowPath.CGPath
        
        let profileFieldMainLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 150, height: 20))
        profileFieldMainLabel.textColor = UIColor.whiteColor()
        profileFieldMainLabel.font = UIFont(name: "AvenirNext-Regular", size: 17)!
        profileFieldMainLabel.text = "Phone Numbers"
        profileField.addSubview(profileFieldMainLabel)
    }
    
    func createProfileEmailsBG() {
        if profileField != nil {
            profileFieldY += profileField.frame.height
        }
        emailFieldY = CGFloat(profileFieldY + 15)
        emailField = UIView(frame: CGRect(x: 0, y: emailFieldY, width: self.view.frame.width, height: CGFloat((44 * emailsProfileArray.count) + 30)))
        emailField.backgroundColor = UIColor(red: 0, green: 0, blue: 13/255, alpha: 1.0)
        emailField.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: emailField.bounds, cornerRadius: 0)
        
        emailField.layer.masksToBounds = false
        emailField.layer.shadowColor = UIColor(hex: 0x00000d).CGColor
        emailField.layer.shadowOffset = CGSize(width: 0, height: 2)
        emailField.layer.shadowRadius = 5.0
        emailField.layer.shadowOpacity = 0.5
        emailField.layer.shadowPath = shadowPath.CGPath
        
        let profileFieldEmailLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 150, height: 20))
        profileFieldEmailLabel.textColor = UIColor.whiteColor()
        profileFieldEmailLabel.font = UIFont(name: "AvenirNext-Regular", size: 17)!
        profileFieldEmailLabel.text = "Emails"
        emailField.addSubview(profileFieldEmailLabel)
    }
    
    func createProfileJobsBG() {
        var jobFieldY = CGFloat()
        if emailsProfileArray.count != 0 && phonesProfileArray.count != 0 {
            jobFieldY = emailField.frame.maxY + 15
        } else if emailsProfileArray.count != 0 && phonesProfileArray.count == 0 {
            jobFieldY = emailField.frame.maxY + 15
        } else if emailsProfileArray.count == 0 && phonesProfileArray.count != 0 {
            jobFieldY = profileField.frame.maxY + 15
        } else {
            jobFieldY = profileFieldY
        }
        jobField = UIView(frame: CGRect(x: 0, y: jobFieldY, width: self.view.frame.width, height: 74))
        jobField.backgroundColor = UIColor(red: 0, green: 0, blue: 13/255, alpha: 1.0)
        jobField.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: jobField.bounds, cornerRadius: 0)
        
        jobField.layer.masksToBounds = false
        jobField.layer.shadowColor = UIColor(hex: 0x00000d).CGColor
        jobField.layer.shadowOffset = CGSize(width: 0, height: 2)
        jobField.layer.shadowRadius = 5.0
        jobField.layer.shadowOpacity = 0.5
        jobField.layer.shadowPath = shadowPath.CGPath
        
        let profileFieldJobLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 150, height: 20))
        profileFieldJobLabel.textColor = UIColor.whiteColor()
        profileFieldJobLabel.font = UIFont(name: "AvenirNext-Regular", size: 17)!
        profileFieldJobLabel.text = "Jobs"
        jobField.addSubview(profileFieldJobLabel)
    }
    
    func createPhoneFields(sender: String, color: String) {
        phoneY = CGFloat(25 + (fieldCount * 44) + 5)
        let profileFieldMask = UIView(frame: CGRect(x: 5, y: phoneY, width: profileField.frame.width - 10, height: 34))
        profileFieldMask.backgroundColor = UIColor(hexString: color)
        profileFieldMask.layer.cornerRadius = 0
        fieldCount++
        
        let profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 8, width: 335, height: 20))
        profileFieldLabel.textColor = UIColor.blackColor()
        profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
        profileFieldLabel.text = (sender)
        profileFieldMask.addSubview(profileFieldLabel)
        
        let mobilePhoneBtn = UIButton(frame: CGRect(x: 280, y: 4, width: 25, height: 28))
        mobilePhoneBtn.setImage(UIImage(named: "profileUtility1"), forState: UIControlState.Normal)
        mobilePhoneBtn.tintColor = UIColor.blackColor()
        mobilePhoneBtn.tag = 50
        mobilePhoneBtn.setTitle(sender, forState: UIControlState.Normal)
        mobilePhoneBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        mobilePhoneBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        mobilePhoneBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
        profileFieldMask.addSubview(mobilePhoneBtn)
        
        let mobileTxtBtn = UIButton(frame: CGRect(x: 336, y: 4, width: 28, height: 28))
        mobileTxtBtn.setImage(UIImage(named: "profileUtility2"), forState: UIControlState.Normal)
        mobileTxtBtn.tintColor = UIColor.blackColor()
        mobileTxtBtn.tag = 51
        mobileTxtBtn.setTitle(sender, forState: UIControlState.Normal)
        mobileTxtBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        mobileTxtBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        mobileTxtBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
        profileFieldMask.addSubview(mobileTxtBtn)
        profileField.addSubview(profileFieldMask)
        scrollView.addSubview(profileField)
    }
    
    func createFacetimeFields(sender: String, value: String, color: String) {
        if sender == "mobile" || sender == "iPhone" {
            facetime(value, color: color)
        }
    }
    
    func createEmailFields(sender: String, color: String) {
        phoneY = CGFloat(25 + (emailCount * 44) + 5)
        let profileFieldMask = UIView(frame: CGRect(x: 5, y: phoneY, width: emailField.frame.width - 10, height: 34))
        profileFieldMask.backgroundColor = UIColor(hexString: color)
        profileFieldMask.layer.cornerRadius = 0
        emailCount++
        
        let profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 8, width: 335, height: 20))
        profileFieldLabel.textColor = UIColor.blackColor()
        profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
        profileFieldLabel.lineBreakMode = .ByWordWrapping
        profileFieldLabel.numberOfLines = 2
        profileFieldLabel.text = (sender)
        profileFieldMask.addSubview(profileFieldLabel)
        
        let emailBtn = UIButton(frame: CGRect(x: 336, y: 8, width: 32, height: 20))
        emailBtn.setImage(UIImage(named: "profileUtility3"), forState: UIControlState.Normal)
        emailBtn.tintColor = UIColor.blackColor()
        emailBtn.tag = 53
        emailBtn.setTitle(sender, forState: UIControlState.Normal)
        emailBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        emailBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        emailBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
        profileFieldMask.addSubview(emailBtn)
        emailField.addSubview(profileFieldMask)
        scrollView.addSubview(emailField)
    }
    
    func createJobFields(sender: String, color: String) {
        let profileFieldMask = UIView(frame: CGRect(x: 5, y: 30, width: jobField.frame.width - 10, height: 34))
        profileFieldMask.backgroundColor = UIColor(hexString: color)
        profileFieldMask.layer.cornerRadius = 0
        
        let profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 8, width: 335, height: 20))
        profileFieldLabel.textColor = UIColor.blackColor()
        profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
        profileFieldLabel.lineBreakMode = .ByWordWrapping
        profileFieldLabel.numberOfLines = 2
        profileFieldLabel.text = (sender)
        
        profileFieldMask.addSubview(profileFieldLabel)
        jobField.addSubview(profileFieldMask)
        scrollView.addSubview(jobField)
    }
    
    func profileActions(sender: UIButton!) {
        var phoneNumberToCall: String!
        var emailToSend: String!
        
        if (sender.tag == 50) {
            phoneNumberToCall = sender.titleLabel!.text!
            callPressed(phoneNumberToCall)
        }
        if (sender.tag == 51) {
            phoneNumberToCall = sender.titleLabel!.text!
            textPressed(phoneNumberToCall)
        }
        if (sender.tag == 52) {
            phoneNumberToCall = sender.titleLabel!.text!
            facetimePressed(phoneNumberToCall)
        }
        if (sender.tag == 53) {
            emailToSend = sender.titleLabel!.text!
            let index = emailToSend.characters.indexOf(":")
            let cleanedEmail = emailToSend.substringFromIndex((index?.successor())!).removeWhitespace()
            emailPressed(cleanedEmail)
        }
    }
    
    func callPressed (sender: AnyObject!) {
        let phoneNumber: String! = sender as? String
        let strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber = cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (cleanNumber.utf16.count > 1){
            callNumber(cleanNumber)
        } else {
            let alert = UIAlertController()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available."
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textPressed (sender: AnyObject!) {
        let phoneNumber: String! = sender as? String
        let strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber = cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (cleanNumber.utf16.count > 1){
            textNumber(cleanNumber)
        } else {
            let alert = UIAlertController()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available."
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    private func textNumber(phoneNumber:String) {
        if let textMessageURL:NSURL = NSURL(string: "sms://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(textMessageURL)) {
                application.openURL(textMessageURL);
            }
        }
    }
    
    private func facetime(phoneNumber:String, color: String) {
        if let facetimeURL:NSURL = NSURL(string: "facetime://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(facetimeURL)) {
                profileField.frame.height += 44
                phoneY = CGFloat(25 + (fieldCount * 44) + 5)
                let profileFieldMask = UIView(frame: CGRect(x: 5, y: phoneY, width: profileField.frame.width - 10, height: 34))
                profileFieldMask.backgroundColor = UIColor(hexString: color)
                profileFieldMask.layer.cornerRadius = 0
                fieldCount++
                
                let profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 8, width: 335, height: 20))
                profileFieldLabel.textColor = UIColor.blackColor()
                profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
                profileFieldLabel.text = ("facetime: \(phoneNumber)")
                profileFieldMask.addSubview(profileFieldLabel)
                
                let mobileFacetimeBtn = UIButton(frame: CGRect(x: 336, y: 8, width: 32, height: 20))
                mobileFacetimeBtn.setImage(UIImage(named: "profileUtility4"), forState: UIControlState.Normal)
                mobileFacetimeBtn.tintColor = UIColor.blackColor()
                mobileFacetimeBtn.tag = 52
                mobileFacetimeBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                mobileFacetimeBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                mobileFacetimeBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
                mobileFacetimeBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
                profileFieldMask.addSubview(mobileFacetimeBtn)
                profileField.addSubview(profileFieldMask)
            }
        }
    }
    
    private func facetimePressed(phoneNumber:String) {
        let phoneNumber = phoneNumber
        let strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber = cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (cleanNumber.utf16.count > 1) {
            if let facetimeURL:NSURL = NSURL(string: "facetime://\(phoneNumber)") {
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(facetimeURL)) {
                    application.openURL(facetimeURL);
                } else {
                    let alert = UIAlertController()
                    alert.title = "Sorry!"
                    alert.message = "Phone number is not available for Facetime."
                    let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
                    }
                    alert.addAction(okAction)
                    presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available for Facetime."
            let okAction = UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .Default) { (action) in
            }
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func emailPressed(email:String) {
        print(email)
        if let emailUrl:NSURL = NSURL(string: "mailto:\(email)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(emailUrl)) {
                application.openURL(emailUrl);
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goBack() {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - (offset) ), 0)
            headerLabel.layer.transform = labelTransform
            companyHeaderLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            headerBlurImageView.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 3.5 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                    header.clipsToBounds = true
                    favIcon.hidden = true
                }
                
            } else {
                if avatarImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                    favIcon.hidden = false
                    //header.clipsToBounds = false
                }
            }
        }
        
        // Apply Transformations
        
        header.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
    }
    
    func favoriteProfile() {
        //Create an instance of SwiftPromptsView and assign its delegate
        prompt = SwiftPromptsView(frame: self.view.bounds)
        prompt.delegate = self
            
        //Set the properties for the background
        prompt.setColorWithTransparency(UIColor.clearColor())
            
        //Set the properties of the promt
        prompt.setPromtHeader("Add to Favorites")
        prompt.setPromptHeaderTxtTruncate(false)
        prompt.setPromptHeaderTxtSize(18.0)
        prompt.setPromptContentTxtSize(16.0)
        prompt.setPromptHeight(172)
        prompt.setPromptContentTextFont("HelveticaNeue-Light")
        prompt.setPromptContentTextRectY(56.0)
        prompt.setPromptContentTxtColor(UIColor.flatBlackColorDark())
        prompt.setPromptContentText("Would you like to add this person to your Favorites?")
        prompt.setPromptTopBarVisibility(true)
        prompt.setPromptBottomBarVisibility(false)
        prompt.setPromptTopLineVisibility(false)
        prompt.setPromptBottomLineVisibility(true)
        prompt.setPromptHeaderBarColor(UIColor(red: 251.0/255.0, green: 22.0/255.0, blue: 80.0/255.0, alpha: 0.8))
        prompt.setPromptBackgroundColor(UIColor(red: 231.0/255.0, green: 232.0/255.0, blue: 233.0/255.0, alpha: 0.85))
        prompt.setPromptHeaderTxtColor(UIColor.whiteColor())
        prompt.setPromptBottomLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.setPromptButtonDividerColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.enableDoubleButtonsOnPrompt()
        prompt.setMainButtonText("Add")
        prompt.setMainButtonColor(UIColor.flatBlackColorDark())
        prompt.setSecondButtonColor(UIColor.flatBlackColorDark())
        prompt.setSecondButtonText("Cancel")
            
        self.view.addSubview(prompt)
    }
    
    // MARK: - Delegate functions for the prompt
    
    func clickedOnTheMainButton() {
        prompt.dismissPrompt()
        GoogleWearAlert.showAlert(title:"Added", image:nil, type: .Success, duration: 2.0, inViewController: self)
        self.favIcon.removeTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
        self.favoritesButton.removeTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
        self.addFavDB()
        self.favIcon.setImage(self.favAdded, forState: .Normal)
        self.favIcon.tintColor = .whiteColor()
        self.favoritesButton.backgroundColor = .whiteColor()
        self.favoritesButton.setTitle("Favorite", forState: .Normal)
        self.favoritesButton.setTitleColor(UIColor(hex: 0xFB2155), forState: .Normal)
        self.favoritesButton.titleLabel!.text = "Favorite"
        self.favoritesButton.titleLabel?.textColor = UIColor(hex: 0xFB2155)
    }
    
    func clickedOnTheRemoveButton() {
        prompt.dismissPrompt()
        GoogleWearAlert.showAlert(title:"Removed", image:nil, type: .Remove, duration: 2.0, inViewController: self)
        self.favIcon.removeTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
        self.favoritesButton.removeTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
        self.removeFavDB()
        self.favIcon.setImage(self.favImage, forState: .Normal)
        self.favIcon.tintColor = UIColor(hex: 0xFB2155)
        self.favoritesButton.backgroundColor = UIColor(hex: 0xFB2155)
        self.favoritesButton.setTitle("Add to Favorites", forState: .Normal)
        self.favoritesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.favoritesButton.titleLabel!.text = "Add to Favorites"
        self.favoritesButton.titleLabel?.textColor = UIColor.whiteColor()
    }
    
    func clickedOnTheSecondButton() {
        prompt.dismissPrompt()
    }
    
    func promptWasDismissed() {
        print("Dismissed the prompt")
    }
    
    func removeFavorite() {
        //Create an instance of SwiftPromptsView and assign its delegate
        prompt = SwiftPromptsView(frame: self.view.bounds)
        prompt.delegate = self
        
        //Set the properties for the background
        prompt.setColorWithTransparency(UIColor.clearColor())
        
        //Set the properties of the promt
        prompt.setPromtHeader("Remove from Favorites")
        prompt.setPromptHeaderTxtTruncate(false)
        prompt.setPromptHeaderTxtSize(18.0)
        prompt.setPromptContentTxtSize(16.0)
        prompt.setPromptContentTextFont("HelveticaNeue-Light")
        prompt.setPromptContentTextRectY(51.0)
        prompt.setPromptHeight(187)
        prompt.setPromptContentTxtColor(UIColor.flatBlackColorDark())
        prompt.setPromptContentText("Are you sure you want to remove this person from your Favorites?")
        prompt.setPromptTopBarVisibility(true)
        prompt.setPromptBottomBarVisibility(false)
        prompt.setPromptTopLineVisibility(false)
        prompt.setPromptBottomLineVisibility(true)
        prompt.setPromptWidth(self.view.bounds.width * 0.65)
        prompt.setPromptHeaderBarColor(UIColor(red: 2.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 0.8))
        prompt.setPromptBackgroundColor(UIColor(red: 231.0/255.0, green: 232.0/255.0, blue: 233.0/255.0, alpha: 0.85))
        prompt.setPromptHeaderTxtColor(UIColor.whiteColor())
        prompt.setPromptBottomLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.setPromptButtonDividerColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.enableDoubleButtonsOnPrompt()
        prompt.setMainButtonText("Remove")
        prompt.setMainButtonColor(UIColor.flatBlackColorDark())
        prompt.setSecondButtonColor(UIColor.flatBlackColorDark())
        prompt.setSecondButtonText("Cancel")
        
        self.view.addSubview(prompt)
    }
    
    func addFavDB() {
        backgroundAddFavorite(person!)
        
        self.favIcon.addTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
        self.favoritesButton.addTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
    }
    
    func removeFavDB() {
        backgroundRemoveFavorite(person!)
        
        self.favIcon.addTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
        self.favoritesButton.addTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
    }
}
