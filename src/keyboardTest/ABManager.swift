//
//  ABManager.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import RealmSwift
import Dollar

typealias NameAndScoreTuple = (name:String, filterName:String)

class ABManager : NSObject, NilLiteralConvertible {
    var ab = RHAddressBook()
    var indexedPeopleModified = Array<Dictionary<String, AnyObject>>()
    var indexedRHPeopleSort = [RHPerson]()
    var indexedPeopleSort = Array<Dictionary<String, AnyObject>>()
    var fuzzyPeopleMatching = [String]()
    var indexesOfPeople = [Int]()
    var lookupWatchController : KannuuIndexController? = nil
    var myResults = [AnyObject]()
    let manager = ABManager.abRealm()
    var fuzzyResultsMatch = [NameAndScoreTuple]()
    var exactResultsMatch = [String]()
    var uniqueResults = [String]()
    
    required init(nilLiteral: ()) {
        super.init()
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "addressBookDidChange:",
            name: RHAddressBookExternalChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    class func abRealm() -> Realm {
        // Switch return statements for in-memory vs. persisted Realms
        //return Realm(inMemoryIdentifier: "OSTABManagerRealm")
        
        func fileInDocumentsDirectory(filename: String) -> String {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = documentsURL.URLByAppendingPathComponent(filename)
            return fileURL.path!
        }
        
        let realmPath: String = fileInDocumentsDirectory("default.realm")
        Realm.Configuration.defaultConfiguration.path = realmPath
        return try! Realm(path: Realm.Configuration.defaultConfiguration.path!)
    }
    
    func addressBookDidChange(notification: NSNotification) {
        print("address book changed via notification: \(notification)")
        createIndex(true)
    }
    
    func hasPermission() -> Bool {
        if RHAddressBook.authorizationStatus() == RHAuthorizationStatus.Authorized {
            return RHAddressBook.authorizationStatus() == RHAuthorizationStatus.Authorized
        }
        return RHAddressBook.authorizationStatus() == RHAuthorizationStatus.Denied
    }
    
    func sortedModifiedRecords(modified: Bool) {
        if self.indexedPeopleSort.count != 0 {
            self.indexedPeopleSort.removeAll(keepCapacity: false)
        }
        print("sort fired")
        let dataItems = self.ab.peopleOrderedByUsersPreference as [AnyObject]! as! [RHPerson]
        let index = self.myResults as [AnyObject]! as! [String]
        var name: String! = nil
        _ = Dictionary<String,AnyObject>()
            for contact in dataItems {
                if (contact.firstName == nil && contact.lastName == nil) {
                    if (contact.organization != nil) {
                        name = contact.organization!
                    } else if (contact.phoneNumbers != nil) {
                        name = contact.phoneNumbers.valueAtIndex(0)! as! String
                    } else {
                        print("no name or company or numbers")
                        continue
                    }
                } else if (contact.firstName == nil) {
                    name = contact.lastName!
                }
                else if (contact.lastName == nil) {
                    name = contact.firstName!
                }
                else {
                    name = contact.firstName! + " " + contact.lastName!
                }
                var contactIndex = $.indexOf(index, value: name!)
                if contactIndex == nil {
                    contactIndex = dataItems.count
                }
                
                let person = ["index": Int(contactIndex!), "person": contact] as Dictionary<String,AnyObject>
                self.indexedPeopleSort.append(person)
            }
            
            indexedPeopleSort.sortInPlace {
                item1, item2 in
                let index1 = item1["index"] as! Int
                let index2 = item2["index"] as! Int
                return index1 <= index2
            }
            print("sort completed")
            if modified == false {
                self.beginFetch()
            } else {
                self.rlmQuery()
            }
    }
    
    func fuzzyAdding(name: String, contact: RHPerson, index: Int) {
        //for people in fuzzyResultsMatch {
            //var matchFirst = people.0
            //var matchSecond = people.1
            //if name == matchFirst {
                //var match = self.ab.peopleWithName(matchSecond) as [AnyObject]! as! [RHPerson]
                //var person = ["index": Int(index), "person": contact, "match": match]
                //self.indexedPeopleSort.append(person)
            //} else if name == matchSecond {
                //continue
            //} else {
                //if uniqueResults.indexOf(name) != nil {
                    //continue
                //}
            //}
        //}
    }
    
    func duplicateAdding(name: String, dupIndex: Int) {
        for (_,people) in uniqueResults.enumerate() {
            if name == people {
                var match = self.ab.peopleWithName(name) as [AnyObject]! as! [RHPerson]
                let matchFirst = match[0]
                let person = ["index": Int(dupIndex), "person": matchFirst, "match": match]
                self.indexedPeopleSort.append(person)
            }
        }
    }
    
    func modifiedRecords(success:(()->())?, failure:((message: String)->())?) {
        if hasPermission() {
            autoreleasepool {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let backgroundRealm = ABManager.abRealm()
                let people = self.indexedPeopleModified
                backgroundRealm.write({ () -> Void in
                    for person in people {
                        var rhContact = [RHPerson]()
                        let rhPerson = person["person"] as! RHPerson
                        rhContact.append(rhPerson)
                        let contactIndex = person["index"] as! Int
                        let hkPerson = person["record"] as! HKPerson
                        self.modifyRecord(realm: backgroundRealm, rhPerson: rhContact, basePerson: hkPerson, indexOrder: contactIndex)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        print("modified success")
                        success?()
                    })
                })
            })
            }
        } else {
            failure?(message: "To utilize HumanKontact you must provide permission for the app to access your contacts under Settings > Privacy > Contacts.")
        }
    }
    
    func indexRecords(success:(()->())?, failure:((message: String)->())?) {
        if hasPermission() {
            autoreleasepool {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let backgroundRealm = ABManager.abRealm()
                    let people = self.indexedPeopleSort
                    backgroundRealm.write({ () -> Void in
                        for person in people {
                            //var rhContact = [RHPerson]()
                            let rhPerson = person["person"] as! RHPerson
                            let contactIndex = person["index"] as! Int
                            self.writeRecord(realm: backgroundRealm, rhPerson: rhPerson, indexOrder: contactIndex)
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            print("success")
                            success?()
                        })
                    })
                })
            }
        } else {
            failure?(message: "To utilize HumanKontact you must provide permission for the app to access your contacts under Settings > Privacy > Contacts.")
        }
    }
    
    private func writeRecord(realm realm: Realm, rhPerson: RHPerson, indexOrder: Int) {
        let rlmPhoneNumbers = List<HKPhoneNumber>()
        let rlmEmails = List<HKEmail>()
        
        if rhPerson.phoneNumbers.count > 0 {
            var index = 0
            let rhPhoneNumbers = rhPerson.phoneNumbers?.values as [AnyObject]?
            for rhNumber in rhPhoneNumbers! {
                let formattedNumString = rhNumber as! String
                let normalizedString = ABPhoneUtility.normalizedPhoneStringFromString(formattedNumString) as String
                let phoneNumber = HKPhoneNumber()
                let rhIndex: UInt = UInt(index)
                if let label = rhPerson.phoneNumbers?.localizedLabelAtIndex(rhIndex) {
                    phoneNumber.formattedNumber = label + ":" + normalizedString
                } else {
                    phoneNumber.formattedNumber = "phone:" + normalizedString
                }
                rlmPhoneNumbers.append(phoneNumber)
                index++
            }
        }
        if rhPerson.emails.count > 0 {
            let rhEmails = rhPerson.emails?.values as [AnyObject]?
            for rhEmail in rhEmails! {
                let emailString = rhEmail as! String
                let email = HKEmail()
                email.email = emailString
                rlmEmails.append(email)
            }
        }
        
        //var mainContact = rhPerson[0]
        let hkPerson = HKPerson()
        hkPerson.fullName = rhPerson.name ?? rhPerson.firstName ?? rhPerson.lastName ?? rhPerson.organization ?? rhPerson.phoneNumbers?.valueAtIndex(0) as? String! ?? ""
        hkPerson.firstName = rhPerson.firstName ?? rhPerson.organization ?? rhPerson.phoneNumbers?.valueAtIndex(0) as? String! ?? ""
        hkPerson.lastName = rhPerson.lastName ?? ""
        hkPerson.initials = profileInitials(hkPerson.firstName, lastName: hkPerson.lastName)
        hkPerson.jobTitle = rhPerson.jobTitle ?? ""
        hkPerson.company = rhPerson.organization ?? ""
        hkPerson.phoneNumbers = rlmPhoneNumbers
        hkPerson.emails = rlmEmails
        hkPerson.created = NSDate(timeIntervalSinceNow: 0)
        hkPerson.avatarColor = avatarImage(indexOrder)
        hkPerson.nameColor = nameColor(indexOrder)
        hkPerson.record = "\(rhPerson.recordID)"
        hkPerson.indexedOrder = indexOrder
        hkPerson.modified = rhPerson.modified ?? NSDate(timeIntervalSinceNow: 0)
        if rhPerson.hasImage {
            let data = rhPerson.thumbnailData ?? rhPerson.originalImageData
            hkPerson.avatar = data!
        }
        
        //if rhPerson.count > 1 {
            //var matchedContact = rhPerson[1]
            //hkPerson.linkedName = matchedContact.name ?? matchedContact.firstName ?? matchedContact.lastName ?? matchedContact.phoneNumbers.valueAtIndex(0) as? String ?? ""
            //hkPerson.linkedRecord = "\(matchedContact.recordID)"
            //hkPerson.linkedModified = matchedContact.modified
            //if matchedContact.hasImage {
                //var data: NSData = matchedContact.thumbnailData
                //hkPerson.linkedAvatar = data
            //}
        //}
        realm.add(hkPerson, update: true)
    }
    
    private func modifyRecord(realm realm: Realm, rhPerson: [RHPerson], basePerson: HKPerson, indexOrder: Int) {
        let rlmPhoneNumbers = List<HKPhoneNumber>()
        let rlmEmails = List<HKEmail>()
        var hkPhoneNumbers = [String]()
        var hkEmails = [String]()
        
        for person in rhPerson {
            if person.phoneNumbers.count > 0 {
                var index = 0
                let rhPhoneNumbers = person.phoneNumbers.values as [AnyObject]?
                for rhNumber in rhPhoneNumbers! {
                    let formattedNumString = rhNumber as! String
                    let normalizedString = ABPhoneUtility.normalizedPhoneStringFromString(formattedNumString) as String
                    var phoneNumber = String()
                    let rhIndex: UInt = UInt(index)
                    if let label = person.phoneNumbers?.localizedLabelAtIndex(rhIndex) {
                        phoneNumber = label + ":" + normalizedString
                    } else {
                        phoneNumber = "phone:" + normalizedString
                    }
                    hkPhoneNumbers.append(phoneNumber)
                    index++
                }
            }
            if person.emails.count > 0 {
                let rhEmails = person.emails.values as [AnyObject]! as! [String]?
                for rhEmail in rhEmails! {
                    let emailString = rhEmail as String
                    hkEmails.append(emailString)
                }
            }
        }
        
        let uniquePhoneNumbers = uniq(hkPhoneNumbers)
        for number in uniquePhoneNumbers {
            let phoneNumber = HKPhoneNumber()
            phoneNumber.formattedNumber = number
            rlmPhoneNumbers.append(phoneNumber)
        }
        
        let uniqueEmails = uniq(hkEmails)
        for emails in uniqueEmails {
            let email = HKEmail()
            email.email = emails
            rlmEmails.append(email)
        }
        let mainContact = rhPerson[0]
        basePerson.fullName = mainContact.name ?? mainContact.firstName ?? mainContact.lastName ?? mainContact.organization ?? mainContact.phoneNumbers?.valueAtIndex(0) as? String! ?? ""
        basePerson.firstName = mainContact.firstName ?? ""
        basePerson.lastName = mainContact.lastName ?? ""
        basePerson.initials = profileInitials(basePerson.firstName, lastName: basePerson.lastName)
        basePerson.jobTitle = mainContact.jobTitle ?? ""
        basePerson.company = mainContact.organization ?? ""
        basePerson.phoneNumbers = rlmPhoneNumbers
        basePerson.emails = rlmEmails
        basePerson.modified = mainContact.modified ?? NSDate(timeIntervalSinceNow: 0)
        
        if basePerson.indexedOrder != indexOrder {
            basePerson.indexedOrder = indexOrder
        }
        if mainContact.hasImage {
            let data = mainContact.thumbnailData ?? mainContact.originalImageData
            basePerson.avatar = data!
        }
    }
    
    func profileInitials(firstName: String, lastName: String) -> String {
        var first: String = ""
        var last: String = ""
        if (firstName.characters.count != 0 && lastName.characters.count != 0) {
            let firstIndex = firstName.startIndex.advancedBy(1)
            let lastIndex = lastName.startIndex.advancedBy(1)
            
            let firstChar = firstName.substringToIndex(firstIndex)
            first = ("\(firstChar)").capitalizedString
            let lastChar = lastName.substringToIndex(lastIndex)
            last = ("\(lastChar)").capitalizedString
        } else if (firstName.characters.count != 0 && lastName.characters.count == 0) {
            let index = firstName.startIndex.advancedBy(2)
            let firstChar = firstName.substringToIndex(index)
            first = ("\(firstChar)").capitalizedString
            last = ""
        } else if (firstName.characters.count == 0 && lastName.characters.count != 0) {
            let index = lastName.startIndex.advancedBy(2)
            let firstChar = lastName.substringToIndex(index)
            first = ("\(firstChar)").capitalizedString
            last = ""
        } else {
            first = ""
            last = ""
        }
        return first + last
    }
    
    func beginFetch() {
        self.indexRecords({ () -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("fetched")
                
            })
            }, failure: { (message: String) -> () in
                let failAlert = UIAlertController.init(title: "Permission Required", message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
                }
                failAlert.addAction(alertAction)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    GlobalVariables.sharedManager.appDelegate.window!.rootViewController!.presentViewController(failAlert, animated: false) { completion -> Void in }
                })
        })
    }
    
    func beginModify() {
        if (self.indexedPeopleModified.count > 0) {
            GlobalVariables.sharedManager.recordsModified = self.indexedPeopleModified.count
            print(self.indexedPeopleModified.count)
        self.modifiedRecords({ () -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("fetched")
            })
            }, failure: { (message: String) -> () in
                let failAlert = UIAlertController.init(title: "Permission Required", message: message, preferredStyle: .Alert)
                let alertAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { action -> Void in
                }
                failAlert.addAction(alertAction)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    GlobalVariables.sharedManager.appDelegate.window!.rootViewController!.presentViewController(failAlert, animated: false) { completion -> Void in }
                })
        })
        }
    }
    
    func rlmQuery() {
        if self.indexedPeopleModified.count != 0 {
            self.indexedPeopleModified.removeAll(keepCapacity: false)
        }
        print("query fired")
        let people = self.indexedPeopleSort
        autoreleasepool {
            dispatch_async(dispatch_get_main_queue()) {
                for person in people {
                    let rhContact = person["person"] as! RHPerson
                    let contactIndex = person["index"] as! Int
                    let predicate = NSPredicate(format: "record = %@", "\(rhContact.recordID)")
                    let base = self.manager.objects(HKPerson).filter(predicate)
                    for basePerson in base {
                        if (basePerson.modified != rhContact.modified)  {
                            print("\(rhContact.name) needs to be modified")
                            let person = ["index": contactIndex, "person": rhContact, "record": basePerson] as Dictionary<String,AnyObject>
                            self.indexedPeopleModified.append(person)
                        }
                    }
                }
                self.beginModify()
                print("query completed")
            }
        }
    }
    
    func requestAuthorization(completion:(isGranted: Bool, permissionError: NSError?)->()) {
        ab.requestAuthorizationWithCompletion { (granted, error) -> Void in
            completion(isGranted: granted, permissionError: error);
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> NSData {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData: NSData = UIImagePNGRepresentation(image)!
        UIGraphicsEndImageContext()
        return imageData
    }
    
    func avatarImage(index: Int) -> NSData {
        let colorIndex = avatarProfileColor(index)
        let currentColor = GlobalVariables.sharedManager.avatarColors[colorIndex]
        let avatarImage = getImageWithColor(UIColor(hex: currentColor), size: CGSize(width: 150, height: 150))
        return avatarImage
    }
    
    func nameColor(index: Int) -> String {
        let colorIndex = avatarProfileColor(index)
        let currentColor = GlobalVariables.sharedManager.nameColors[colorIndex]
        let hexString = currentColor
        return hexString
    }
    
    func avatarProfileColor(value: Int) -> Int {
        let rems = value % 12
        return rems
    }
    
    func createIndex(modified: Bool) {
        if GlobalVariables.sharedManager.objectKeys.count > 0 && self.myResults.count > 0 {
            GlobalVariables.sharedManager.objectKeys.removeAll(keepCapacity: false)
            self.myResults.removeAll(keepCapacity: false)
        }
        print("index fired")
        let dataItems = self.ab.peopleOrderedByUsersPreference as [AnyObject]! as! [RHPerson]
        let indexFilePath = ABManager.indexFile
        var indexController = KannuuIndexController(controllerMode: .Create, indexFilePath: indexFilePath, numberOfOptions: 9, numberOfBranchSelections: 999)
        print("index created")
            for dictionary in dataItems {
                var error : NSError? = nil
                var flName: String! = nil
                var lfName: String! = nil
                if (dictionary.firstName == nil && dictionary.lastName == nil) {
                    if (dictionary.organization != nil) {
                        flName = dictionary.organization!
                        lfName = dictionary.organization!
                    } else if (dictionary.phoneNumbers != nil) {
                        flName = dictionary.phoneNumbers.valueAtIndex(0)! as! String
                        lfName = dictionary.phoneNumbers.valueAtIndex(0)! as! String
                    } else {
                        print("no name or company or numbers")
                        continue
                    }
                }
                else if (dictionary.firstName == nil) {
                    flName = dictionary.lastName!
                    lfName = dictionary.lastName!
                }
                else if (dictionary.lastName == nil) {
                    flName = dictionary.firstName!
                    lfName = dictionary.firstName!
                }
                else {
                    flName = dictionary.firstName! + " " + dictionary.lastName!
                    lfName = dictionary.lastName! + " " + dictionary.firstName!
                }
                //fuzzyPeopleMatching.append(flName)
                indexController?.addIndicies([flName], forData: flName, priority: 0, error: &error)
                indexController?.addIndicies([lfName], forData: flName, priority: 1, error: &error)
            }
        
        indexController = nil
        
        Lookup.lookupController = KannuuIndexController(controllerMode: .Lookup, indexFilePath: indexFilePath, numberOfOptions: 9, numberOfBranchSelections: 999)
        
        GlobalVariables.sharedManager.objectKeys = Lookup.lookupController!.options!
        let selections = Lookup.lookupController!.branchSelecions!
        self.myResults += selections
        print("index completed")
        //self.fuzzyNames()
        self.sortedModifiedRecords(modified)
    }
    
    private class var indexFile : String {
        print("index file path")
        
        func fileInDocumentsDirectory(filename: String) -> String {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = documentsURL.URLByAppendingPathComponent(filename)
            return fileURL.path!
        }
        
        let hkIndexPath: String = fileInDocumentsDirectory("HKIndex")
        return hkIndexPath
    }
    
    func fuzzyNames() {
        for person in fuzzyPeopleMatching {
            fuzzyNameMatching(person)
        }
        uniqueResults += uniq(exactResultsMatch)
    }
    
    func uniq<T: Hashable>(lst: [T]) -> [T] {
        var uniqueSet = [T : Void](minimumCapacity: lst.count)
        for x in lst {
            uniqueSet[x] = ()
        }
        return Array(uniqueSet.keys)
    }
    
    //func checkTuple(tupleToCheck:(String, String), theTupleArray: [NameAndScoreTuple]) -> Bool{
        //Iterate over your Array of tuples
        //for arrayObject in theTupleArray{
            //If a tuple is the same as your tuple to check, it returns true and ends
            //if arrayObject.0 == tupleToCheck.0 || arrayObject.1 == tupleToCheck.1 {
                //return true
            //}
        //}
        
        //If no tuple matches, it returns false
        //return false
    //}
    
    func fuzzyNameMatching(name: String) {
        var filteredPeople = fuzzyPeopleMatching.filter {
            let keyword = $0 as NSString
            return keyword.containsString(name) ?? false
        }
        if filteredPeople.count > 1 {
            for index in 1..<filteredPeople.count {
                let nameToSearch = filteredPeople[0]
                let filteredName = filteredPeople[index]
                let flscore = FuzzySearch.score(originalString: "\(filteredName)", stringToMatch: "\(nameToSearch)", fuzziness: 0.5)
                let lfscore = FuzzySearch.score(originalString: "\(nameToSearch)", stringToMatch: "\(filteredName)", fuzziness: 0.5)
                if flscore > Double(0.75) && flscore < Double(1.0) {
                    let s = (name: nameToSearch, filterName: filteredName)
                    fuzzyResultsMatch.append(s)
                } else if lfscore > Double(0.75) && lfscore < Double(1.0) {
                    let s = (name: nameToSearch, filterName: filteredName)
                    fuzzyResultsMatch.append(s)
                } else if flscore == Double(1.0) {
                    exactResultsMatch.append(nameToSearch)
                }
            }
        }
    }
}
