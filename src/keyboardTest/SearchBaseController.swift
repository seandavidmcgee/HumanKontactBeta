/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A table view controller that displays filtered strings (used by other view controllers for simple displaying and filtering of data).
*/

import UIKit
import AddressBook
import AddressBookUI

class SearchTableViewController: UITableViewController, ABPersonViewControllerDelegate {
    // MARK: Types
    
    var filtered = Array<Dictionary<String,AnyObject>>()
    var myBook = Array<Dictionary<String,AnyObject>>()
    let ap = APAddressBook()
    var addressBook:ABAddressBookRef?
    var parentNavigationController : UINavigationController?
    var pickedImage : UIImage!
    var pickedName : String?
    var pickedCompany : String?
    var pickedMobile : String?
    var pickedHome : String?
    var pickedEmail : String?
    var pickedTitle : String?
    
    // MARK: Properties
    var filterString: String? = nil {
        didSet {
            println(self.filterString!)
            if (filterString!.isEmpty) {
                return
            }
            else if (!self.filterString!.isEmpty) {
                filtered = myBook.filter({ (text) -> Bool in
                        var tmp1: NSDictionary = text
                        println(text)
                        var tmp2: NSDictionary = tmp1.dictionaryWithValuesForKeys(["fullName"])
                        var tmp: NSString = tmp2.descriptionInStringsFileFormat
                        var range = tmp.rangeOfString(self.filterString!, options: NSStringCompareOptions.CaseInsensitiveSearch)
                        return range.location != NSNotFound
                })
                myBook = filtered
            }
            tableView.reloadData()
        }
    }
    
    func getSysContacts() -> [[String:AnyObject]] {
        var error:Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
        
        if sysAddressBookStatus == .Denied || sysAddressBookStatus == .NotDetermined {
            // Need to ask for authorization
            var authorizedSingal:dispatch_semaphore_t = dispatch_semaphore_create(0)
            var askAuthorization:ABAddressBookRequestAccessCompletionHandler = { success, error in
                if success {
                    ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as NSArray
                    dispatch_semaphore_signal(authorizedSingal)
                }
            }
            ABAddressBookRequestAccessWithCompletion(addressBook, askAuthorization)
            dispatch_semaphore_wait(authorizedSingal, DISPATCH_TIME_FOREVER)
        }
        
        func analyzeSysContacts(sysContacts:NSArray) -> [[String:AnyObject]] {
            var allContacts:Array = [[String:AnyObject]]()
            
            func analyzeContactProperty(contact:ABRecordRef, property:ABPropertyID) -> [AnyObject]? {
                var propertyValues:ABMultiValueRef? = ABRecordCopyValue(contact, property)?.takeRetainedValue()
                if propertyValues != nil {
                    var values:Array<AnyObject> = Array()
                    for i in 0 ..< ABMultiValueGetCount(propertyValues) {
                        var value = ABMultiValueCopyValueAtIndex(propertyValues, i)
                        switch property {
                            
                        case kABPersonAddressProperty :
                            var valueDictionary:Dictionary = [String:String]()
                            
                            var addrNSDict:NSMutableDictionary = (value.takeRetainedValue() as? NSMutableDictionary)!
                            valueDictionary["_Country"] = addrNSDict.valueForKey(kABPersonAddressCountryKey as! String) as? String ?? ""
                            valueDictionary["_State"] = addrNSDict.valueForKey(kABPersonAddressStateKey as! String) as? String ?? ""
                            valueDictionary["_City"] = addrNSDict.valueForKey(kABPersonAddressCityKey as! String) as? String ?? ""
                            valueDictionary["_Street"] = addrNSDict.valueForKey(kABPersonAddressStreetKey as! String) as? String ?? ""
                            valueDictionary["_Countrycode"] = addrNSDict.valueForKey(kABPersonAddressCountryCodeKey as! String) as? String ?? ""
                            
                            
                            var fullAddress:String = (valueDictionary["_Country"]! == "" ? valueDictionary["_Countrycode"]! : valueDictionary["_Country"]!) + ", " + valueDictionary["_State"]! + ", " + valueDictionary["_City"]! + ", " + valueDictionary["_Street"]!
                            values.append(fullAddress)
                            
                        case kABPersonSocialProfileProperty :
                            var valueDictionary:Dictionary = [String:String]()
                            
                            var snsNSDict:NSMutableDictionary = (value.takeRetainedValue() as? NSMutableDictionary)!
                            valueDictionary["_Username"] = snsNSDict.valueForKey(kABPersonSocialProfileUsernameKey as! String) as? String ?? ""
                            valueDictionary["_URL"] = snsNSDict.valueForKey(kABPersonSocialProfileURLKey as! String) as? String ?? ""
                            valueDictionary["_Serves"] = snsNSDict.valueForKey(kABPersonSocialProfileServiceKey as! String) as? String ?? ""
                            
                            values.append(valueDictionary)
                            
                        case kABPersonInstantMessageProperty :
                            var valueDictionary:Dictionary = [String:String]()
                            
                            var imNSDict:NSMutableDictionary = (value.takeRetainedValue() as? NSMutableDictionary)!
                            valueDictionary["_Serves"] = imNSDict.valueForKey(kABPersonInstantMessageServiceKey as! String) as? String ?? ""
                            valueDictionary["_Username"] = imNSDict.valueForKey(kABPersonInstantMessageUsernameKey as! String) as? String ?? ""
                            
                            values.append(valueDictionary)
                            
                        case kABPersonDateProperty :
                            var date:String? = (value.takeRetainedValue() as? NSDate)?.description
                            if date != nil {
                                values.append(date!)
                            }
                        default :
                            var val:String = value.takeRetainedValue() as? String ?? ""
                            values.append(val)
                        }
                    }
                    return values
                }else{
                    return nil
                }
            }
            
            for contact in sysContacts {
                var currentContact:Dictionary = [String:AnyObject]()
                
                currentContact["abrecord"] = contact
                
                var FirstName:String = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as? String ?? ""
                currentContact["FirstName"] = FirstName
                currentContact["FirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as? String ?? ""
                
                var LastName:String = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as? String ?? ""
                currentContact["LastName"] = LastName
                currentContact["LastNamePhonetic"] = ABRecordCopyValue(contact, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as? String ?? ""
                
                currentContact["Nickname"] = ABRecordCopyValue(contact, kABPersonNicknameProperty)?.takeRetainedValue() as? String ?? ""
                
                currentContact["fullName"] = FirstName + " " + LastName
                
                currentContact["Organization"] = ABRecordCopyValue(contact, kABPersonOrganizationProperty)?.takeRetainedValue() as? String ?? ""
                
                currentContact["JobTitle"] = ABRecordCopyValue(contact, kABPersonJobTitleProperty)?.takeRetainedValue() as? String ?? ""
                
                currentContact["Department"] = ABRecordCopyValue(contact, kABPersonDepartmentProperty)?.takeRetainedValue() as? String ?? ""
                
                currentContact["Note"] = ABRecordCopyValue(contact, kABPersonNoteProperty)?.takeRetainedValue() as? String ?? ""
                
                var Phone:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonPhoneProperty)
                if Phone != nil {
                    currentContact["Phone"] = Phone
                }
                
                var Address:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonAddressProperty)
                if Address != nil {
                    currentContact["Address"] = Address
                }
                
                var Email:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonEmailProperty)
                if Email != nil {
                    currentContact["Email"] = Email
                }
                
                var Date:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonDateProperty)
                if Date != nil {
                    currentContact["Date"] = Date
                }
                
                var URL:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonURLProperty)
                if URL != nil{
                    currentContact["URL"] = URL
                }
                
                var SNS:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonSocialProfileProperty)
                if SNS != nil {
                    currentContact["SNS"] = SNS
                }
                
                if ABPersonHasImageData(contact){
                    let fullData = ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatOriginalSize).takeRetainedValue() as NSData
                    let data = ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail).takeRetainedValue() as NSData
                    currentContact["FullImage"] = UIImage(data: fullData)
                    currentContact["Thumbnail"] = UIImage(data: data)
                } else {
                    currentContact["FullImage"] = UIImage(named: "placeholder")
                    currentContact["Thumbnail"] = UIImage(named: "placeholder")
                }
                allContacts.append(currentContact)
            }
            allContacts = sorted(allContacts,mcp)
            return allContacts
        }
        return analyzeSysContacts( ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray )
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.registerNib(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendTableViewCell")
        self.tableView.registerNib(UINib(nibName: "ProfileMenuCell", bundle: nil), forCellReuseIdentifier: "ProfileMenuCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func mcp(dict1: Dictionary<String,AnyObject>, dict2:Dictionary<String,AnyObject>) -> Bool{
        let firstname1 = dict1["FirstName"] as! String
        let firstname2 = dict2["FirstName"] as! String
        let lastname1 = dict1["LastName"] as! String
        let lastname2 = dict2["LastName"] as! String
        if firstname1 == firstname2 {
            return lastname1 < lastname2
        } else {
            return firstname1 < firstname2
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.showsVerticalScrollIndicator = false
        super.viewDidAppear(animated)
        refresh()
        self.tableView.showsVerticalScrollIndicator = true
    }
    
    func refresh(){
        myBook = getSysContacts()
        var error:Unmanaged<CFError>?
        //test()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myBook.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell") as! FriendTableViewCell
        let quickActions : ProfileMenuCell = tableView.dequeueReusableCellWithIdentifier("ProfileMenuCell") as! ProfileMenuCell
        cell.photoImageView!.image = myBook[indexPath.row]["Thumbnail"] as? UIImage
        let firstName = myBook[indexPath.row]["FirstName"] as? String
        let lastName = myBook[indexPath.row]["LastName"] as? String
        cell.sourceLabel!.text = "Added from iPhone"
        cell.nameLabel!.text = (firstName ?? "") + " " + (lastName ?? "")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 47.0
    }
    
    func test(){
        self.ap.loadContacts(
            { (contacts: [AnyObject]!, error: NSError!) in
                if contacts != nil{
                    for contact in contacts {
                        let c = contact as! APContact
                        println(c.firstName)
                    }
                }
                else if error != nil {
                    // show error
                }
        })
    }
    
    func personViewController(personViewController: ABPersonViewController!, shouldPerformDefaultActionForPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let record: ABRecordRef! = myBook[indexPath.row]["abrecord"] as ABRecordRef!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController

        var name: String? = myBook[indexPath.row]["fullName"] as! String?
        pickedName = name
        
        var image: UIImage! = myBook[indexPath.row]["FullImage"] as! UIImage!
        pickedImage = image
        
        var company: String? = myBook[indexPath.row]["Organization"] as! String?
        pickedCompany = company
        
        let unmanagedPhones = ABRecordCopyValue(record, kABPersonPhoneProperty)
        let phones: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
        let countOfPhones = ABMultiValueGetCount(phones)
        
        for index in 0..<countOfPhones {
            let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, index)
            let phone: String = Unmanaged.fromOpaque(unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
            
            if (index == 0) {
                pickedHome = "Home: " + phone
            }
            if (index == 1) {
                pickedMobile = "Mobile: " + phone
            }
        }
        
        let unmanagedEmails = ABRecordCopyValue(record, kABPersonEmailProperty)
        let emails: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedEmails.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
        let countOfEmails = ABMultiValueGetCount(emails)
        
        for index in 0..<countOfEmails {
            let unmanagedEmail = ABMultiValueCopyValueAtIndex(emails, index)
            let email: String = Unmanaged.fromOpaque(unmanagedEmail.toOpaque()).takeUnretainedValue() as NSObject as! String
            if (index == 0) {
                pickedEmail = "Work Email: " + email
            }
        }
        
        var jobTitle: String? = myBook[indexPath.row]["JobTitle"] as! String?
        pickedTitle = "Job Title: " + jobTitle!
        
        vc.image = pickedImage
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.mobileLabel = pickedMobile
        vc.homeLabel = pickedHome
        vc.emailLabel = pickedEmail
        vc.jobTitleLabel = pickedTitle
        
        parentSearchNavigationController?.pushViewController(vc, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}
