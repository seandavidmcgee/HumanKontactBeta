//
//  GridViewControllerExtensions.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension GridViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Return the number of sections.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Int(People.people.count)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var hkPerson = People.people[Int(indexPath.row)] as HKPerson
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCollectionViewCell", forIndexPath: indexPath) as! FriendCollectionViewCell
        
        if hkPerson.avatar.length != 0 {
            cell.backgroundImageView.image = UIImage(data: hkPerson.avatar)
        } else {
            cell.backgroundImageView.image = avatarImage(indexPath.row)
            cell.initialsLabel!.text = hkPerson.initials
        }
        var firstName = hkPerson.firstName
        var lastName = hkPerson.lastName
        cell.firstNameTitleLabel!.text = firstName ?? ""
        if (cell.firstNameTitleLabel!.text == "") {
            cell.firstNameTitleLabel!.text = lastName
            cell.lastNameTitleLabel!.hidden = true
        }
        cell.lastNameTitleLabel!.text = lastName ?? ""
        return cell
    }
}

extension GridViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if contactsSearchController.active {
            controller.view.hidden = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var hkPerson = People.people[Int(indexPath.row)] as HKPerson
        pickedPerson = hkPerson
        
        let size = CGSizeMake(50, 50)
        let hasAlpha = false
        let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
        
        var profilePhone: String! = ""
        var profileEmail: String! = ""
        var avatarNeeded: Bool! = false
        
        //Create an instance of SwiftPromptsView and assign its delegate
        prompt = SwiftPromptsView(frame: self.view.bounds)
        prompt.delegate = self
        
        //Set the properties for the background
        prompt.setColorWithTransparency(UIColor.clearColor())
        
        //Reset profile action properties
        prompt.homeCallButton.hidden = true
        prompt.homeCallButton.setTitle("", forState: UIControlState.Normal)
        prompt.workCallButton.hidden = true
        prompt.workCallButton.setTitle("", forState: UIControlState.Normal)
        prompt.mobileCallButton.hidden = true
        prompt.mobileCallButton.setTitle("", forState: UIControlState.Normal)
        prompt.messageButton.hidden = true
        prompt.messageButton.setTitle("", forState: UIControlState.Normal)
        prompt.iPhoneCallButton.hidden = true
        prompt.iPhoneCallButton.setTitle("", forState: UIControlState.Normal)
        prompt.iPhoneMessageButton.hidden = true
        prompt.iPhoneMessageButton.setTitle("", forState: UIControlState.Normal)
        prompt.emailButton.hidden = true
        prompt.emailButton.setTitle("", forState: UIControlState.Normal)
        prompt.secondEmailButton.hidden = true
        prompt.secondEmailButton.setTitle("", forState: UIControlState.Normal)
        prompt.workCallButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.mobileCallButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.messageButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.iPhoneCallButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.iPhoneMessageButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.emailButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.secondEmailButton.transform = CGAffineTransformMakeTranslation(0, 0)
        
        recentPeople.append(hkPerson)
        self.backgroundAddRecent()
        
        if contactsSearchController.active == true
        {
            controller.view.hidden = true
            var imageBG: UIImage!
            var image: UIImage!
            
            if hkPerson.avatar.length != 0 {
                imageBG = UIImage(data: hkPerson.avatar)
                image = imageBG
                pickedInitials = ""
            } else {
                avatarNeeded = true
                imageBG = UIImage(named: "placeBG")
                image = UIImage(data: hkPerson.avatarColor)
                pickedInitials = hkPerson.initials
            }
            var name = hkPerson.fullName
            pickedName = name
            pickedBG = imageBG
            pickedImage = image
            
            // Phone Numbers
            if let hkPhone = hkPerson.phoneNumbers.first as HKPhoneNumber! {
                if hkPerson.phoneNumbers.count > 0 {
                    for phone in hkPerson.phoneNumbers {
                        var phones = phone as HKPhoneNumber!
                        var phoneStrings: String = phone.formattedNumber
                        var profilePhoneNumber = self.profilePhone(phoneStrings)
                        if let profileLabel = profilePhoneLabel(phoneStrings) as String! {
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                            promptPhonesArray.append(localPhone)
                        } else {
                            var profileLabel = "phone"
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                            promptPhonesArray.append(localPhone)
                        }
                    }
                }
            }
            
            // Emails
            
            if let hkEmail = hkPerson.emails.first as HKEmail! {
                if hkPerson.emails.count > 0 {
                    for email in hkPerson.emails {
                        var currentEmail = email as HKEmail!
                        var profileEmailString: String = self.profileEmail(currentEmail.email)
                        var localEmail = ["email": profileEmailString]
                        emailsProfileArray.append(localEmail)
                        promptEmailsArray.append(localEmail)
                    }
                }
            }
            
            var company = hkPerson.company
            pickedCompany = company
            
            var jobTitle = hkPerson.jobTitle
            pickedTitle = jobTitle
        }
            
        else
        {
            var imageBG: UIImage!
            var image: UIImage!
            
            if hkPerson.avatar.length != 0 {
                imageBG = UIImage(data: hkPerson.avatar)
                image = imageBG
                pickedInitials = ""
            } else {
                avatarNeeded = true
                imageBG = UIImage(named: "placeBG")
                image = UIImage(data: hkPerson.avatarColor)
                pickedInitials = hkPerson.initials
            }
            var name = hkPerson.fullName
            pickedName = name
            pickedBG = imageBG
            pickedImage = image
            
            // Phone Numbers
            if let hkPhone = hkPerson.phoneNumbers.first as HKPhoneNumber! {
                if hkPerson.phoneNumbers.count > 0 {
                    for phone in hkPerson.phoneNumbers {
                        var phones = phone as HKPhoneNumber!
                        var phoneStrings: String = phone.formattedNumber
                        var profilePhoneNumber = self.profilePhone(phoneStrings)
                        if let profileLabel = profilePhoneLabel(phoneStrings) as String! {
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                            promptPhonesArray.append(localPhone)
                        } else {
                            var profileLabel = "phone"
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                            promptPhonesArray.append(localPhone)
                        }
                    }
                }
            }
            
            // Emails
            
            if let hkEmail = hkPerson.emails.first as HKEmail! {
                if hkPerson.emails.count > 0 {
                    for email in hkPerson.emails {
                        var currentEmail = email as HKEmail!
                        var profileEmailString: String = self.profileEmail(currentEmail.email)
                        var localEmail = ["email": profileEmailString]
                        emailsProfileArray.append(localEmail)
                        promptEmailsArray.append(localEmail)
                    }
                }
            }
            
            var company = hkPerson.company
            pickedCompany = company
            
            var jobTitle = hkPerson.jobTitle
            pickedTitle = jobTitle
        }
        
        var secondaryTranslate: CGFloat = 60 * CGFloat(promptPhonesArray.count + 1)
        
        for phone in promptPhonesArray {
            // Grab each key, value pair from the person dictionary
            if let valI = phone["iPhone"] {
                prompt.iPhoneIncluded = true
                profilePhone = "iPhone : \(valI)"
                prompt.enableiPhoneButtonOnPrompt()
                prompt.iPhoneCallButton.setTitle("\(valI)", forState: UIControlState.Normal)
                prompt.iPhoneCallButton.hidden = false
                prompt.iPhoneMessageButton.setTitle("\(valI)", forState: UIControlState.Normal)
                prompt.iPhoneMessageButton.transform = CGAffineTransformMakeTranslation(60, 0)
                prompt.iPhoneMessageButton.hidden = false
                prompt.emailButton.transform = CGAffineTransformMakeTranslation(120, 0)
            }
            if let valM = phone["mobile"] {
                prompt.mobileIncluded = true
                profilePhone = "mobile : \(valM)"
                prompt.enableMobileButtonOnPrompt()
                prompt.mobileCallButton.setTitle("\(valM)", forState: UIControlState.Normal)
                prompt.mobileCallButton.hidden = false
                prompt.messageButton.setTitle("\(valM)", forState: UIControlState.Normal)
                prompt.messageButton.transform = CGAffineTransformMakeTranslation(60, 0)
                prompt.messageButton.hidden = false
                prompt.emailButton.transform = CGAffineTransformMakeTranslation(120, 0)
                if prompt.iPhoneIncluded {
                    let valI = phone["iPhone"]
                    profilePhone = "iPhone : \(valI)"
                    prompt.mobileCallButton.setTitle("\(valM)", forState: UIControlState.Normal)
                    prompt.mobileCallButton.transform = CGAffineTransformMakeTranslation(120, 0)
                    prompt.mobileCallButton.hidden = false
                    prompt.messageButton.setTitle("\(valM)", forState: UIControlState.Normal)
                    prompt.messageButton.transform = CGAffineTransformMakeTranslation(180, 0)
                    prompt.messageButton.hidden = false
                    prompt.emailButton.transform = CGAffineTransformMakeTranslation(240, 0)
                }
            }
        }
        
        prompt.emailIncluded = true
        for email in promptEmailsArray {
            // Grab each key, value pair from the person dictionary
            for (key,value) in email {
                if (emailsProfileArray.count == 1) {
                    prompt.enableEmailButtonOnPrompt()
                    profileEmail = "\(value)"
                    prompt.emailButton.setTitle("\(value)", forState: UIControlState.Normal)
                    prompt.emailButton.hidden = false
                } else if (emailsProfileArray.count > 1) {
                    prompt.enableEmailButtonOnPrompt()
                    prompt.emailButton.setTitle("\(value)", forState: UIControlState.Normal)
                    prompt.emailButton.hidden = false
                    prompt.enableSecondEmailButtonOnPrompt()
                    prompt.secondEmailButton.setTitle("\(email)", forState: UIControlState.Normal)
                    prompt.secondEmailButton.hidden = false
                }
            }
        }
        if (profilePhone.isEmpty) {
            profilePhone = profileEmail
        }
        if prompt.mobileIncluded || prompt.iPhoneIncluded {
            prompt.secondEmailButton.transform = CGAffineTransformMakeTranslation(secondaryTranslate + 60, 0)
        } else {
            prompt.secondEmailButton.transform = CGAffineTransformMakeTranslation(secondaryTranslate, 0)
        }
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        pickedImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Set the properties of the promt
        prompt.setPromtHeader(pickedName!)
        prompt.setPromptHeaderTxtSize(18.0)
        prompt.setPromptContentTxtSize(16.0)
        prompt.setPromptContentTextFont("AvenirNext-Regular")
        prompt.setPromptContentTextRectY(26.0)
        prompt.setPromptContentTxtColor(UIColor.whiteColor())
        prompt.setPromptContentText(profilePhone)
        prompt.setPromptDismissIconColor(UIColor(patternImage: scaledImage))
        prompt.setPromptDismissIconVisibility(true)
        prompt.setPromptTopBarVisibility(true)
        prompt.setPromptBottomBarVisibility(false)
        prompt.setPromptTopLineVisibility(false)
        prompt.setPromptBottomLineVisibility(true)
        prompt.setPromptWidth(self.view.bounds.width * 0.75)
        prompt.setPromptHeight(self.view.bounds.width * 0.55)
        prompt.setPromptBackgroundColor(UIColor(red: 94.0/255.0, green: 100.0/255.0, blue: 112.0/255.0, alpha: 0.85))
        prompt.setPromptHeaderBarColor(UIColor(red: 50.0/255.0, green: 58.0/255.0, blue: 71.0/255.0, alpha: 0.8))
        prompt.setPromptHeaderTxtColor(UIColor.whiteColor())
        prompt.setPromptBottomLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.setPromptButtonDividerColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.enableDoubleButtonsOnPrompt()
        prompt.setMainButtonText("View Profile")
        prompt.setMainButtonColor(UIColor.whiteColor())
        prompt.setSecondButtonColor(UIColor.whiteColor())
        prompt.setSecondButtonText("Cancel")
        
        if (avatarNeeded == true) {
            prompt.setPromptInitialsVisibility(true)
            prompt.setPromptInitialsText(pickedInitials!)
        } else {
            prompt.setPromptInitialsVisibility(false)
            prompt.setPromptInitialsText("")
        }
        
        self.view.addSubview(prompt)
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func clickedOnTheMainButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        vc.person = pickedPerson
        vc.image = pickedImage
        vc.imageBG = pickedBG
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.jobTitleLabel = pickedTitle
        vc.initials = pickedInitials
        
        dispatch_async(dispatch_get_main_queue()) {
            self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
            self.prompt.dismissPrompt()
            promptPhonesArray.removeAll(keepCapacity: false)
            promptEmailsArray.removeAll(keepCapacity: false)
        }
    }
    
    func clickedOnTheSecondButton() {
        println("Clicked on the second button")
        prompt.dismissPrompt()
        phonesProfileArray.removeAll(keepCapacity: false)
        emailsProfileArray.removeAll(keepCapacity: false)
        promptPhonesArray.removeAll(keepCapacity: false)
        promptEmailsArray.removeAll(keepCapacity: false)
    }
    
    func promptWasDismissed() {
        println("Dismissed the prompt")
    }
}

extension GridViewController: UISearchResultsUpdating
{
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        var keyEntry = searchController.searchBar.text!
        var searchString: String! = ""
        if let spaceIndex = keyEntry.indexOfCharacter(" ") {
            let index: String.Index = advance(keyEntry.startIndex, spaceIndex)
            let lastName: String = keyEntry.substringToIndex(index)
            let firstName: String = keyEntry.substringFromIndex(spaceIndex + 1)
            if count(firstName) > 0 && count(lastName) > 0 {
                searchString = firstName + " " + lastName
            } else if count(firstName) == 0 && count(lastName) > 0 {
                searchString = lastName
            } else if count(lastName) == 0 && count(firstName) > 0 {
                searchString = firstName
            }
        }
        
        var queriedSearch: Results<HKPerson>
        if searchString == "" {
            queriedSearch = realm.objects(HKPerson).filter("firstName BEGINSWITH[c] '\(keyEntry)' OR lastName BEGINSWITH[c] '\(keyEntry)'")
        } else {
            queriedSearch = realm.objects(HKPerson).filter("fullName CONTAINS[c] '\(keyEntry)' OR fullName CONTAINS[c] '\(searchString)' OR firstName CONTAINS[c] '\(searchString)' OR lastName CONTAINS[c] '\(searchString)'")
        }
        People.people = queriedSearch
        self.collectionView!.reloadData()
    }
}