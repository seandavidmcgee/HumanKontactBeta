//
//  SwiftPromptsView.swift
//  Swift-Prompts
//
//  Created by Gabriel Alvarado on 3/15/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import Foundation
import UIKit

@objc protocol SwiftPromptsProtocol
{
    optional func clickedOnTheMainButton()
    optional func clickedOnTheSecondButton()
    optional func promptWasDismissed()
    optional func clickedOnTheRemoveButton()
}

extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func truncate(length: Int, trailing: String? = nil) -> String {
        if count(self) > length {
            return self.substringToIndex(advance(self.startIndex, length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}

class SwiftPromptsView: UIView
{
    //Delegate var
    var delegate : SwiftPromptsProtocol?
    
    //Variables for the background view
    private var blurringLevel : CGFloat = 5.0
    private var colorWithTransparency = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0)
    private var enableBlurring : Bool = true
    private var enableTransparencyWithColor : Bool = true
    
    //Variables for the prompt with their default values
    private var promptHeight : CGFloat = 197.0
    private var promptWidth : CGFloat = 225.0
    private var promtHeader : String = "Success"
    private var promptHeaderTxtSize : CGFloat = 20.0
    private var promptHeaderTxtTruncate: Bool = true
    private var promptContentText : String = "You have successfully posted this item to your Facebook wall."
    private var promptContentTextFont : String = "AvenirNext-Regular"
    private var promptContentTextRectY : CGFloat = 23.0
    private var promptInitialsText : String = ""
    private var promptContentTxtSize : CGFloat = 18.0
    private var promptTopBarVisibility : Bool = false
    private var promptBottomBarVisibility : Bool = true
    private var promptTopLineVisibility : Bool = true
    private var promptBottomLineVisibility : Bool = false
    private var promptOutlineVisibility : Bool = false
    private var promptButtonDividerVisibility : Bool = true
    private var promptDismissIconVisibility : Bool = false
    private var promptInitialsVisibility : Bool = false
    
    //Colors of the items within the prompt
    private var promptBackgroundColor : UIColor = UIColor.whiteColor()
    private var promptHeaderBarColor : UIColor = UIColor.clearColor()
    private var promptBottomBarColor : UIColor = UIColor(red: 34.0/255.0, green: 192.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    private var promptHeaderTxtColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptContentTxtColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptOutlineColor : UIColor = UIColor.clearColor()
    private var promptTopLineColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptBottomLineColor : UIColor = UIColor.clearColor()
    private var promptButtonDividerColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptDismissIconColor : UIColor = UIColor.whiteColor()
    
    //Button panel vars
    private var enableDoubleButtons : Bool = false
    private var mainButtonText : String = "Post"
    private var secondButtonText : String = "Cancel"
    private var mainButtonColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var secondButtonColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    
    //Profile action buttons
    var person: HKPerson! = nil
    var homeCallImage = UIImage(named: "CallHome") as UIImage?
    var homeCallButton = UIButton()
    var enableHomeButton : Bool = false
    var workCallImage = UIImage(named: "CallWork") as UIImage?
    var workCallButton = UIButton()
    var enableWorkButton : Bool = false
    var iPhoneCallImage = UIImage(named: "CalliPhone") as UIImage?
    var iPhoneCallButton = UIButton()
    var enableiPhoneButton : Bool = false
    var mobileCallImage = UIImage(named: "CallMobile") as UIImage?
    var mobileCallButton = UIButton()
    var enableMobileButton : Bool = false
    var messageImage = UIImage(named: "Messaging") as UIImage?
    var messageButton = UIButton()
    var iPhoneMessageImage = UIImage(named: "MessagingiPhone") as UIImage?
    var iPhoneMessageButton = UIButton()
    var emailImage = UIImage(named: "Email") as UIImage?
    var emailButton = UIButton()
    var enableEmailButton : Bool = false
    var secondEmailButton = UIButton()
    var enableSecondEmailButton : Bool = false
    
    var mobileIncluded: Bool = false
    var workIncluded: Bool = false
    var homeIncluded: Bool = false
    var iPhoneIncluded: Bool = false
    var emailIncluded: Bool = false
    
    //Gesture enabling
    private var enablePromptGestures : Bool = true
    
    //Declare the enum for use in the construction of the background switch
    enum TypeOfBackground
    {
        case LeveledBlurredWithTransparencyView
        case LightBlurredEffect
        case ExtraLightBlurredEffect
        case DarkBlurredEffect
    }
    var backgroundType = TypeOfBackground.LeveledBlurredWithTransparencyView
    
    //Construct the prompt by overriding the view's drawRect
    override func drawRect(rect: CGRect)
    {
        var backgroundImage : UIImage = snapshot(self.superview)
        var effectImage : UIImage!
        var transparencyAndColorImageView : UIImageView!
        
        //Construct the prompt's background
        switch backgroundType
        {
        case .LeveledBlurredWithTransparencyView:
            if (enableBlurring) {
                effectImage = backgroundImage.applyBlurWithRadius(blurringLevel, tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)
                var blurredImageView = UIImageView(image: effectImage)
                self.addSubview(blurredImageView)
            }
            if (enableTransparencyWithColor) {
                transparencyAndColorImageView = UIImageView(frame: self.bounds)
                transparencyAndColorImageView.backgroundColor = colorWithTransparency;
                self.addSubview(transparencyAndColorImageView)
            }
        case .LightBlurredEffect:
            effectImage = backgroundImage.applyLightEffect()
            var lightEffectImageView = UIImageView(image: effectImage)
            self.addSubview(lightEffectImageView)
            
        case .ExtraLightBlurredEffect:
            effectImage = backgroundImage.applyExtraLightEffect()
            var extraLightEffectImageView = UIImageView(image: effectImage)
            self.addSubview(extraLightEffectImageView)
            
        case .DarkBlurredEffect:
            effectImage = backgroundImage.applyDarkEffect()
            var darkEffectImageView = UIImageView(image: effectImage)
            self.addSubview(darkEffectImageView)
        }
        
        //Create the prompt and assign its size and position
        var promptSize = CGRect(x: 0, y: 0, width: promptWidth, height: promptHeight)
        var swiftPrompt = PromptBoxView(master: self)
        swiftPrompt.backgroundColor = UIColor.clearColor()
        swiftPrompt.tag = 99
        swiftPrompt.center = CGPointMake(self.center.x, self.center.y)
        self.addSubview(swiftPrompt)
        
        //Add the button(s) on the bottom of the prompt
        if (enableDoubleButtons == false)
        {
            let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.frame = CGRectMake(0, promptHeight-52, promptWidth, 41)
            button.setTitleColor(mainButtonColor, forState: .Normal)
            button.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            button.setTitle(mainButtonText, forState: UIControlState.Normal)
            button.tag = 1
            button.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
    
            swiftPrompt.addSubview(button)
        }
        else
        {
            if (promptButtonDividerVisibility) {
                var divider = UIView(frame: CGRectMake(promptWidth/2, promptHeight-47, 0.5, 31))
                divider.backgroundColor = promptButtonDividerColor
                
                swiftPrompt.addSubview(divider)
            }
            
            let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.frame = CGRectMake(promptWidth/2, promptHeight-52, promptWidth/2, 41)
            button.setTitleColor(mainButtonColor, forState: .Normal)
            button.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            button.setTitle(mainButtonText, forState: UIControlState.Normal)
            button.tag = 1
            button.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(button)
            
            let secondButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            secondButton.frame = CGRectMake(0, promptHeight-52, promptWidth/2, 41)
            secondButton.setTitleColor(secondButtonColor, forState: .Normal)
            secondButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            secondButton.setTitle(secondButtonText, forState: UIControlState.Normal)
            secondButton.tag = 2
            secondButton.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(secondButton)
            if (enableiPhoneButton == true) {
                homeCallButton.frame = CGRectMake(15, promptHeight/2.25, 50, 50)
                homeCallButton.setImage(homeCallImage, forState: .Normal)
                homeCallButton.layer.cornerRadius = homeCallButton.frame.width / 2.0
                homeCallButton.contentMode = UIViewContentMode.ScaleAspectFit
                homeCallButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                homeCallButton.tag = 85
                homeCallButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(homeCallButton)
            }
            if (enableWorkButton == true) {
                workCallButton.frame = CGRectMake(15, promptHeight/2.25, 50, 50)
                workCallButton.setImage(workCallImage, forState: .Normal)
                workCallButton.layer.cornerRadius = homeCallButton.frame.width / 2.0
                workCallButton.contentMode = UIViewContentMode.ScaleAspectFit
                workCallButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                workCallButton.tag = 86
                workCallButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(workCallButton)
            }
            if (enableiPhoneButton == true) {
                iPhoneCallButton.frame = CGRectMake(15, promptHeight/2.25, 50, 50)
                iPhoneCallButton.setImage(iPhoneCallImage, forState: .Normal)
                iPhoneCallButton.layer.cornerRadius = iPhoneCallButton.frame.width / 2.0
                iPhoneCallButton.contentMode = UIViewContentMode.ScaleAspectFit
                iPhoneCallButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                iPhoneCallButton.tag = 87
                iPhoneCallButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(iPhoneCallButton)
            
                iPhoneMessageButton.frame = CGRectMake(promptWidth/2 - 25, promptHeight/2.25, 50, 50)
                iPhoneMessageButton.setImage(iPhoneMessageImage, forState: .Normal)
                iPhoneMessageButton.layer.cornerRadius = messageButton.frame.width / 2.0
                iPhoneMessageButton.contentMode = UIViewContentMode.ScaleAspectFit
                iPhoneMessageButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                iPhoneMessageButton.tag = 88
                iPhoneMessageButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(iPhoneMessageButton)
            }
            if (enableMobileButton == true) {
                mobileCallButton.frame = CGRectMake(15, promptHeight/2.25, 50, 50)
                mobileCallButton.setImage(mobileCallImage, forState: .Normal)
                mobileCallButton.layer.cornerRadius = mobileCallButton.frame.width / 2.0
                mobileCallButton.contentMode = UIViewContentMode.ScaleAspectFit
                mobileCallButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                mobileCallButton.tag = 87
                mobileCallButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(mobileCallButton)
            
                messageButton.frame = CGRectMake(promptWidth/2 - 25, promptHeight/2.25, 50, 50)
                messageButton.setImage(messageImage, forState: .Normal)
                messageButton.layer.cornerRadius = messageButton.frame.width / 2.0
                messageButton.contentMode = UIViewContentMode.ScaleAspectFit
                messageButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                messageButton.tag = 88
                messageButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(messageButton)
            }
            if (enableEmailButton == true) {
                if (!enableMobileButton && !enableiPhoneButton && !enableWorkButton && !enableHomeButton) {
                    emailButton.frame = CGRectMake(15, promptHeight/2.25, 50, 50)
                }
                else {
                    emailButton.frame = CGRectMake(promptWidth-65, promptHeight/2.25, 50, 50)
                }
                emailButton.setImage(emailImage, forState: .Normal)
                emailButton.layer.cornerRadius = emailButton.frame.width / 2.0
                emailButton.contentMode = UIViewContentMode.ScaleAspectFit
                emailButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                emailButton.tag = 89
                emailButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
            
                swiftPrompt.addSubview(emailButton)
            }
            if (enableSecondEmailButton == true) {
                if ((enableMobileButton && enableiPhoneButton && enableWorkButton && enableHomeButton) == false) {
                    secondEmailButton.frame = CGRectMake(promptWidth/2 - 25, promptHeight/2.25, 50, 50)
                } else {
                    secondEmailButton.frame = CGRectMake(promptWidth-15, promptHeight/2.25, 50, 50)
                }
                secondEmailButton.setImage(emailImage, forState: .Normal)
                secondEmailButton.layer.cornerRadius = secondEmailButton.frame.width / 2.0
                secondEmailButton.contentMode = UIViewContentMode.ScaleAspectFit
                secondEmailButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
                secondEmailButton.tag = 89
                secondEmailButton.addTarget(self, action: "didPressButton:", forControlEvents: .TouchUpInside)
                
                swiftPrompt.addSubview(secondEmailButton)
            }
        }
        
        //Add the top dismiss button if enabled
        if (promptDismissIconVisibility)
        {
            let dismissButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            dismissButton.frame = CGRectMake(5, 17, 35, 35)
            dismissButton.addTarget(self, action: "dismissPrompt", forControlEvents: UIControlEvents.TouchUpInside)
            
            if (promptInitialsVisibility)
            {
                let initials2Path = UILabel(frame: CGRect(x: 2.5, y: -9, width: 35, height: 35))
                initials2Path.font = UIFont(name: "HelveticaNeue-Thin", size: 21)!
                initials2Path.textColor = UIColor.whiteColor()
                initials2Path.textAlignment = NSTextAlignment.Center
                initials2Path.text = promptInitialsText
                dismissButton.addSubview(initials2Path)
            }
            
            swiftPrompt.addSubview(dismissButton)
        }
        
        if (promptHeaderTxtTruncate)
        {
            promtHeader = promtHeader.truncate(17, trailing: "...")
        }
        
        //Apply animation effect to present this view
        var applicationLoadViewIn = CATransition()
        applicationLoadViewIn.duration = 0.4
        applicationLoadViewIn.type = kCATransitionReveal
        applicationLoadViewIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.addAnimation(applicationLoadViewIn, forKey: kCATransitionReveal)
    }
    
    func panelButtonAction(sender:UIButton?)
    {
        switch (sender!.tag) {
        case 1:
            if promtHeader != "Remove from Favorites" {
                delegate?.clickedOnTheMainButton?()
            } else {
                delegate?.clickedOnTheRemoveButton?()
            }
        case 2:
            delegate?.clickedOnTheSecondButton?()
            
        default:
            delegate?.promptWasDismissed?()
        }
    }
    
    // MARK: - Helper Functions
    func snapshot(view: UIView!) -> UIImage!
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        var image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func dismissPrompt()
    {
        UIView.animateWithDuration(0.6, animations: {
            self.layer.opacity = 0.0
            }, completion: {
                (value: Bool) in
                self.delegate?.promptWasDismissed?()
                self.removeFromSuperview()
        })
    }
    
    func didPressButton(button:UIButton) {
        var infoToSend: String! = button.titleLabel!.text!
        recentPeople.append(person)
        if (infoToSend != nil) {
            if (button.tag == 85 || button.tag == 86 || button.tag == 87) {
                callNumber(infoToSend)
            }
            if (button.tag == 88) {
                textNumber(infoToSend)
            }
            if (button.tag == 89) {
                emailPressed(infoToSend)
            }
        } else {
            return
        }
    }
    
    private func callNumber(phoneNumber:String) {
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
    
    // MARK: - API Functions For The Background
    func setBlurringLevel(level: CGFloat) { blurringLevel = level }
    func setColorWithTransparency(color: UIColor) { colorWithTransparency = color }
    func enableBlurringView (enabler : Bool) { enableBlurring = enabler; backgroundType = TypeOfBackground.LeveledBlurredWithTransparencyView; }
    func enableTransparencyWithColorView (enabler : Bool) { enableTransparencyWithColor = enabler; backgroundType = TypeOfBackground.LeveledBlurredWithTransparencyView; }
    func enableLightEffectView () { backgroundType = TypeOfBackground.LightBlurredEffect }
    func enableExtraLightEffectView () { backgroundType = TypeOfBackground.ExtraLightBlurredEffect }
    func enableDarkEffectView () { backgroundType = TypeOfBackground.DarkBlurredEffect }
    
    // MARK: - API Functions For The Prompt
    func setPromptHeight (height : CGFloat) { promptHeight = height }
    func setPromptWidth (width : CGFloat) { promptWidth = width }
    func setPromtHeader (header : String) { promtHeader = header }
    func setPromptHeaderTxtSize (headerTxtSize : CGFloat) { promptHeaderTxtSize = headerTxtSize }
    func setPromptHeaderTxtTruncate (headerTxtTruncate : Bool) { promptHeaderTxtTruncate = headerTxtTruncate }
    func setPromptContentText (contentTxt : String) { promptContentText = contentTxt }
    func setPromptContentTextFont (contentTxtFont: String) { promptContentTextFont = contentTxtFont }
    func setPromptContentTextRectY (contentTxtRectY: CGFloat) { promptContentTextRectY = contentTxtRectY }
    func setPromptContentTxtSize (contentTxtSize : CGFloat) { promptContentTxtSize = contentTxtSize }
    func setPromptTopBarVisibility (topBarVisibility : Bool) { promptTopBarVisibility = topBarVisibility }
    func setPromptBottomBarVisibility (bottomBarVisibility : Bool) { promptBottomBarVisibility = bottomBarVisibility }
    func setPromptTopLineVisibility (topLineVisibility : Bool) { promptTopLineVisibility = topLineVisibility }
    func setPromptBottomLineVisibility (bottomLineVisibility : Bool) { promptBottomLineVisibility = bottomLineVisibility }
    func setPromptOutlineVisibility (outlineVisibility: Bool) { promptOutlineVisibility = outlineVisibility }
    func setPromptBackgroundColor (backgroundColor : UIColor) { promptBackgroundColor = backgroundColor }
    func setPromptHeaderBarColor (headerBarColor : UIColor) { promptHeaderBarColor = headerBarColor }
    func setPromptBottomBarColor (bottomBarColor : UIColor) { promptBottomBarColor = bottomBarColor }
    func setPromptHeaderTxtColor (headerTxtColor  : UIColor) { promptHeaderTxtColor =  headerTxtColor}
    func setPromptContentTxtColor (contentTxtColor : UIColor) { promptContentTxtColor = contentTxtColor }
    func setPromptOutlineColor (outlineColor : UIColor) { promptOutlineColor = outlineColor }
    func setPromptTopLineColor (topLineColor : UIColor) { promptTopLineColor = topLineColor }
    func setPromptBottomLineColor (bottomLineColor : UIColor) { promptBottomLineColor = bottomLineColor }
    func enableDoubleButtonsOnPrompt () { enableDoubleButtons = true }
    func enableHomeButtonOnPrompt () { enableHomeButton = true }
    func enableWorkButtonOnPrompt () { enableWorkButton = true }
    func enableiPhoneButtonOnPrompt () { enableiPhoneButton = true }
    func enableMobileButtonOnPrompt () { enableMobileButton = true }
    func enableEmailButtonOnPrompt () { enableEmailButton = true }
    func enableSecondEmailButtonOnPrompt () { enableSecondEmailButton = true }
    func setMainButtonText (buttonTitle : String) { mainButtonText = buttonTitle }
    func setSecondButtonText (secondButtonTitle : String) { secondButtonText = secondButtonTitle }
    func setMainButtonColor (colorForButton : UIColor) { mainButtonColor = colorForButton }
    func setSecondButtonColor (colorForSecondButton : UIColor) { secondButtonColor = colorForSecondButton }
    func setPromptButtonDividerColor (dividerColor : UIColor) { promptButtonDividerColor = dividerColor }
    func setPromptButtonDividerVisibility (dividerVisibility : Bool) { promptButtonDividerVisibility = dividerVisibility }
    func setPromptDismissIconColor (dismissIconColor : UIColor) { promptDismissIconColor = dismissIconColor }
    func setPromptDismissIconVisibility (dismissIconVisibility : Bool) { promptDismissIconVisibility = dismissIconVisibility }
    func setPromptInitialsVisibility (initialsVisibility : Bool) { promptInitialsVisibility = initialsVisibility }
    func setPromptInitialsText (initialsTxt : String) { promptInitialsText = initialsTxt }
    func enableGesturesOnPrompt (gestureEnabler : Bool) { enablePromptGestures = gestureEnabler }
    
    // MARK: - Create The Prompt With A UIView Sublass
    class PromptBoxView: UIView
    {
        //Mater Class
        let masterClass : SwiftPromptsView
        
        //Gesture Recognizer Vars
        var lastLocation:CGPoint = CGPointMake(197, 235)
        
        init(master: SwiftPromptsView)
        {
            //Create a link to the parent class to access its vars and init with the prompts size
            masterClass = master
            var promptSize = CGRect(x: 0, y: 0, width: masterClass.promptWidth, height: masterClass.promptHeight)
            super.init(frame: promptSize)
            
            // Initialize Gesture Recognizer
            if (masterClass.enablePromptGestures) {
                var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
                self.gestureRecognizers = [panRecognizer]
            }
        }

        required init(coder aDecoder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func drawRect(rect: CGRect)
        {
            //Call to the SwiftPrompts drawSwiftPrompt func, this handles the drawing of the prompt
            SwiftPrompts.drawSwiftPrompt(frame: self.bounds, backgroundColor: masterClass.promptBackgroundColor, headerBarColor: masterClass.promptHeaderBarColor, bottomBarColor: masterClass.promptBottomBarColor, headerTxtColor: masterClass.promptHeaderTxtColor, contentTxtColor: masterClass.promptContentTxtColor, outlineColor: masterClass.promptOutlineColor, topLineColor: masterClass.promptTopLineColor, bottomLineColor: masterClass.promptBottomLineColor, dismissIconButton: masterClass.promptDismissIconColor, promptText: masterClass.promptContentText, textSize: masterClass.promptContentTxtSize, topBarVisibility: masterClass.promptTopBarVisibility, bottomBarVisibility: masterClass.promptBottomBarVisibility, headerText: masterClass.promtHeader, headerSize: masterClass.promptHeaderTxtSize, topLineVisibility: masterClass.promptTopLineVisibility, bottomLineVisibility: masterClass.promptBottomLineVisibility, outlineVisibility: masterClass.promptOutlineVisibility, dismissIconVisibility: masterClass.promptDismissIconVisibility, initialsVisibility: masterClass.promptInitialsVisibility, initialsText: masterClass.promptInitialsText, contentTxtFont: masterClass.promptContentTextFont, contentTxtRectY: masterClass.promptContentTextRectY)
        }
        
        func detectPan(recognizer:UIPanGestureRecognizer)
        {
            var translation  = recognizer.translationInView(self)
            self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
            
            var verticalDistanceFromCenter : CGFloat = fabs(translation.y)
            var horizontalDistanceFromCenter : CGFloat = fabs(translation.x)
            var shouldDismissPrompt : Bool = false
            
            //Dim the prompt accordingly to the specified radius
            if (verticalDistanceFromCenter < 100.0) {
                var radiusAlphaLevel : CGFloat = 1.0 - verticalDistanceFromCenter/100
                self.alpha = radiusAlphaLevel
                //self.superview!.alpha = radiusAlphaLevel
                shouldDismissPrompt = false
            } else {
                self.alpha = 0.0
                //self.superview!.alpha = 0.0
                shouldDismissPrompt = true
            }
            
            //Handle the end of the pan gesture
            if (recognizer.state == UIGestureRecognizerState.Ended)
            {
                if (shouldDismissPrompt == true) {
                    UIView.animateWithDuration(0.6, animations: {
                        self.layer.opacity = 0.0
                        self.masterClass.layer.opacity = 0.0
                        }, completion: {
                            (value: Bool) in
                            self.masterClass.delegate?.promptWasDismissed?()
                            self.removeFromSuperview()
                            self.masterClass.removeFromSuperview()
                    })
                } else
                {
                    UIView.animateWithDuration(0.3, animations: {
                        self.center = self.masterClass.center
                        self.alpha = 1.0
                        //self.superview!.alpha = 1.0
                    })
                }
            }
        }
        
        override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
        {
            // Remember original location
            lastLocation = self.center
        }
    }
}
