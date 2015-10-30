//
//  KeyboardView.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/26/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import SwiftyUserDefaults

var entrySoFar : String? = nil
var nameSearch = UITextField()

class KeyboardViewController: UIViewController, UITextFieldDelegate {
    var buttonsArray: Array<UIButton> = []
    var buttonsBlurArray = [AnyObject]()
    var keyPresses: Int = 1
    var deleteInput: UIButton!
    var clearSearch: UIButton!
    var moreOptionsForward = UIButton()
    var moreOptionsBack = UIButton()
    var altKeyboard = UIButton()
    var optionsControl: Bool = false
    var moreKeyPresses: Int = 0
    var firstRowKeyStrings = ""
    var secondRowKeyStrings = ""
    var lastRowKeyStrings = ""
    var buttonXFirst: CGFloat!
    var buttonXSecond: CGFloat!
    var buttonXThird: CGFloat!
    var fieldXSearch: CGFloat!
    var altXKeyboard: CGFloat!
    var deleteX: CGFloat!
    var dismissX: CGFloat!
    var clearX: CGFloat!
    var paddingW: CGFloat!
    var moreOptionsX: CGFloat!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if GlobalVariables.sharedManager.keyboardFirst && !GlobalVariables.sharedManager.keyboardOrientChanged {
            GlobalVariables.sharedManager.keyboardFirst = false
            populateKeys()
        } else if GlobalVariables.sharedManager.keyboardOrientChanged {
            keyboardOrient()
            for view in self.view.subviews {
                if view.accessibilityLabel == "keyButton" || view.accessibilityLabel == "altKeys" {
                    view.removeFromSuperview()
                } else if view.accessibilityLabel == "keyBlur" || view.accessibilityLabel == "searchBlur" {
                    view.removeFromSuperview()
                } else if view.accessibilityLabel == "searchField" {
                    view.removeFromSuperview()
                }
            }
            createKeyboard("changed")
            populateKeys()
            GlobalVariables.sharedManager.keyboardFirst = false
            GlobalVariables.sharedManager.keyboardOrientChanged = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardOrient()
        createKeyboard("default")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardOrient() {
        if Defaults[.orient] == "right" {
            buttonXFirst = 260
            buttonXSecond = buttonXFirst
            buttonXThird = buttonXSecond
            fieldXSearch = 10
            altXKeyboard = 0
            dismissX = self.view.frame.width - 40
            deleteX = dismissX - 54
            paddingW = 15
            moreOptionsX = self.view.frame.width - 260
        } else if Defaults[.orient] == "left" {
            buttonXFirst = self.view.frame.width - 10
            buttonXSecond = buttonXFirst
            buttonXThird = buttonXSecond
            fieldXSearch = 111
            altXKeyboard = self.view.frame.width - 50
            dismissX = 10
            deleteX = 64
            paddingW = 41
            moreOptionsX = 10
        }
    }
    
    private class var indexFile : String {
        print("index file path")
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.kannuu.humankontact")!
        let hkIndexPath = directory.path!.stringByAppendingPathComponent("HKIndex")
        return hkIndexPath
    }
    
    func refreshData() {
        dispatch_async(dispatch_get_main_queue()) {
            self.optionsControl = false
            if let indexController = Lookup.lookupController {
                GlobalVariables.sharedManager.objectKeys.removeAll(keepCapacity: false)
                GlobalVariables.sharedManager.objectKeys = indexController.options!
                entrySoFar = indexController.entrySoFar!
                nameSearch.text = entrySoFar?.capitalizedString
                contactsSearchController.searchBar.text = entrySoFar?.capitalizedString
                self.optionsControl = indexController.moreOptions
                if (People.people.count <= 8 && indexController.branchSelectionCount != 0 && self.keyPresses > 1) {
                    self.view.hidden = true
                }
                if (self.optionsControl == true) {
                    if (indexController.atTop == true) {
                        self.moreOptionsBack.hidden = true
                    }
                    if (self.keyPresses > 1 && indexController.optionCount == 9) {
                        self.moreOptionsBack.hidden = true
                    }
                    if self.moreKeyPresses == 1 {
                        self.moreOptionsBack.hidden = false
                    }
                    self.moreOptionsForward.hidden = false
                }
                else if (self.optionsControl == false && indexController.complete == true) {
                    self.moreOptionsForward.hidden = true
                    self.moreOptionsBack.hidden = true
                }
                else if (self.optionsControl == false && self.moreKeyPresses != 2) {
                    if self.keyPresses > 1 && self.moreKeyPresses == 1 {
                        self.moreOptionsForward.hidden = true
                        self.moreOptionsBack.hidden = false
                    } else {
                        self.moreOptionsForward.hidden = true
                        self.moreOptionsBack.hidden = true
                    }
                }
                else if (self.optionsControl == false && self.moreKeyPresses == 2) {
                    if self.keyPresses > 1 {
                        self.moreOptionsForward.hidden = true
                        self.moreOptionsBack.hidden = true
                    } else {
                        self.moreOptionsForward.hidden = true
                    }
                }
            }
        }
    }
    
    func backToInitialView() {
        self.view.hidden = true
        if contactsSearchController.searchBar.text != nil {
            contactsSearchController.searchBar.text = ""
        }
        contactsSearchController.active = false
        if nameSearch.text != nil {
            nameSearch.text = ""
        }
        keyPresses = 1
        if (Lookup.lookupController?.atTop == false) {
            Lookup.lookupController?.restart()
            self.refreshData()
            _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("singleReset"), userInfo: nil, repeats: false)
        }
        GlobalVariables.sharedManager.keyboardFirst = true
    }
    
    func createKeyboard(orient: String) {
        if orient == "default" {
            let BlurredKeyBG = UIImage(named: "BlurredKeyBG")
            let BlurredKeyBGView = UIImageView(image: BlurredKeyBG)
            BlurredKeyBGView.frame = self.view.frame
            BlurredKeyBGView.contentMode = UIViewContentMode.ScaleAspectFill
            BlurredKeyBGView.clipsToBounds = true
        
            self.view.addSubview(BlurredKeyBGView)
        }
        
        nameSearch = UITextField(frame: CGRectMake(fieldXSearch, 10.0, self.view.frame.width - 122, 40.0))
        nameSearch.backgroundColor = UIColor.clearColor()
        nameSearch.borderStyle = UITextBorderStyle.None
        nameSearch.textColor = UIColor(white: 1.0, alpha: 1.0)
        nameSearch.layer.cornerRadius = 12
        
        if Defaults[.orient] == "right" {
            clearX = nameSearch.frame.maxX - 36
        } else if Defaults[.orient] == "left" {
            clearX = nameSearch.frame.minX
        }
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        _ = UIVibrancyEffect(forBlurEffect: blur)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = nameSearch.frame
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        blurView.accessibilityLabel = "searchBlur"
        let paddingView = UIView(frame: CGRectMake(0, 0, paddingW, 40))
        nameSearch.leftView = paddingView
        nameSearch.leftViewMode = UITextFieldViewMode.Always
        nameSearch.enabled = false
        nameSearch.font = UIFont(name: "HelveticaNeue-Regular", size: 19)
        nameSearch.accessibilityLabel = "searchField"
        clearSearch = UIButton(frame: CGRect(x: clearX, y: 12, width: 36, height: 36))
        clearSearch.setImage(UIImage(named: "Clear"), forState: UIControlState.Disabled)
        clearSearch.setImage(UIImage(named: "Clear"), forState: UIControlState.Normal)
        clearSearch.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        clearSearch.enabled = false
        clearSearch.addTarget(self, action: "clearNameSearch", forControlEvents: UIControlEvents.TouchUpInside)
        clearSearch.accessibilityLabel = "altKeys"
        
        self.view.addSubview(blurView)
        self.view.addSubview(nameSearch)
        self.view.addSubview(clearSearch)
        
        altKeyboard.frame = CGRect(x: altXKeyboard, y: 262, width: 50, height: 50)
        altKeyboard.setImage(UIImage(named: "keyAlt"), forState: UIControlState.Normal)
        altKeyboard.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        altKeyboard.addTarget(self, action: "useNormalKeyboard", forControlEvents: UIControlEvents.TouchUpInside)
        altKeyboard.accessibilityLabel = "altKeys"
        
        self.view.addSubview(altKeyboard)
        self.dismissKeyboard(orient)
    }
    
    func dismissKeyboard(orient: String) {
        let dismissKeyboard = UIButton(frame: CGRect(x: dismissX, y: 20, width: 30, height: 30))
        dismissKeyboard.setImage(UIImage(named: "KeyboardReverse"), forState: UIControlState.Normal)
        dismissKeyboard.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        dismissKeyboard.addTarget(self, action: "backToInitialView", forControlEvents: UIControlEvents.TouchUpInside)
        dismissKeyboard.accessibilityLabel = "altKeys"
        
        self.view.addSubview(dismissKeyboard)
        self.deleteBtn(orient)
    }
    
    func useNormalKeyboard() {
        self.view.hidden = true
        contactsSearchController.active = false
        self.view.window?.rootViewController!.presentViewController(normalSearchController, animated: true, completion: nil)
        normalSearchController.active = true
    }
    
    func deleteBtn(orient: String) {
        deleteInput = UIButton(frame: CGRect(x: deleteX, y: 18, width: 26, height: 26))
        if Defaults[.orient] == "right" {
            deleteInput.setImage(UIImage(named: "Delete"), forState: UIControlState.Disabled)
            deleteInput.setImage(UIImage(named: "Delete"), forState: UIControlState.Normal)
        } else {
            deleteInput.setImage(UIImage(named: "DeleteAlt"), forState: UIControlState.Disabled)
            deleteInput.setImage(UIImage(named: "DeleteAlt"), forState: UIControlState.Normal)
        }
        deleteInput.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        deleteInput.enabled = false
        deleteInput.addTarget(self, action: "deleteSearchInput:", forControlEvents: .TouchUpInside)
        deleteInput.accessibilityLabel = "altKeys"
        
        self.view.addSubview(deleteInput)
        self.navKeys()
    }
    
    func populateKeys() {
        for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
            if (index < 3) {
                let keyButton1 = UIButton(frame: CGRect(x: self.view.frame.width - buttonXFirst, y: 75, width: 77, height: 52))
                buttonXFirst = buttonXFirst - 87
                
                keyButton1.layer.cornerRadius = keyButton1.frame.width / 6.0
                keyButton1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                keyButton1.backgroundColor = UIColor.clearColor()
                keyButton1.titleLabel!.font = UIFont(name: "HelveticaNeue-Regular", size: 17.0)
                firstRowKeyStrings = "\(GlobalVariables.sharedManager.objectKeys[index])"
                keyButton1.setTitle(firstRowKeyStrings.capitalizedString, forState: UIControlState.Normal)
                keyButton1.setTitleColor(UIColor(white: 0.0, alpha: 1.0 ), forState: UIControlState.Highlighted)
                keyButton1.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                keyButton1.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                keyButton1.titleLabel!.numberOfLines = 2
                keyButton1.titleLabel!.text = firstRowKeyStrings.capitalizedString
                keyButton1.tag = index
                keyButton1.accessibilityLabel = "keyButton"
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                _ = UIVibrancyEffect(forBlurEffect: blur)
                let blurView1 = UIVisualEffectView(effect: blur)
                blurView1.frame = keyButton1.frame
                blurView1.layer.cornerRadius = keyButton1.frame.width / 6.0
                blurView1.clipsToBounds = true
                blurView1.accessibilityLabel = "keyBlur"
                buttonsArray.append(keyButton1)
                buttonsBlurArray.append(blurView1)
                
                keyButton1.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchDown);
                keyButton1.addTarget(self, action: "buttonNormal:", forControlEvents: UIControlEvents.TouchUpInside);
                
                self.view.addSubview(blurView1)
                self.view.addSubview(keyButton1)
            }
            
            if (index < 6 && index >= 3) {
                let keyButton2 = UIButton(frame: CGRect(x: self.view.frame.width - buttonXSecond, y: 137, width: 77, height: 52))
                buttonXSecond = buttonXSecond - 87
                
                keyButton2.layer.cornerRadius = keyButton2.frame.width / 6.0
                keyButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                keyButton2.backgroundColor = UIColor.clearColor()
                keyButton2.titleLabel!.font = UIFont(name: "HelveticaNeue-Regular", size: 17.0)
                secondRowKeyStrings = "\(GlobalVariables.sharedManager.objectKeys[index])"
                keyButton2.setTitle(secondRowKeyStrings.capitalizedString, forState: UIControlState.Normal)
                keyButton2.setTitleColor(UIColor(white: 0.0, alpha: 1.000 ), forState: UIControlState.Highlighted)
                keyButton2.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                keyButton2.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                keyButton2.titleLabel!.numberOfLines = 2
                keyButton2.titleLabel!.text = secondRowKeyStrings.capitalizedString
                keyButton2.tag = index
                keyButton2.accessibilityLabel = "keyButton"
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                _ = UIVibrancyEffect(forBlurEffect: blur)
                let blurView2 = UIVisualEffectView(effect: blur)
                blurView2.frame = keyButton2.frame
                blurView2.layer.cornerRadius = keyButton2.frame.width / 6.0
                blurView2.clipsToBounds = true
                blurView2.accessibilityLabel = "keyBlur"
                buttonsArray.append(keyButton2)
                buttonsBlurArray.append(blurView2)
                
                keyButton2.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchDown);
                keyButton2.addTarget(self, action: "buttonNormal:", forControlEvents: UIControlEvents.TouchUpInside);
                
                self.view.addSubview(blurView2)
                self.view.addSubview(keyButton2)
            }
            
            if (index < 9 && index >= 6) {
                let keyButton3 = UIButton(frame: CGRect(x: self.view.frame.width - buttonXThird, y: 199, width: 77, height: 52))
                buttonXThird = buttonXThird - 87
                
                keyButton3.layer.cornerRadius = keyButton3.frame.width / 6.0
                keyButton3.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                keyButton3.backgroundColor = UIColor.clearColor()
                keyButton3.titleLabel!.font = UIFont(name: "HelveticaNeue-Regular", size: 17.0)
                lastRowKeyStrings = "\(GlobalVariables.sharedManager.objectKeys[index])"
                keyButton3.setTitle(lastRowKeyStrings.capitalizedString, forState: UIControlState.Normal)
                keyButton3.setTitleColor(UIColor(white: 0.0, alpha: 1.000 ), forState: UIControlState.Highlighted)
                keyButton3.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                keyButton3.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                keyButton3.titleLabel!.numberOfLines = 2
                keyButton3.titleLabel!.text = lastRowKeyStrings.capitalizedString
                keyButton3.tag = index
                keyButton3.accessibilityLabel = "keyButton"
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                _ = UIVibrancyEffect(forBlurEffect: blur)
                let blurView3 = UIVisualEffectView(effect: blur)
                blurView3.frame = keyButton3.frame
                blurView3.layer.cornerRadius = keyButton3.frame.width / 6.0
                blurView3.clipsToBounds = true
                blurView3.accessibilityLabel = "keyBlur"
                buttonsArray.append(keyButton3)
                buttonsBlurArray.append(blurView3)
                
                keyButton3.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchDown);
                keyButton3.addTarget(self, action: "buttonNormal:", forControlEvents: UIControlEvents.TouchUpInside);
                
                self.view.addSubview(blurView3)
                self.view.addSubview(keyButton3)
            }
        }
    }
    
    func navKeys() {
        let backTitle = NSAttributedString(string: "Back", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 17.0)!])
        let moreTitle = NSAttributedString(string: "More", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 17.0)!])
        
        moreOptionsBack.frame = CGRect(x: moreOptionsX, y: 273, width: 50, height: 26)
        moreOptionsBack.setAttributedTitle(backTitle, forState: .Normal)
        moreOptionsBack.tag = 998
        moreOptionsBack.hidden = true
        moreOptionsBack.addTarget(self, action: "respondToMore:", forControlEvents: UIControlEvents.TouchUpInside)
        moreOptionsBack.accessibilityLabel = "altKeys"
        self.view.addSubview(moreOptionsBack)
        
        moreOptionsForward.frame = CGRect(x: moreOptionsX + 196, y: 273, width: 50, height: 26)
        moreOptionsForward.setAttributedTitle(moreTitle, forState: .Normal)
        moreOptionsForward.tag = 999
        moreOptionsForward.hidden = true
        moreOptionsForward.addTarget(self, action: "respondToMore:", forControlEvents: UIControlEvents.TouchUpInside)
        moreOptionsForward.accessibilityLabel = "altKeys"
        self.view.addSubview(moreOptionsForward)
    }
    
    func keyPressed(sender: UIButton!) {
        Lookup.lookupController?.selectOption(sender.tag)
        self.refreshData()
        keyPresses++
        moreKeyPresses = 0
    }
    
    func clearNameSearch() {
        if contactsSearchController.searchBar.text != nil {
            contactsSearchController.searchBar.text = ""
        }
        if nameSearch.text != nil {
            nameSearch.text = ""
        }
        keyPresses = 1
        optionsControl = false
        moreKeyPresses = 0
        Lookup.lookupController?.restart()
        self.refreshData()
        clearSearch.enabled = false
        deleteInput.enabled = false
        _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("singleReset"), userInfo: nil, repeats: false)
    }
    
    func deleteSearchInput(sender: UIButton!) {
        keyPresses--
        if (keyPresses > 1) {
            Lookup.lookupController?.back()
            self.refreshData()
            _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("combinedReset"), userInfo: nil, repeats: false)
        }
        else {
            Lookup.lookupController?.restart()
            self.refreshData()
            clearSearch.enabled = false
            deleteInput.enabled = false
            optionsControl = false
            moreKeyPresses = 0
            _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("singleReset"), userInfo: nil, repeats: false)
        }
    }
    
    func respondToMore(sender: UIButton!) {
        if (sender.tag == 998) {
            moreKeyPresses--
            Lookup.lookupController?.back()
            self.refreshData()
            moreOptionsForward.hidden = false
            _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("respondToBackRefresh"), userInfo: nil, repeats: false)
        }
        if (sender.tag == 999) {
            moreKeyPresses++
            Lookup.lookupController?.more()
            self.refreshData()
            moreOptionsBack.hidden = false
            _ = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("respondToForwardRefresh"), userInfo: nil, repeats: false)
        }
    }
    
    func respondToBackRefresh() {
        let baseKey : String = nameSearch.text!.capitalizedString
        if (keyPresses == 1) {
            for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
                let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
                buttonsArray[index].setTitle("\(keyInput.capitalizedString)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(keyInput.capitalizedString)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
        }
        if (keyPresses > 1) {
            for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
                let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
                let combinedKeys = "\(baseKey)" + "\(keyInput)"
                buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
            if (GlobalVariables.sharedManager.objectKeys.count != self.buttonsArray.count) {
                for key in GlobalVariables.sharedManager.objectKeys.count..<self.buttonsArray.count {
                    buttonsArray[key].hidden = true
                    buttonsBlurArray[key].layer.hidden = true
                }
            }
        }
    }
    
    func respondToForwardRefresh() {
        let baseKey : String = nameSearch.text!.capitalizedString
        if (keyPresses == 1) {
            for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
                let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
                buttonsArray[index].setTitle("\(keyInput.capitalizedString)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(keyInput.capitalizedString)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
            if (GlobalVariables.sharedManager.objectKeys.count != self.buttonsArray.count) {
                for key in GlobalVariables.sharedManager.objectKeys.count..<self.buttonsArray.count {
                    buttonsArray[key].hidden = true
                    buttonsBlurArray[key].layer.hidden = true
                }
            }
        }
        if (keyPresses > 1) {
            for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
                let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
                let combinedKeys = "\(baseKey)" + "\(keyInput)"
                buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
            if (GlobalVariables.sharedManager.objectKeys.count != self.buttonsArray.count) {
                for key in GlobalVariables.sharedManager.objectKeys.count..<self.buttonsArray.count {
                    buttonsArray[key].hidden = true
                    buttonsBlurArray[key].layer.hidden = true
                }
            }
        }
    }
    
    func buttonNormal(sender: UIButton!) {
        sender.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        let baseKey = sender.titleLabel!.text!
        for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
            let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
            let combinedKeys = "\(baseKey)" + "\(keyInput)"
            buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
            buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
            buttonsArray[index].hidden = false
            buttonsBlurArray[index].layer.hidden = false
        }
        if (GlobalVariables.sharedManager.objectKeys.count != self.buttonsArray.count) {
            for key in GlobalVariables.sharedManager.objectKeys.count..<self.buttonsArray.count {
                buttonsArray[key].hidden = true
                buttonsBlurArray[key].layer.hidden = true
            }
        }
        clearSearch.enabled = true
        deleteInput.enabled = true
        sender.backgroundColor = UIColor.clearColor()
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func combinedReset() {
        let base = nameSearch.text!.capitalizedString
        for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
            let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
            let combinedKeys = "\(base)" + "\(keyInput)"
            buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
            buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
            buttonsArray[index].hidden = false
            buttonsBlurArray[index].layer.hidden = false
        }
        if (GlobalVariables.sharedManager.objectKeys.count != self.buttonsArray.count) {
            for key in GlobalVariables.sharedManager.objectKeys.count..<self.buttonsArray.count {
                buttonsArray[key].hidden = true
                buttonsBlurArray[key].layer.hidden = true
            }
        }
    }
    
    func singleReset() {
        for index in 0..<GlobalVariables.sharedManager.objectKeys.count {
            let keyInput = GlobalVariables.sharedManager.objectKeys[index] as! String
            buttonsArray[index].setTitle("\(keyInput.capitalizedString)", forState: UIControlState.Normal)
            buttonsArray[index].titleLabel!.text = "\(keyInput.capitalizedString)"
            buttonsArray[index].hidden = false
            buttonsBlurArray[index].layer.hidden = false
        }
    }
}
