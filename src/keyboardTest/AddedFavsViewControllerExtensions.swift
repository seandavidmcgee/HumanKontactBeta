//
//  AddedFavsViewControllerExtensions.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/12/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension AddedFavsViewController: UITableViewDataSource
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(FavPeople.favorites.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var hkPerson = hkFavSorted[Int(indexPath.row)] as HKPerson
        
        let cellIdentifier:String = "FriendTableViewCell"
        var cell: FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FriendTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
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
                    var phones = phone as HKPhoneNumber!
                    var phoneStrings: String = phone.formattedNumber
                    var profilePhoneNumber = profilePhone(phoneStrings)
                    cell.phoneCell(phoneStrings)
                    if let profileLabel = profilePhoneLabel(phoneStrings) as String! {
                        var localPhone = [profileLabel: profilePhoneNumber]
                        favsPhonesArray.append(localPhone)
                    } else {
                        var profileLabel = "phone"
                        var localPhone = [profileLabel: profilePhoneNumber]
                        favsPhonesArray.append(localPhone)
                    }
                }
            } else {
                let phoneString: String = hkPhone.formattedNumber
                var profilePhoneNumber = profilePhone(phoneString)
                cell.phoneCell(phoneString)
                if let profileLabel = profilePhoneLabel(phoneString) as String! {
                    var localPhone = [profileLabel: profilePhoneNumber]
                    favsPhonesArray.append(localPhone)
                } else {
                    var profileLabel = "phone"
                    var localPhone = [profileLabel: profilePhoneNumber]
                    favsPhonesArray.append(localPhone)
                }
            }
        } else {
            cell.phoneCell("")
        }
        
        // Emails
        
        if let hkEmail = hkPerson.emails.first as HKEmail! {
            if hkPerson.emails.count > 1 {
                for email in hkPerson.emails {
                    var currentEmail = email as HKEmail!
                    var profileEmailString: String = profileEmail(currentEmail.email)
                    var localEmail = ["email": profileEmailString]
                    favsEmailsArray.append(localEmail)
                    cell.emailCell(profileEmailString, emailCount: hkPerson.emails.count)
                }
            } else {
                let emailString: String = hkEmail.email
                cell.emailCell(emailString, emailCount: hkPerson.emails.count)
            }
        } else {
            cell.emailCell("", emailCount: hkPerson.emails.count)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74.0
    }
}

extension AddedFavsViewController: UITableViewDelegate
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var hkPerson = hkFavSorted[Int(indexPath.row)] as HKPerson
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        recentPeople.append(hkPerson)
        self.backgroundAddRecent()
        
        if contactsSearchController.active == true
        {
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
                        var profilePhoneNumber = profilePhone(phoneStrings)
                        if let profileLabel = profilePhoneLabel(phoneStrings) as String! {
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                        } else {
                            var profileLabel = "phone"
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                        }
                    }
                }
            }
            
            // Emails
            
            if let hkEmail = hkPerson.emails.first as HKEmail! {
                if hkPerson.emails.count > 0 {
                    for email in hkPerson.emails {
                        var currentEmail = email as HKEmail!
                        var profileEmailString: String = profileEmail(currentEmail.email)
                        var localEmail = ["email": profileEmailString]
                        emailsProfileArray.append(localEmail)
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
                imageBG = UIImage(named: "placeBG")
                image = avatarImage(indexPath.row)
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
                        var profilePhoneNumber = profilePhone(phoneStrings)
                        if let profileLabel = profilePhoneLabel(phoneStrings) as String! {
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                        } else {
                            var profileLabel = "phone"
                            var localPhone = [profileLabel: profilePhoneNumber]
                            phonesProfileArray.append(localPhone)
                        }
                    }
                }
            }
            
            // Emails
            
            if let hkEmail = hkPerson.emails.first as HKEmail! {
                if hkPerson.emails.count > 0 {
                    for email in hkPerson.emails {
                        var currentEmail = email as HKEmail!
                        var profileEmailString: String = profileEmail(currentEmail.email)
                        var localEmail = ["email": profileEmailString]
                        emailsProfileArray.append(localEmail)
                    }
                }
            }
            
            var company = hkPerson.company
            pickedCompany = company
            
            var jobTitle = hkPerson.jobTitle
            pickedTitle = jobTitle
        }
        vc.person = hkPerson
        vc.image = pickedImage
        vc.imageBG = pickedBG
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.jobTitleLabel = pickedTitle
        vc.initials = pickedInitials
        
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        dispatch_async(dispatch_get_main_queue()) {
            if normalSearchController.active {
                self.view.window!.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
            }
            self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

extension AddedFavsViewController: UISearchResultsUpdating
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
            queriedSearch = favRealm.objects(HKPerson).filter("firstName BEGINSWITH '\(keyEntry)' OR lastName BEGINSWITH '\(keyEntry)'")
        } else {
            queriedSearch = favRealm.objects(HKPerson).filter("fullName CONTAINS '\(keyEntry)' OR fullName CONTAINS '\(searchString)'")
        }
        FavPeople.favorites = queriedSearch
        self.tableView.reloadData()
    }
}
