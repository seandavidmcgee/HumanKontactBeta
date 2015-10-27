//
//  PrimaryViewController.swift
//  EMPartialModalViewController
//
//  Created by Emad A. on 16/02/2015.
//  Copyright (c) 2015 Emad A. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import AddressBookUI
import RealmSwift

class PrimaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UINavigationControllerDelegate {
    var realmNotification: NotificationToken?
    var masterTableView: UITableView = UITableView()
    var masterCollectionView: UICollectionView?
    let layoutSwitch = DGRunkeeperSwitch()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if realmNotification == nil {
            realmNotification = realm.addNotificationBlock({ [weak self](notificationString, realm) -> Void in
                self?.masterTableView.reloadData()
            })
        }
        navigationController?.delegate = self
        self.view.backgroundColor = UIColor(hex: 0x00000d)
        masterTableView.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: 354)
        masterTableView.delegate = self
        masterTableView.dataSource = self
        masterTableView.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "FriendTableViewCell")
        view.addSubview(masterTableView)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 58, height: 102)
        masterCollectionView = UICollectionView(frame: masterTableView.frame, collectionViewLayout: layout)
        masterCollectionView!.dataSource = self
        masterCollectionView!.delegate = self
        masterCollectionView!.backgroundColor = UIColor.clearColor()
        masterCollectionView!.registerClass(FriendCollectionViewCell.self, forCellWithReuseIdentifier: "FriendCollectionViewCell")
        masterCollectionView!.hidden = true
        view.addSubview(masterCollectionView!)
        view.sendSubviewToBack(masterCollectionView!)
        
        layoutSwitch.leftTitle = "Grid"
        layoutSwitch.rightTitle = "List"
        layoutSwitch.setSelectedIndex(1, animated: true)
        layoutSwitch.backgroundColor = UIColor(red: 251.0/255.0, green: 33.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        layoutSwitch.selectedBackgroundColor = .whiteColor()
        layoutSwitch.titleColor = .whiteColor()
        layoutSwitch.selectedTitleColor = UIColor(red: 251.0/255.0, green: 33.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        layoutSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 13.0)
        layoutSwitch.frame = CGRect(x: 30.0, y: 40.0, width: 100.0, height: 30.0)
        layoutSwitch.addTarget(self, action: Selector("layoutSwitchValueDidChange:"), forControlEvents: .ValueChanged)
        let rightItem = UIBarButtonItem(customView: layoutSwitch)
        navigationItem.rightBarButtonItem = rightItem
        let dismissBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        dismissBtn.setImage(UIImage(named: "Dismiss"), forState: UIControlState.Normal)
        dismissBtn.setImage(UIImage(named: "Dismiss"), forState: UIControlState.Highlighted)
        dismissBtn.tintColor = .whiteColor()
        dismissBtn.addTarget(self, action: Selector("dismiss"), forControlEvents:  UIControlEvents.TouchUpInside)
        let leftItem = UIBarButtonItem(customView: dismissBtn)
        navigationItem.leftBarButtonItem = leftItem
    }
    
    deinit {
        realm.removeNotification(realmNotification!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        masterTableView.showsVerticalScrollIndicator = true
        masterTableView.delaysContentTouches = false
        masterTableView.backgroundColor = UIColor.clearColor()
        masterTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        masterCollectionView!.showsVerticalScrollIndicator = true
        masterCollectionView!.delaysContentTouches = false
        masterCollectionView!.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        self.masterTableView.reloadData()
        self.masterCollectionView!.reloadData()
    }
    
    func dismiss() {
        parentViewController?.dismissViewControllerAnimated(true) {
            print("dismissing view controller - done")
        }
    }
    
    func layoutSwitchValueDidChange(sender:DGRunkeeperSwitch) {
        print(sender.selectedIndex)
        if sender.selectedIndex == 0 {
            if isViewLoaded() {
                let center: CGPoint = {
                    let itemFrame = self.navigationController?.navigationBar.frame
                    let itemCenter = CGPoint(x: itemFrame!.midX, y: itemFrame!.midY)
                    var convertedCenter = self.masterTableView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                    convertedCenter.y = 0
                    
                    return convertedCenter
                    }()
                
                let transition = CircularRevealTransition(layer: masterTableView.layer, center: center)
                transition.start()
                
                masterTableView.hidden = true
                view.insertSubview(masterCollectionView!, aboveSubview: masterTableView)
                masterCollectionView!.reloadData()
                masterCollectionView!.hidden = false
            }
        } else if sender.selectedIndex == 1 {
            if isViewLoaded() {
                let center: CGPoint = {
                    let itemFrame = self.navigationController?.navigationBar.frame
                    let itemCenter = CGPoint(x: itemFrame!.midX, y: itemFrame!.midY)
                    var convertedCenter = self.masterCollectionView!.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                    convertedCenter.y = 0
                    
                    return convertedCenter
                    }()
                
                let transition = CircularRevealTransition(layer: masterCollectionView!.layer, center: center)
                transition.start()
                
                masterCollectionView!.hidden = true
                view.insertSubview(masterTableView, aboveSubview: masterCollectionView!)
                view.sendSubviewToBack(masterCollectionView!)
                masterTableView.reloadData()
                masterTableView.hidden = false
            }
        } else {
            print("no selection")
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(FavPeople.favorites.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let hkPerson = FavPeople.favorites[Int(indexPath.row)] as HKPerson
        
        let cellIdentifier:String = "FriendTableViewCell"
        let cell: FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FriendTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.photoImageView!.layer.borderColor = UIColor(hexString: hkPerson.nameColor).CGColor
        cell.backgroundColorView.backgroundColor = UIColor(hexString: hkPerson.nameColor)
        
        if hkPerson.avatar.length != 0 {
            cell.photoImageView!.image = UIImage(data: hkPerson.avatar)
        } else {
            cell.photoImageView!.image = UIImage(data: hkPerson.avatarColor)
            cell.initialsLabel!.text = hkPerson.initials
        }
        cell.person = hkPerson
        cell.nameLabel!.text = hkPerson.fullName
        
        // Phone Numbers
        if let hkPhone = hkPerson.phoneNumbers.first as HKPhoneNumber! {
            if hkPerson.phoneNumbers.count > 1 {
                for phone in hkPerson.phoneNumbers {
                    let profilePhoneNumber = phone.formattedNumber
                    if let profileLabel = phone.label as String! {
                        let localPhone = [profileLabel: profilePhoneNumber]
                        cell.phoneCell(profilePhoneNumber, label: profileLabel)
                        phonesArray.append(localPhone)
                    } else {
                        let profileLabel = "Phone"
                        let localPhone = [profileLabel: profilePhoneNumber]
                        phonesArray.append(localPhone)
                    }
                }
            } else {
                let profilePhoneNumber = hkPhone.formattedNumber
                if let profileLabel = hkPhone.label as String! {
                    let localPhone = [profileLabel: profilePhoneNumber]
                    cell.phoneCell(profilePhoneNumber, label: profileLabel)
                    phonesArray.append(localPhone)
                } else {
                    let profileLabel = "Phone"
                    let localPhone = [profileLabel: profilePhoneNumber]
                    phonesArray.append(localPhone)
                }
            }
        } else {
            cell.phoneCell("", label: "")
        }
        
        // Emails
        
        if hkPerson.emails.first != nil {
            cell.emailCell(hkPerson, emailCount: hkPerson.emails.count)
        } else {
            cell.emailCell(hkPerson, emailCount: 0)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hkPerson = FavPeople.favorites[Int(indexPath.row)] as HKPerson
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        backgroundAddRecent(hkPerson)
        
        var imageBG: UIImage!
        var image: UIImage!
        
        if hkPerson.avatar.length != 0 {
            imageBG = UIImage(data: hkPerson.avatar)
            image = imageBG
            pickedInitials = ""
        } else {
            imageBG = UIImage(named: "placeBG")
            image = UIImage(data: hkPerson.avatarColor)
            pickedInitials = hkPerson.initials
        }
        let name = hkPerson.fullName
        pickedName = name
        pickedBG = imageBG
        pickedImage = image
        
        // Phone Numbers
        if hkPerson.phoneNumbers.first != nil {
            if hkPerson.phoneNumbers.count > 0 {
                for phone in hkPerson.phoneNumbers {
                    let profilePhoneNumber = phone.formattedNumber
                    if let profileLabel = phone.label as String! {
                        let localPhone = [profileLabel: profilePhoneNumber]
                        phonesProfileArray.append(localPhone)
                    } else {
                        let profileLabel = "phone"
                        let localPhone = [profileLabel: profilePhoneNumber]
                        phonesProfileArray.append(localPhone)
                    }
                }
            }
        }
        
        // Emails
        
        if hkPerson.emails.first != nil {
            if hkPerson.emails.count > 0 {
                for email in hkPerson.emails {
                    let currentEmail = email as HKEmail!
                    let profileEmailString: String = profileEmail(currentEmail.email)
                    let localEmail = ["email": profileEmailString]
                    emailsProfileArray.append(localEmail)
                }
            }
        }
        let company = hkPerson.company
        pickedCompany = company
        
        let jobTitle = hkPerson.jobTitle
        pickedTitle = jobTitle
        
        let personUUID = hkPerson.uuid
        pickedPerson = personUUID
        
        vc.selectedPerson = pickedPerson
        vc.image = pickedImage
        vc.imageBG = pickedBG
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.jobTitleLabel = pickedTitle
        vc.initials = pickedInitials
        
        self.dismiss()
        
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        autoreleasepool {
            dispatch_async(dispatch_get_main_queue()) {
                self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Return the number of sections.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Int(FavPeople.favorites.count)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let hkPerson = FavPeople.favorites[Int(indexPath.row)] as HKPerson
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCollectionViewCell", forIndexPath: indexPath) as! FriendCollectionViewCell
        
        cell.backgroundImageView.layer.borderColor = UIColor(hexString: hkPerson.nameColor).CGColor
        cell.backgroundColorView.backgroundColor = UIColor(hexString: hkPerson.nameColor)
        
        if hkPerson.avatar.length != 0 {
            cell.backgroundImageView.image = UIImage(data: hkPerson.avatar)
        } else {
            cell.backgroundImageView.image = UIImage(data: hkPerson.avatarColor)
            cell.initialsLabel!.text = hkPerson.initials
        }
        let firstName = hkPerson.firstName
        let lastName = hkPerson.lastName
        cell.firstNameTitleLabel!.text = firstName ?? ""
        if (cell.firstNameTitleLabel!.text == "") {
            cell.firstNameTitleLabel!.text = lastName
            cell.lastNameTitleLabel!.hidden = true
        }
        cell.lastNameTitleLabel!.text = lastName ?? ""
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let hkPerson = FavPeople.favorites[Int(indexPath.row)] as HKPerson
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        backgroundAddRecent(hkPerson)
        
        var imageBG: UIImage!
        var image: UIImage!
        
        if hkPerson.avatar.length != 0 {
            imageBG = UIImage(data: hkPerson.avatar)
            image = imageBG
            pickedInitials = ""
        } else {
            imageBG = UIImage(named: "placeBG")
            image = UIImage(data: hkPerson.avatarColor)
            pickedInitials = hkPerson.initials
        }
        let name = hkPerson.fullName
        pickedName = name
        pickedBG = imageBG
        pickedImage = image
        
        // Phone Numbers
        if hkPerson.phoneNumbers.first != nil {
            if hkPerson.phoneNumbers.count > 0 {
                for phone in hkPerson.phoneNumbers {
                    let profilePhoneNumber = phone.formattedNumber
                    if let profileLabel = phone.label as String! {
                        let localPhone = [profileLabel: profilePhoneNumber]
                        phonesProfileArray.append(localPhone)
                    } else {
                        let profileLabel = "phone"
                        let localPhone = [profileLabel: profilePhoneNumber]
                        phonesProfileArray.append(localPhone)
                    }
                }
            }
        }
        
        // Emails
        
        if hkPerson.emails.first != nil {
            if hkPerson.emails.count > 0 {
                for email in hkPerson.emails {
                    let currentEmail = email as HKEmail!
                    let profileEmailString: String = profileEmail(currentEmail.email)
                    let localEmail = ["email": profileEmailString]
                    emailsProfileArray.append(localEmail)
                }
            }
        }
        let company = hkPerson.company
        pickedCompany = company
        
        let jobTitle = hkPerson.jobTitle
        pickedTitle = jobTitle
        
        let personUUID = hkPerson.uuid
        pickedPerson = personUUID
        
        vc.selectedPerson = pickedPerson
        vc.image = pickedImage
        vc.imageBG = pickedBG
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.jobTitleLabel = pickedTitle
        vc.initials = pickedInitials
        
        self.dismiss()
        
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        autoreleasepool {
            dispatch_async(dispatch_get_main_queue()) {
                self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
            }
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}
