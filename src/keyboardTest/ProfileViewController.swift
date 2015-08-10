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

let offset_HeaderStop:CGFloat = 122.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 54.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 45.0 // The distance between the bottom of the Header and the top of the White Label

class ProfileViewController: UIViewController, UIScrollViewDelegate, SwiftPromptsProtocol {
    var prompt = SwiftPromptsView()
    var person: HKPerson = HKPerson()
    var image:UIImage? = nil
    var imageBG:UIImage? = nil
    var initials: String! = nil
    var nameLabel:String! = nil
    var coLabel:String! = nil
    var jobTitleLabel:String! = nil
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var avatarImage:UIImageView!
    @IBOutlet var header:UIView!
    @IBOutlet var baseLabel: UILabel!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var companyHeaderLabel: UILabel!
    
    var profileBGImageView: UIImageView = UIImageView()
    var personHeader: UIImageView = UIImageView()
    var headerImageView:UIImageView = UIImageView()
    var headerBlurImageView:UIImageView = UIImageView()
    var favIcon: UIButton!
    var profileFieldY: CGFloat = 303
    var profileFieldArray: [String?] = []
    var visibleFields: CGFloat = 0
    var profileField: UIView!
    var profilePhone: String!
    var profileEmail: String!
    var initialsLabel: UILabel! = UILabel()
    let favImage = UIImage(named: "Favs")
    let favAdded = UIImage(named: "love")
    var favIncluded: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "back")
        profileBGImageView = UIImageView(frame: self.view.frame)
        profileBGImageView.image = UIImage(named: "BitmapOverlayBG")
        profileBGImageView.alpha = 0.5
        profileBGImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(profileBGImageView)
        self.view.sendSubviewToBack(profileBGImageView)
        let backTitle = NSAttributedString(string: "Back", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 21.0)!])
        var back = UIButton(frame: CGRect(x: -10, y: 32, width: 112, height: 21))
        back.setImage(image, forState: UIControlState.Normal)
        back.setAttributedTitle(backTitle, forState: UIControlState.Normal)
        back.layer.zPosition = 3
        back.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(back)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        scrollView.delegate = self
        
        //Favorites
        favIcon = UIButton(frame: CGRect(x: (self.view.frame.width - 40), y: 25, width: 32, height: 32))
        favIcon.layer.zPosition = 3
        
        for fav in FavPeople.favorites {
            if fav.fullName == person.fullName {
                favIcon.setImage(favAdded, forState: UIControlState.Normal)
                favIncluded = true
                favIcon.addTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
            }
        }
        
        if !favIncluded {
            favIcon.addTarget(self, action: "favoriteProfile", forControlEvents: UIControlEvents.TouchUpInside)
            favIcon.setImage(favImage, forState: UIControlState.Normal)
        }
        self.view.addSubview(favIcon)
        
        // Header - Image
        var headerSizeOffset: CGFloat = header.frame.width * 0.0833
        var headerYOffset: CGFloat = header.frame.height * 0.1136
        
        personHeader = UIImageView(frame: CGRect(x: -headerSizeOffset, y: headerYOffset, width: header.frame.width - headerSizeOffset, height: header.frame.height - headerSizeOffset))
        personHeader.image = imageBG?.blurredImageWithRadius(20, iterations: 20, tintColor: UIColor(white: 0.7, alpha: 0.3))!
        personHeader.contentMode = .ScaleAspectFill
        
        headerImageView = UIImageView(frame: personHeader.frame)
        headerImageView.contentMode = .ScaleAspectFit
        headerImageView.alpha = 0.7
        headerImageView.addSubview(personHeader)
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        header.backgroundColor = UIColor(gradientStyle: .LeftToRight, withFrame: header.frame, andColors: [UIColor(hex: 0x172445), UIColor(hex: 0x3E6D8E)])
        header.clipsToBounds = true
        
        var profileImageView: UIImageView! = UIImageView(frame: avatarImage.bounds)
        profileImageView.image = image
        profileImageView.contentMode = .ScaleAspectFill
        initialsLabel.frame = CGRect(x: 0, y: 0, width: profileImageView.frame.width, height: profileImageView.frame.height)
        if (initials != nil) {
            initialsLabel.text = initials
        }
        initialsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 28)!
        initialsLabel.textColor = UIColor.whiteColor()
        initialsLabel.textAlignment = NSTextAlignment.Center
        profileImageView.addSubview(initialsLabel)
        avatarImage.insertSubview(profileImageView!, atIndex: 0)
        
        for phone in phonesProfileArray {
            // Grab each key, value pair from the person dictionary
            for (key,value) in phone {
                profilePhone = "\(key): \(value)"
                createPhoneFields(profilePhone)
                visibleFields++
            }
        }
        for email in emailsProfileArray {
            // Grab each key, value pair from the person dictionary
            for (key,value) in email {
                profileEmail = "\(key): \(value)"
                createEmailFields(profileEmail)
                visibleFields++
            }
        }
        if (jobTitleLabel != nil && jobTitleLabel != "") {
            createJobFields("Job Title: \(jobTitleLabel)")
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
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
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
        //var profileFieldBG = UIImageView(frame: CGRect(x: 0, y: 303, width: self.view.frame.width, height: (55*visibleFields)-11))
        //profileFieldBG.image = imageBG?.blurredImageWithRadius(20, iterations: 20, tintColor: UIColor(white: 0.7, alpha: 0.3))
        //profileFieldBG.contentMode = UIViewContentMode.ScaleAspectFill
        //profileFieldBG.clipsToBounds = true
        //scrollView.insertSubview(profileFieldBG, atIndex: 0)
    }
    
    func createPhoneFields(sender: String!) {
        profileField = UIView(frame: CGRect(x: 0, y: profileFieldY, width: self.view.frame.width, height: 44))
        profileFieldY = profileFieldY + 55
        profileField.backgroundColor = UIColor(gradientStyle: UIGradientStyle.LeftToRight, withFrame: profileField.frame, andColors: [FlatHKDark(), UIColor(white: 1.0, alpha: 0.4)])
        profileField.alpha = 0.7
        profileField.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: profileField.bounds, cornerRadius: 0)
        
        profileField.layer.masksToBounds = false
        profileField.layer.shadowColor = UIColor.blackColor().CGColor
        profileField.layer.shadowOffset = CGSize(width: 0, height: 2);
        profileField.layer.shadowOpacity = 0.3
        profileField.layer.shadowPath = shadowPath.CGPath
        
        var profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 11, width: 380, height: 21))
        profileFieldLabel.textColor = UIColor.whiteColor()
        profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        profileFieldLabel.text = (sender)!
        
        profileField.addSubview(profileFieldLabel)
        
        var mobilePhoneBtn = UIButton(frame: CGRect(x: 224, y: 11, width: 22, height: 22))
        mobilePhoneBtn.setImage(UIImage(named: "profileUtility1"), forState: UIControlState.Normal)
        mobilePhoneBtn.tag = 50
        mobilePhoneBtn.setTitle(sender, forState: UIControlState.Normal)
        mobilePhoneBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        mobilePhoneBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        mobilePhoneBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
        profileField.addSubview(mobilePhoneBtn)
        var mobileTxtBtn = UIButton(frame: CGRect(x: 280, y: 11, width: 22, height: 22))
        mobileTxtBtn.setImage(UIImage(named: "profileUtility2"), forState: UIControlState.Normal)
        mobileTxtBtn.tag = 51
        mobileTxtBtn.setTitle(sender, forState: UIControlState.Normal)
        mobileTxtBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        mobileTxtBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        mobileTxtBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
        profileField.addSubview(mobileTxtBtn)
        facetimeOption(sender)
        scrollView.addSubview(profileField)
    }
    
    func createEmailFields(sender: String!) {
        profileField = UIView(frame: CGRect(x: 0, y: profileFieldY, width: self.view.frame.width, height: 44))
        profileFieldY = profileFieldY + 55
        profileField.backgroundColor = UIColor(gradientStyle: UIGradientStyle.LeftToRight, withFrame: profileField.frame, andColors: [FlatHKDark(), UIColor(white: 1.0, alpha: 0.4)])
        profileField.alpha = 0.7
        profileField.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: profileField.bounds, cornerRadius: 0)
        
        profileField.layer.masksToBounds = false
        profileField.layer.shadowColor = UIColor.blackColor().CGColor
        profileField.layer.shadowOffset = CGSize(width: 0, height: 2);
        profileField.layer.shadowOpacity = 0.3
        profileField.layer.shadowPath = shadowPath.CGPath
        
        var profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 11, width: 380, height: 21))
        profileFieldLabel.textColor = UIColor.whiteColor()
        profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        profileFieldLabel.text = (sender)!
        
        profileField.addSubview(profileFieldLabel)
        var emailBtn = UIButton(frame: CGRect(x: 336, y: 9, width: 28, height: 28))
        emailBtn.setImage(UIImage(named: "profileUtility3"), forState: UIControlState.Normal)
        emailBtn.tag = 53
        emailBtn.setTitle(sender, forState: UIControlState.Normal)
        emailBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        emailBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        emailBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
        profileField.addSubview(emailBtn)
        scrollView.addSubview(profileField)
    }
    
    func createJobFields(sender: String!) {
        profileField = UIView(frame: CGRect(x: 0, y: profileFieldY, width: self.view.frame.width, height: 44))
        profileFieldY = profileFieldY + 55
        profileField.backgroundColor = UIColor(gradientStyle: UIGradientStyle.LeftToRight, withFrame: profileField.frame, andColors: [FlatHKDark(), UIColor(white: 1.0, alpha: 0.4)])
        profileField.alpha = 0.7
        profileField.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: profileField.bounds, cornerRadius: 0)
        
        profileField.layer.masksToBounds = false
        profileField.layer.shadowColor = UIColor.blackColor().CGColor
        profileField.layer.shadowOffset = CGSize(width: 0, height: 2);
        profileField.layer.shadowOpacity = 0.3
        profileField.layer.shadowPath = shadowPath.CGPath
        
        var profileFieldLabel = UILabel(frame: CGRect(x: 10, y: 11, width: 380, height: 21))
        profileFieldLabel.textColor = UIColor.whiteColor()
        profileFieldLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        profileFieldLabel.text = (sender)!
        
        profileField.addSubview(profileFieldLabel)
        scrollView.addSubview(profileField)
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
            var index = emailToSend.indexOfCharacter(":")!
            var cleanedEmail = emailToSend.substringFromIndex(index+1).removeWhitespace()
            emailPressed(cleanedEmail)
        }
    }
    
    func callPressed (sender: AnyObject!) {
        var phoneNumber: String! = sender as? String
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (count(cleanNumber.utf16) > 1){
            callNumber(cleanNumber)
        } else {
            let alert = UIAlertView()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    func textPressed (sender: AnyObject!) {
        var phoneNumber: String! = sender as? String
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (count(cleanNumber.utf16) > 1){
            textNumber(cleanNumber)
        } else {
            let alert = UIAlertView()
            alert.title = "Sorry!"
            alert.message = "Phone number is not available for text messaging."
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    func facetimeOption (sender: String!) {
        var phoneNumber = sender
        var strippedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9 ]", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range:nil);
        var cleanNumber = strippedPhoneNumber.removeWhitespace()
        cleanNumber.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (count(cleanNumber.utf16) > 1){
            facetime(cleanNumber)
        }
        else {
            return
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
    
    private func facetime(phoneNumber:String) {
        if let facetimeURL:NSURL = NSURL(string: "facetime://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(facetimeURL)) {
                var mobileFacetimeBtn = UIButton(frame: CGRect(x: 336, y: 13, width: 32, height: 18))
                mobileFacetimeBtn.setImage(UIImage(named: "profileUtility4"), forState: UIControlState.Normal)
                mobileFacetimeBtn.tag = 52
                mobileFacetimeBtn.setTitle(phoneNumber, forState: UIControlState.Normal)
                mobileFacetimeBtn.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                mobileFacetimeBtn.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
                mobileFacetimeBtn.addTarget(self, action: "profileActions:", forControlEvents: UIControlEvents.TouchDown)
                profileField.addSubview(mobileFacetimeBtn)
            }
        }
    }
    
    private func facetimePressed(phoneNumber:String) {
        if let facetimeURL:NSURL = NSURL(string: "facetime://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(facetimeURL)) {
                application.openURL(facetimeURL);
            } else {
                let alert = UIAlertView()
                alert.title = "Sorry!"
                alert.message = "Phone number is not available for Facetime."
                alert.addButtonWithTitle("Ok")
                alert.show()
            }
        }
    }
    
    private func emailPressed(email:String) {
        println(email)
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
        
        var offset = scrollView.contentOffset.y
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
                }
                
            } else {
                if avatarImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
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
        favPeople.append(self.person)
        self.favIcon.removeTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
        self.backgroundAddFavorite()
        self.favIcon.setImage(self.favAdded, forState: .Normal)
    }
    
    func clickedOnTheRemoveButton() {
        prompt.dismissPrompt()
        GoogleWearAlert.showAlert(title:"Removed", image:nil, type: .Remove, duration: 2.0, inViewController: self)
        self.favIcon.removeTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
        self.removeFavDB()
        self.favIcon.setImage(self.favImage, forState: .Normal)
    }
    
    func clickedOnTheSecondButton() {
        prompt.dismissPrompt()
    }
    
    func promptWasDismissed() {
        println("Dismissed the prompt")
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
    
    func backgroundAddFavorite() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            favResults.fetchFavorites()
        }
        self.favIcon.addTarget(self, action: "removeFavorite", forControlEvents: .TouchUpInside)
    }
    
    func removeFavDB() {
        favRealm.beginWrite()
        favRealm.delete(person)
        favRealm.commitWrite()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            favResults.fetchFavorites()
        }
        self.favIcon.addTarget(self, action: "favoriteProfile", forControlEvents: .TouchUpInside)
    }
}

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
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
}

extension UIButton {
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var relativeFrame = self.bounds
        var hitTestEdgeInsets = UIEdgeInsetsMake(-22, -22, -22, -22)
        var hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
    }
}
