//
//  SettingsViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/11/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import RealmSwift

var leftHanded: Bool! = false
var rightHanded: Bool! = true
var blurredImageView : UIButton! = UIButton()

class SettingsViewController: UIViewController, ENSideMenuDelegate {
    var parentNavigationController : UINavigationController?
    var realmNotification: NotificationToken?
    var generalSettings: UIButton = UIButton()
    var notificationSettings: UILabel = UILabel()
    var photoSettings: UILabel = UILabel()
    var contactSettings: UILabel = UILabel()
    var linkedSettings: UILabel = UILabel()
    var helpSettings: UILabel = UILabel()
    var privacySettings: UILabel = UILabel()
    var feedbackSettings: UILabel = UILabel()
    var termsSettings: UILabel = UILabel()
    let settingsColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0)
    let settingsTextAttr = UIFont(name: "HelveticaNeue-Thin", size: 17)!
    var effectImage : UIImage!
    var backgroundImage : UIImage!
    var settingsToggle: Int = 0
    var centerPoint: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentSearchNavigationController = self.navigationController
        self.sideMenuController()?.sideMenu?.delegate = self
        centerPoint = view.center
        print(centerPoint)
        let profileBGImageView = UIImageView(frame: self.view.frame)
        profileBGImageView.image = UIImage(named: "BitmapOverlayBG")
        profileBGImageView.alpha = 0.5
        profileBGImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(profileBGImageView)
        self.view.sendSubviewToBack(profileBGImageView)
        settingsViewSetup()
        
        let backBtn = UIButton(frame: CGRect(x: -20, y: 32, width: 112, height: 22))
        backBtn.setImage(UIImage(named: "Dismiss"), forState: UIControlState.Normal)
        backBtn.setImage(UIImage(named: "Dismiss"), forState: UIControlState.Highlighted)
        backBtn.addTarget(self, action: "goBack", forControlEvents:  UIControlEvents.TouchDown)
        
        self.view.addSubview(backBtn)
        
        let settingsTitle = UILabel(frame: CGRect(x: centerPoint.x - 36, y: 32, width: 75, height: 22))
        settingsTitle.textColor = .whiteColor()
        settingsTitle.font = UIFont(name: "AvenirNext-Regular", size: 18.0)!
        settingsTitle.text = "Settings"
        
        self.view.addSubview(settingsTitle)
    }
    
    func settingsViewSetup() {
        let settingsView = UIView(frame: CGRect(x: 5, y: 76, width: self.view.frame.width - 10, height: 176))
        settingsView.backgroundColor = UIColor(white: 0.85, alpha: 0.85)
        settingsView.layer.cornerRadius = 0
        let shadowPath = UIBezierPath(roundedRect: settingsView.bounds, cornerRadius: 0)
        settingsView.layer.masksToBounds = false
        settingsView.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0).CGColor
        settingsView.layer.shadowOffset = CGSize(width: 0, height: 3);
        settingsView.layer.shadowOpacity = 0.5
        settingsView.layer.shadowPath = shadowPath.CGPath
        
        let generalItem = UIView(frame: CGRect(x: 10, y: 0, width: settingsView.frame.width - 10, height: 44))
        generalItem.layer.addBorder(.Bottom, color: settingsColor, thickness: 1.0)
        generalSettings.frame = CGRect(x: 35, y: 0, width: generalItem.frame.width, height: generalItem.frame.height)
        generalSettings.backgroundColor = UIColor.clearColor()
        generalSettings.titleLabel?.font = settingsTextAttr
        generalSettings.setTitleColor(settingsColor, forState: .Normal)
        generalSettings.contentHorizontalAlignment = .Left
        generalSettings.setTitle("General", forState: .Normal)
        generalSettings.addTarget(self, action: "toggleSideMenu:", forControlEvents: .TouchUpInside)
        generalItem.addSubview(generalSettings)
        settingsView.addSubview(generalItem)
        
        let notificationsItem = UIView(frame: CGRect(x: 10, y: 44, width: settingsView.frame.width - 10, height: 44))
        notificationsItem.layer.addBorder(.Bottom, color: settingsColor, thickness: 1.0)
        notificationSettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        notificationSettings.text = "Notifications"
        notificationSettings.font = settingsTextAttr
        notificationSettings.textColor = settingsColor
        notificationsItem.addSubview(notificationSettings)
        settingsView.addSubview(notificationsItem)
        
        let photosItem = UIView(frame: CGRect(x: 10, y: 88, width: settingsView.frame.width - 10, height: 44))
        photosItem.layer.addBorder(.Bottom, color: settingsColor, thickness: 1.0)
        photoSettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        photoSettings.text = "Photos"
        photoSettings.font = settingsTextAttr
        photoSettings.textColor = settingsColor
        photosItem.addSubview(photoSettings)
        settingsView.addSubview(photosItem)
        
        let contactsItem = UIView(frame: CGRect(x: 10, y: 132, width: settingsView.frame.width - 10, height: 44))
        contactSettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        contactSettings.text = "Contacts"
        contactSettings.font = settingsTextAttr
        contactSettings.textColor = settingsColor
        contactsItem.addSubview(contactSettings)
        settingsView.addSubview(contactsItem)
        
        let settingsViewMiddle = UIView(frame: CGRect(x: 5, y: 262, width: self.view.frame.width - 10, height: 132))
        settingsViewMiddle.backgroundColor = UIColor(white: 0.85, alpha: 0.85)
        settingsViewMiddle.layer.cornerRadius = 0
        let shadowPathMiddle = UIBezierPath(roundedRect: settingsViewMiddle.bounds, cornerRadius: 0)
        settingsViewMiddle.layer.masksToBounds = false
        settingsViewMiddle.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0).CGColor
        settingsViewMiddle.layer.shadowOffset = CGSize(width: 0, height: 3);
        settingsViewMiddle.layer.shadowOpacity = 0.5
        settingsViewMiddle.layer.shadowPath = shadowPathMiddle.CGPath
        
        let linkedItem = UIView(frame: CGRect(x: 10, y: 0, width: settingsViewMiddle.frame.width - 10, height: 44))
        linkedItem.layer.addBorder(.Bottom, color: settingsColor, thickness: 1.0)
        linkedSettings.frame = CGRect(x: 35, y: 10, width: 130, height: 24)
        linkedSettings.text = "Linked Accounts"
        linkedSettings.font = settingsTextAttr
        linkedSettings.textColor = settingsColor
        linkedItem.addSubview(linkedSettings)
        settingsViewMiddle.addSubview(linkedItem)
        
        let helpItem = UIView(frame: CGRect(x: 10, y: 44, width: settingsViewMiddle.frame.width - 10, height: 44))
        helpItem.layer.addBorder(.Bottom, color: settingsColor, thickness: 1.0)
        helpSettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        helpSettings.text = "Help"
        helpSettings.font = settingsTextAttr
        helpSettings.textColor = settingsColor
        helpItem.addSubview(helpSettings)
        settingsViewMiddle.addSubview(helpItem)
        
        let privacyItem = UIView(frame: CGRect(x: 10, y: 88, width: settingsViewMiddle.frame.width - 10, height: 44))
        privacySettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        privacySettings.text = "Privacy"
        privacySettings.font = settingsTextAttr
        privacySettings.textColor = settingsColor
        privacyItem.addSubview(privacySettings)
        settingsViewMiddle.addSubview(privacyItem)
        
        let settingsViewBottom = UIView(frame: CGRect(x: 5, y: 404, width: self.view.frame.width - 10, height: 88))
        settingsViewBottom.backgroundColor = UIColor(white: 0.85, alpha: 0.85)
        settingsViewBottom.layer.cornerRadius = 0
        let shadowPathBottom = UIBezierPath(roundedRect: settingsViewBottom.bounds, cornerRadius: 0)
        settingsViewBottom.layer.masksToBounds = false
        settingsViewBottom.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0).CGColor
        settingsViewBottom.layer.shadowOffset = CGSize(width: 0, height: 3);
        settingsViewBottom.layer.shadowOpacity = 0.5
        settingsViewBottom.layer.shadowPath = shadowPathBottom.CGPath
        
        let feedbackItem = UIView(frame: CGRect(x: 10, y: 0, width: settingsViewBottom.frame.width - 10, height: 44))
        feedbackItem.layer.addBorder(.Bottom, color: settingsColor, thickness: 1.0)
        feedbackSettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        feedbackSettings.text = "Feedback"
        feedbackSettings.font = settingsTextAttr
        feedbackSettings.textColor = settingsColor
        feedbackItem.addSubview(feedbackSettings)
        settingsViewBottom.addSubview(feedbackItem)
        
        let termsItem = UIView(frame: CGRect(x: 10, y: 44, width: settingsViewBottom.frame.width - 10, height: 44))
        termsSettings.frame = CGRect(x: 35, y: 10, width: 100, height: 24)
        termsSettings.text = "Terms of Use"
        termsSettings.font = settingsTextAttr
        termsSettings.textColor = settingsColor
        termsItem.addSubview(termsSettings)
        settingsViewBottom.addSubview(termsItem)
        
        self.view.addSubview(settingsView)
        self.view.addSubview(settingsViewMiddle)
        self.view.addSubview(settingsViewBottom)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func toggleSideMenu(sender: AnyObject) {
        let rems = settingsToggle % 2
        if rems == 0 {
            backgroundImage = self.view.snapshot(self.view)
            blurredImageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            effectImage = backgroundImage.applyDarkEffect()
            blurredImageView.setBackgroundImage(effectImage, forState: .Normal)
            blurredImageView.setBackgroundImage(effectImage, forState: .Highlighted)
            blurredImageView.addTarget(self, action: "toggleSideMenu:", forControlEvents: .TouchUpInside)
            blurredImageView.showsTouchWhenHighlighted = false
            self.view.addSubview(blurredImageView)
            self.view.bringSubviewToFront(blurredImageView)
            UIApplication.sharedApplication().statusBarHidden = true
        } else {
            blurredImageView.removeFromSuperview()
            UIApplication.sharedApplication().statusBarHidden = false
        }
        toggleSideMenuView()
        settingsToggle++
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        blurredImageView.removeFromSuperview()
        UIApplication.sharedApplication().statusBarHidden = false
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

class MySettingsController: ENSideMenuNavigationController, ENSideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MySettingsTableViewController(), menuPosition:.Right)
        //sideMenu?.delegate = self //optional
        sideMenu?.menuWidth = 200.0 // optional, default is 160
        sideMenu?.allowLeftSwipe = false
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
}

class MySettingsTableViewController: UITableViewController {
    var selectedKeyboardItem : NSIndexPath!
    var selectedSortItem : NSIndexPath!
    var selectedLandingItem : NSIndexPath!
    var selectedShortNameItem : NSIndexPath!
    var sectionFixedHeader = UIView()
    var sectionFixedHeaderLabel = UILabel()
    
    var keyboardSelections = ["Left-handed", "Right-handed"]
    var sortSelections = ["Last, First", "First, Last"]
    var landingSelections = ["Recents", "List", "Grid", "Favorites"]
    var shortNameSelections = ["First Name & Last Initial", "First & Last Initial", "First Initial & Last Name"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
        tableView.contentOffset = CGPoint(x: 0, y: -64.0)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollEnabled = false
        
        sectionFixedHeader.frame = CGRect(x: 0, y: -64, width: 200, height: 64)
        sectionFixedHeader.backgroundColor = UIColor(red: 33/255, green: 193/255, blue: 223/255, alpha: 1.0)
        sectionFixedHeaderLabel.frame = CGRect(x: 0, y: 0, width: sectionFixedHeader.frame.width, height: sectionFixedHeader.frame.height)
        sectionFixedHeaderLabel.textColor = .whiteColor()
        sectionFixedHeaderLabel.textAlignment = .Center
        sectionFixedHeaderLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)!
        sectionFixedHeaderLabel.text = "General Settings"
        sectionFixedHeader.addSubview(sectionFixedHeaderLabel)
        
        tableView.addSubview(sectionFixedHeader)
        
        //tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch (section) {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 4
        case 3:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 0.8)
        header.textLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 17)!
        header.textLabel!.textColor = UIColor.whiteColor()
    }
    
    override func tableView( tableView : UITableView, titleForHeaderInSection section: Int) -> String {
        switch (section) {
        case 0:
            return "Keyboard"
        case 1:
            return "Sort Order"
        case 2:
            return "Default Landing"
        case 3:
            return "Short Name"
        default:
            return "Settings"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("CE LL", forIndexPath: indexPath) 
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 44))
        selectedBackgroundView.backgroundColor = UIColor.clearColor()
        let selectedImage = UIImage(named: "SettingsCheck")
        let selectedImageView = UIImageView(frame: CGRect(x: 170, y: 12, width: 20, height: 20))
        selectedImageView.image = selectedImage
        selectedImageView.contentMode = .ScaleAspectFill
        selectedBackgroundView.addSubview(selectedImageView)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.selectedBackgroundView = selectedBackgroundView
        
        switch (indexPath.section) {
        case 0:
            cell.textLabel!.text = keyboardSelections[indexPath.row]
            if indexPath.row == 1 {
                selectedKeyboardItem = indexPath
                cell.addSubview(selectedBackgroundView)
            }
        case 1:
            cell.textLabel!.text = sortSelections[indexPath.row]
            if indexPath.row == 1 {
                selectedSortItem = indexPath
                cell.addSubview(selectedBackgroundView)
            }
        case 2:
            cell.textLabel!.text = landingSelections[indexPath.row]
            if indexPath.row == 0 {
                selectedLandingItem = indexPath
                cell.addSubview(selectedBackgroundView)
            }
        case 3:
            cell.textLabel!.text = shortNameSelections[indexPath.row]
            if indexPath.row == 1 {
                selectedShortNameItem = indexPath
                cell.addSubview(selectedBackgroundView)
            }
        default:
            cell.textLabel!.text = "None"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedBackgroundView = UIView(frame: CGRectMake(170, 12, 20, 20))
        selectedBackgroundView.contentMode = .ScaleAspectFill
        let selectedImage = UIImage(named: "SettingsCheck")
        let selectedImageView = UIImageView(image: selectedImage)
        selectedBackgroundView.addSubview(selectedImageView)
        let newSelection = tableView.cellForRowAtIndexPath(indexPath)
        let oldKeySelection = tableView.cellForRowAtIndexPath(selectedKeyboardItem)
        
        switch (indexPath.section) {
        case 0:
            if indexPath != selectedKeyboardItem {
                oldKeySelection?.subviews.last?.removeFromSuperview()
                newSelection?.addSubview(selectedBackgroundView)
                selectedKeyboardItem = indexPath
                if indexPath.row == 0 {
                    leftHanded = true
                    rightHanded = false
                } else {
                    leftHanded = false
                    rightHanded = true
                }
            }
        case 1:
            if indexPath != selectedSortItem {
                newSelection?.addSubview(selectedBackgroundView)
            }
        case 2:
            if indexPath != selectedLandingItem {
                newSelection?.addSubview(selectedBackgroundView)
            }
        case 3:
            if indexPath != selectedShortNameItem {
                newSelection?.addSubview(selectedBackgroundView)
            }
        default:
            print("None")
        }
    }
}

