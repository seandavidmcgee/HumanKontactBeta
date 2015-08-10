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

var entrySoFar : String? = nil
var nameSearch = UITextField()

class KeyboardViewController: UIViewController, UITextFieldDelegate {
    
    var buttonsArray: Array<UIButton> = []
    var buttonsBlurArray = [AnyObject]()
    var buttonXFirst: CGFloat = 250
    var buttonXSecond: CGFloat = 250
    var buttonXThird: CGFloat = 250
    var keyPresses: Int = 1
    var deleteInput: UIButton!
    var clearSearch: UIButton!
    var moreOptionsForward: UIButton! = UIButton()
    var moreOptionsBack: UIButton! = UIButton()
    var altKeyboard: UIButton! = UIButton()
    var textFieldInsideSearchBar = contactsSearchController.searchBar.valueForKey("searchField") as? UITextField
    var optionsControl: Bool! = false
    var moreKeyPresses: Int = 0
    var firstRowKeyStrings = ""
    var secondRowKeyStrings = ""
    var lastRowKeyStrings = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createKeyboard()
        dismissKeyboard()
        deleteBtn()
        navKeys()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        dispatch_async(dispatch_get_main_queue()) {
            self.optionsControl == false
            if var indexController = lookupController {
                myResults.removeAll(keepCapacity: false)
                objectKeys.removeAll(keepCapacity: false)
                objectKeys = indexController.options!
                var selections = indexController.branchSelecions!
                myResults += selections
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
                    self.moreOptionsForward.hidden = false
                }
                else if (self.optionsControl == false && indexController.complete == true) {
                    self.moreOptionsForward.hidden = true
                    self.moreOptionsBack.hidden = true
                    self.view.hidden = true
                }
                else if (self.optionsControl == false && self.moreKeyPresses != 2) {
                    self.moreOptionsForward.hidden = true
                    self.moreOptionsBack.hidden = true
                }
                else if (self.optionsControl == false && self.moreKeyPresses == 2) {
                    self.moreKeyPresses = 0
                    self.moreOptionsForward.hidden = true
                }
            }
        }
    }
    
    func backToInitialView() {
        self.view.hidden = true
        contactsSearchController.searchBar.text! = ""
        contactsSearchController.active = false
        nameSearch.text! = ""
        keyPresses == 1
        if (lookupController!.atTop == false) {
            lookupController?.restart()
            self.refreshData()
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("singleReset"), userInfo: nil, repeats: false)
        }
    }
    
    func createKeyboard() {
        self.view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        var BlurredKeyBG = UIImage(named: "BlurredKeyBG")
        var BlurredKeyBGView = UIImageView(image: BlurredKeyBG)
        BlurredKeyBGView.frame = view.frame
        BlurredKeyBGView.contentMode = UIViewContentMode.ScaleAspectFill
        BlurredKeyBGView.clipsToBounds = true
        
        self.view.addSubview(BlurredKeyBGView)
        
        nameSearch = UITextField(frame: CGRectMake(10.0, 10.0, self.view.frame.width - 122, 40.0))
        nameSearch.backgroundColor = UIColor.clearColor()
        nameSearch.borderStyle = UITextBorderStyle.None
        nameSearch.textColor = UIColor(white: 1.0, alpha: 1.0)
        nameSearch.layer.cornerRadius = 12
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var vibrancy = UIVibrancyEffect(forBlurEffect: blur)
        var blurView = UIVisualEffectView(effect: blur)
        blurView.frame = nameSearch.frame
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, 40))
        nameSearch.leftView = paddingView
        nameSearch.leftViewMode = UITextFieldViewMode.Always
        nameSearch.enabled = false
        clearSearch = UIButton(frame: CGRect(x: nameSearch.frame.width - 36, y: 12, width: 36, height: 36))
        clearSearch.setImage(UIImage(named: "Clear"), forState: UIControlState.Disabled)
        clearSearch.setImage(UIImage(named: "Clear"), forState: UIControlState.Normal)
        clearSearch.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        clearSearch.enabled = false
        clearSearch.addTarget(self, action: "clearNameSearch", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(blurView)
        self.view.addSubview(nameSearch)
        self.view.addSubview(clearSearch)
        
        altKeyboard.frame = CGRect(x: 0, y: 262, width: 50, height: 50)
        altKeyboard.setImage(UIImage(named: "keyAlt"), forState: UIControlState.Normal)
        altKeyboard.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        altKeyboard.addTarget(self, action: "useNormalKeyboard", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(altKeyboard)
    }
    
    func dismissKeyboard() {
        var dismissKeyboard = UIButton(frame: CGRect(x: nameSearch.frame.width + 75, y: 20, width: 30, height: 30))
        dismissKeyboard.setImage(UIImage(named: "KeyboardReverse"), forState: UIControlState.Normal)
        dismissKeyboard.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        dismissKeyboard.addTarget(self, action: "backToInitialView", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(dismissKeyboard)
    }
    
    func useNormalKeyboard() {
        self.view.hidden = true
        contactsSearchController.active = false
        self.view.window?.rootViewController!.presentViewController(normalSearchController, animated: true, completion: nil)
        normalSearchController.active = true
    }
    
    func deleteBtn() {
        deleteInput = UIButton(frame: CGRect(x: nameSearch.frame.width + 30, y: 18, width: 26, height: 26))
        deleteInput.setImage(UIImage(named: "Delete"), forState: UIControlState.Disabled)
        deleteInput.setImage(UIImage(named: "Delete"), forState: UIControlState.Normal)
        deleteInput.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        deleteInput.enabled = false
        deleteInput.addTarget(self, action: "deleteSearchInput:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(deleteInput)
    }
    
    func populateKeys() {
        for index in 0..<objectKeys.count {
            if (index < 3) {
                var keyButton1 = UIButton(frame: CGRect(x: self.view.frame.width - buttonXFirst, y: 75, width: 72, height: 52))
                buttonXFirst = buttonXFirst - 82
                
                keyButton1.layer.cornerRadius = keyButton1.frame.width / 6.0
                keyButton1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                keyButton1.backgroundColor = UIColor.clearColor()
                firstRowKeyStrings = "\(objectKeys[index])"
                keyButton1.setTitle(firstRowKeyStrings.capitalizedString, forState: UIControlState.Normal)
                keyButton1.setTitleColor(UIColor(white: 0.0, alpha: 1.0 ), forState: UIControlState.Highlighted)
                keyButton1.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                keyButton1.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                keyButton1.titleLabel!.numberOfLines = 2
                keyButton1.titleLabel!.text = firstRowKeyStrings.capitalizedString
                keyButton1.tag = index
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                var vibrancy = UIVibrancyEffect(forBlurEffect: blur)
                var blurView = UIVisualEffectView(effect: blur)
                blurView.frame = keyButton1.frame
                blurView.layer.cornerRadius = keyButton1.frame.width / 6.0
                blurView.clipsToBounds = true
                buttonsArray.append(keyButton1)
                buttonsBlurArray.append(blurView)
                
                keyButton1.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchDown);
                keyButton1.addTarget(self, action: "buttonNormal:", forControlEvents: UIControlEvents.TouchUpInside);
                
                self.view.addSubview(blurView)
                self.view.addSubview(keyButton1)
            }
            
            if (index < 6 && index >= 3) {
                var keyButton2 = UIButton(frame: CGRect(x: self.view.frame.width - buttonXSecond, y: 137, width: 72, height: 52))
                buttonXSecond = buttonXSecond - 82
                
                keyButton2.layer.cornerRadius = keyButton2.frame.width / 6.0
                keyButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                keyButton2.backgroundColor = UIColor.clearColor()
                secondRowKeyStrings = "\(objectKeys[index])"
                keyButton2.setTitle(secondRowKeyStrings.capitalizedString, forState: UIControlState.Normal)
                keyButton2.setTitleColor(UIColor(white: 0.0, alpha: 1.000 ), forState: UIControlState.Highlighted)
                keyButton2.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                keyButton2.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                keyButton2.titleLabel!.numberOfLines = 2
                keyButton2.titleLabel!.text = secondRowKeyStrings.capitalizedString
                keyButton2.tag = index
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                var vibrancy = UIVibrancyEffect(forBlurEffect: blur)
                var blurView = UIVisualEffectView(effect: blur)
                blurView.frame = keyButton2.frame
                blurView.layer.cornerRadius = keyButton2.frame.width / 6.0
                blurView.clipsToBounds = true
                buttonsArray.append(keyButton2)
                buttonsBlurArray.append(blurView)
                
                keyButton2.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchDown);
                keyButton2.addTarget(self, action: "buttonNormal:", forControlEvents: UIControlEvents.TouchUpInside);
                
                self.view.addSubview(blurView)
                self.view.addSubview(keyButton2)
            }
            
            if (index < 9 && index >= 6) {
                var keyButton3 = UIButton(frame: CGRect(x: self.view.frame.width - buttonXThird, y: 199, width: 72, height: 52))
                buttonXThird = buttonXThird - 82
                
                keyButton3.layer.cornerRadius = keyButton3.frame.width / 6.0
                keyButton3.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                keyButton3.backgroundColor = UIColor.clearColor()
                lastRowKeyStrings = "\(objectKeys[index])"
                keyButton3.setTitle(lastRowKeyStrings.capitalizedString, forState: UIControlState.Normal)
                keyButton3.setTitleColor(UIColor(white: 0.0, alpha: 1.000 ), forState: UIControlState.Highlighted)
                keyButton3.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5)
                keyButton3.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                keyButton3.titleLabel!.numberOfLines = 2
                keyButton3.titleLabel!.text = lastRowKeyStrings.capitalizedString
                keyButton3.tag = index
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                var vibrancy = UIVibrancyEffect(forBlurEffect: blur)
                var blurView = UIVisualEffectView(effect: blur)
                blurView.frame = keyButton3.frame
                blurView.layer.cornerRadius = keyButton3.frame.width / 6.0
                blurView.clipsToBounds = true
                buttonsArray.append(keyButton3)
                buttonsBlurArray.append(blurView)
                
                keyButton3.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchDown);
                keyButton3.addTarget(self, action: "buttonNormal:", forControlEvents: UIControlEvents.TouchUpInside);
                
                self.view.addSubview(blurView)
                self.view.addSubview(keyButton3)
            }
        }
    }
    
    func navKeys() {
        let backTitle = NSAttributedString(string: "Back", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 17.0)!])
        let moreTitle = NSAttributedString(string: "More", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 17.0)!])
        
        moreOptionsBack.frame = CGRect(x: self.view.frame.width - 250, y: 273, width: 50, height: 26)
        moreOptionsBack.setAttributedTitle(backTitle, forState: .Normal)
        moreOptionsBack.tag = 998
        moreOptionsBack.hidden = true
        moreOptionsBack.addTarget(self, action: "respondToMore:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(moreOptionsBack)
        
        moreOptionsForward.frame = CGRect(x: self.view.frame.width - 64, y: 273, width: 50, height: 26)
        moreOptionsForward.setAttributedTitle(moreTitle, forState: .Normal)
        moreOptionsForward.tag = 999
        moreOptionsForward.hidden = true
        moreOptionsForward.addTarget(self, action: "respondToMore:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(moreOptionsForward)
    }
    
    func keyPressed(sender: UIButton!) {
        sender.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        sender.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        lookupController?.selectOption(sender.tag)
        self.refreshData()
        keyPresses++
    }
    
    func clearNameSearch() {
        contactsSearchController.searchBar.text! = ""
        nameSearch.text! = ""
        keyPresses == 1
        lookupController?.restart()
        self.refreshData()
        clearSearch.enabled = false
        deleteInput.enabled = false
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("singleReset"), userInfo: nil, repeats: false)
    }
    
    func deleteSearchInput(sender: UIButton!) {
        keyPresses--
        if (keyPresses > 1) {
            lookupController?.back()
            self.refreshData()
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("combinedReset"), userInfo: nil, repeats: false)
        }
        else {
            lookupController?.restart()
            self.refreshData()
            clearSearch.enabled = false
            deleteInput.enabled = false
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("singleReset"), userInfo: nil, repeats: false)
        }
    }
    
    func respondToMore(sender: UIButton!) {
        if (sender.tag == 998) {
            lookupController?.back()
            self.refreshData()
            moreOptionsForward.hidden = false
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("respondToBackRefresh"), userInfo: nil, repeats: false)
        }
        if (sender.tag == 999) {
            moreKeyPresses++
            lookupController?.more()
            self.refreshData()
            moreOptionsBack.hidden = false
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("respondToForwardRefresh"), userInfo: nil, repeats: false)
        }
    }
    
    func respondToBackRefresh() {
        var baseKey : String = nameSearch.text.capitalizedString
        if (keyPresses == 1) {
            for index in 0..<objectKeys.count {
                var keyInput = objectKeys[index] as! String
                buttonsArray[index].setTitle("\(keyInput.capitalizedString)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(keyInput.capitalizedString)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
        }
        if (keyPresses > 1) {
            for index in 0..<objectKeys.count {
                var keyInput = objectKeys[index] as! String
                let combinedKeys = "\(baseKey)" + "\(keyInput)"
                buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
            if (objectKeys.count != self.buttonsArray.count) {
                for key in objectKeys.count..<self.buttonsArray.count {
                    buttonsArray[key].hidden = true
                    buttonsBlurArray[key].layer.hidden = true
                }
            }
        }
    }
    
    func respondToForwardRefresh() {
        var baseKey : String = nameSearch.text.capitalizedString
        if (keyPresses == 1) {
            for index in 0..<objectKeys.count {
                var keyInput = objectKeys[index] as! String
                buttonsArray[index].setTitle("\(keyInput.capitalizedString)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(keyInput.capitalizedString)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
            if (objectKeys.count != self.buttonsArray.count) {
                for key in objectKeys.count..<self.buttonsArray.count {
                    buttonsArray[key].hidden = true
                    buttonsBlurArray[key].layer.hidden = true
                }
            }
        }
        if (keyPresses > 1) {
            for index in 0..<objectKeys.count {
                var keyInput = objectKeys[index] as! String
                let combinedKeys = "\(baseKey)" + "\(keyInput)"
                buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
                buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
                buttonsArray[index].hidden = false
                buttonsBlurArray[index].layer.hidden = false
            }
            if (objectKeys.count != self.buttonsArray.count) {
                for key in objectKeys.count..<self.buttonsArray.count {
                    buttonsArray[key].hidden = true
                    buttonsBlurArray[key].layer.hidden = true
                }
            }
        }
    }
    
    func buttonNormal(sender: UIButton!) {
        sender.backgroundColor = UIColor.clearColor()
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        var baseKey = sender.titleLabel!.text!
        for index in 0..<objectKeys.count {
            var keyInput = objectKeys[index] as! String
            let combinedKeys = "\(baseKey)" + "\(keyInput)"
            buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
            buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
            buttonsArray[index].hidden = false
            buttonsBlurArray[index].layer.hidden = false
        }
        if (objectKeys.count != self.buttonsArray.count) {
            for key in objectKeys.count..<self.buttonsArray.count {
                buttonsArray[key].hidden = true
                buttonsBlurArray[key].layer.hidden = true
            }
        }
        clearSearch.enabled = true
        deleteInput.enabled = true
    }
    
    func combinedReset() {
        var base = nameSearch.text.capitalizedString
        for index in 0..<objectKeys.count {
            var keyInput = objectKeys[index] as! String
            let combinedKeys = "\(base)" + "\(keyInput)"
            buttonsArray[index].setTitle("\(combinedKeys)", forState: UIControlState.Normal)
            buttonsArray[index].titleLabel!.text = "\(combinedKeys)"
            buttonsArray[index].hidden = false
            buttonsBlurArray[index].layer.hidden = false
        }
        if (objectKeys.count != self.buttonsArray.count) {
            for key in objectKeys.count..<self.buttonsArray.count {
                buttonsArray[key].hidden = true
                buttonsBlurArray[key].layer.hidden = true
            }
        }
    }
    
    func singleReset() {
        for index in 0..<objectKeys.count {
            var keyInput = objectKeys[index] as! String
            buttonsArray[index].setTitle("\(keyInput.capitalizedString)", forState: UIControlState.Normal)
            buttonsArray[index].titleLabel!.text = "\(keyInput.capitalizedString)"
            buttonsArray[index].hidden = false
            buttonsBlurArray[index].layer.hidden = false
        }
    }
}
