//
//  HKPerson.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import AddressBook

class HKPerson : Object {
    dynamic var uuid = NSUUID().UUIDString
    dynamic var group: Group?
    dynamic var createdDateInterval: NSTimeInterval = 0
    dynamic var createdDate: NSDate?{
        get{
            return createdDateInterval == 0 ? nil : NSDate(timeIntervalSince1970: createdDateInterval)
        }
        set(newModifiedDate){
            
            if let date = newModifiedDate{
                createdDateInterval = date.timeIntervalSince1970
            }else {
                createdDateInterval = 0
            }
        }
    }
    
    dynamic var modifiedDateInterval: NSTimeInterval = 0
    dynamic var modifiedDate: NSDate?{
        get{
            return modifiedDateInterval == 0 ? nil : NSDate(timeIntervalSince1970: modifiedDateInterval)
        }
        set(newModifiedDate){
            
            if let date = newModifiedDate{
                modifiedDateInterval = date.timeIntervalSince1970
            }else {
                modifiedDateInterval = 0
            }
        }
    }
    
    dynamic var record: Int = 0
    dynamic var firstName = ""
    dynamic var middleName = ""
    dynamic var lastName = ""
    dynamic var fullName = "No name"
    dynamic var initials = ""
    
    dynamic var tag = 0
    dynamic var isMissing = false
    dynamic var isOrganization = false
    dynamic var company = ""
    dynamic var department = ""
    dynamic var jobTitle = ""
    dynamic var note = ""
    dynamic var nickname = ""
    dynamic var birthPlace = ""
    dynamic var occupation = ""
    
    //Data
    dynamic var avatar = NSData()
    dynamic var avatarColor = NSData()
    
    dynamic var flUsageWeight: Double = 0
    dynamic var recentIndex = 0
    dynamic var favIndex = 0
    dynamic var indexedOrder = 0
    dynamic var nameColor = ""
    dynamic var recent: Bool = false
    dynamic var favorite: Bool = false
    
    //Relations
    let addresses     = List<Address>()
    let phoneNumbers  = List<HKPhoneNumber>()
    let emails        = List<HKEmail>()
    
    //Custom
    let notes        = List<Note>()
    let strongPoints = List<SimpleNote>()
    let weakPoints   = List<SimpleNote>()
    let todos        = List<ToDo>()
    
    func deleteWithChildren(inRealm realm:Realm) {
        realm.delete(addresses)
        realm.delete(phoneNumbers)
        realm.delete(emails)
        realm.delete(notes)
        realm.delete(self)
    }
    
    var detail: String{
        if !note.isEmpty{
            return note
        }
        return " "
    }
    
    var thumbnail: UIImage?{
        get{
            return avatar == NSData() ? nil : UIImage(data: avatar)
        }
        set(newThumbnail){
            
            if let thumb = newThumbnail{
                avatar = UIImageJPEGRepresentation(thumb, 0.5)!
            }else {
                avatar = NSData()
            }
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["thumbnail", "createdDate", "modifiedDate", "attributedFullName"]
    }
    
    override class func primaryKey() -> String {
        return "uuid"
    }
    
    lazy var title: String = {
        return self.fullName
        }()
    
    lazy var subtitle: String = {
        var s = ""
        
        if (!self.department.isEmpty) {
            s += "\(self.department) / "
        }
        s += self.jobTitle
        return s
        }()
}

extension HKPerson {
    func updateIfNeeded(fromRecord person: ABRecordRef, inRealm realm:Realm) {
        let lastModifiedDate = ABRecordCopyValue(person, kABPersonModificationDateProperty).takeRetainedValue() as? NSDate
        let updateDate = modifiedDate?.earlierDate(lastModifiedDate!)
        if (updateDate?.isEqualToDate(lastModifiedDate!) == false) {
            print("Contact was changed externally, we will update it")
            update(fromRecord: person, inRealm: realm)
        }
    }
    
    func update(fromRecord person: ABRecordRef, inRealm realm:Realm) {
        let recordId = ABRecordGetRecordID(person)
        
        if recordId != kABRecordInvalidID {
            let recordInt = Int(recordId)
            self.record = recordInt
        } else{
            print("kABRecordInvalidID")
        }
        
        nameColor = nameColor(Int(recordId))
        
        avatarColor = avatarImage(Int(recordId))
        
        firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as! String? ?? ABRecordCopyValue(person, kABPersonOrganizationProperty)?.takeRetainedValue() as! String? ?? "N/A"
        lastName = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as! String? ?? ""
        middleName = ABRecordCopyValue(person, kABPersonMiddleNameProperty)?.takeRetainedValue() as! String? ?? ""
        initials = profileInitials(firstName, lastName: lastName)
        nickname = ABRecordCopyValue(person, kABPersonNicknameProperty)?.takeRetainedValue() as! String? ?? ""
        fullName  = ABRecordCopyCompositeName(person)?.takeRetainedValue() as String? ?? ABRecordCopyValue(person, kABPersonOrganizationProperty)?.takeRetainedValue() as! String? ?? "N/A"
        
        note = ABRecordCopyValue(person, kABPersonNoteProperty)?.takeRetainedValue() as! String? ?? ""
        
        createdDate = ABRecordCopyValue(person, kABPersonCreationDateProperty).takeRetainedValue() as? NSDate
        modifiedDate = ABRecordCopyValue(person, kABPersonModificationDateProperty).takeRetainedValue() as? NSDate
        
        jobTitle = ABRecordCopyValue(person, kABPersonJobTitleProperty)?.takeRetainedValue() as! String? ?? ""
        company = ABRecordCopyValue(person, kABPersonOrganizationProperty)?.takeRetainedValue() as! String? ?? ""
        
        let kind = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? NSNumber ?? (kABPersonKindPerson as NSNumber)
        isOrganization = kind.isEqualToNumber(kABPersonKindOrganization)
        if kind.isEqualToNumber(kABPersonKindPerson) {
            //print("is person \(fullName)")
        } else {
            //print("is company \(company)")
        }
        department = ABRecordCopyValue(person, kABPersonDepartmentProperty)?.takeRetainedValue() as! String? ?? ""
        
        if ABPersonHasImageData(person) {
            let data = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail) != nil ? ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail).takeRetainedValue() : ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize).takeRetainedValue()
            avatar = data
        }
        
        readEmails(fromRecord: person, inRealm: realm)
        readPhones(fromRecord: person, inRealm: realm)
        readAddresses(fromRecord: person, inRealm: realm)
    }
    
    func profileInitials(firstName: String, lastName: String) -> String {
        var first: String = ""
        var last: String = ""
        if (firstName == "N/A") {
            first = "NA"
            last = ""
        } else if (firstName.characters.count != 0 && lastName.characters.count != 0) {
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
    
    func createIndex(modified: Bool) -> [AnyObject] {
        var myResults = [AnyObject]()
        print("index fired")
        let realm = try! Realm()
        let dataItems = realm.objects(HKPerson)
        let indexFilePath = self.indexFile
        var indexController = KannuuIndexController(controllerMode: .Create, indexFilePath: indexFilePath, numberOfOptions: 9, numberOfBranchSelections: 999)
        print("index created")
        var error : NSError? = nil
        var flName: String! = nil
        var lfName: String! = nil
        for dictionary in dataItems {
            if ((dictionary).lastName == "") {
                flName = (dictionary).firstName
                lfName = (dictionary).firstName
            } else {
                flName = (dictionary).firstName + " " + (dictionary).lastName
                lfName = (dictionary).lastName + " " + (dictionary).firstName
            }
            //fuzzyPeopleMatching.append(flName)
            indexController?.addIndicies([flName], forData: flName, priority: 0, error: &error)
            indexController?.addIndicies([lfName], forData: flName, priority: 2, error: &error)
        }
        
        indexController = nil
        
        Lookup.lookupController = KannuuIndexController(controllerMode: .Lookup, indexFilePath: indexFilePath, numberOfOptions: 9, numberOfBranchSelections: 999)
        
        GlobalVariables.sharedManager.objectKeys = Lookup.lookupController!.options!
        let selections = Lookup.lookupController!.branchSelecions!
        myResults += selections
        print("index completed")
        indexOrderOperation(myResults)
        return myResults
    }
    
    func indexOrderOperation(results: [AnyObject]) {
        let realm = try! Realm()
        let dataItems = realm.objects(HKPerson)
        var i = 0
        for result in results {
            let people = dataItems.filter("fullName BEGINSWITH[c] %@", "\(result)")
            for person in people {
                person.indexedOrder = i
            }
            i++
        }
    }
    
    private var indexFile : String {
        print("index file path")
        
        func fileInDocumentsDirectory(filename: String) -> String {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = documentsURL.URLByAppendingPathComponent(filename)
            return fileURL.path!
        }
        
        let hkIndexPath: String = fileInDocumentsDirectory("HKIndex")
        return hkIndexPath
    }
    
    func readEmails(fromRecord person: ABRecordRef, inRealm realm: Realm){
        if let emailsRef: ABMultiValueRef = ABRecordCopyValue(person,
            kABPersonEmailProperty)?.takeRetainedValue(){
                
                for counter in 0..<ABMultiValueGetCount(emailsRef){
                    let label = ABMultiValueCopyLabelAtIndex(emailsRef,
                        counter)?.takeRetainedValue() as? String ?? ""
                    let email = ABMultiValueCopyValueAtIndex(emailsRef,
                        counter).takeRetainedValue() as! String
                    //print(label)
                    //print(email)
                    let emailObj = realm.create(HKEmail.self, value: ["label": label, "email": email])
                    self.emails.append(emailObj)
                }
        }
    }
    
    func readPhones(fromRecord person: ABRecordRef, inRealm realm: Realm){
        if let phonesRef: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef {
                //print(phonesRef)
            let counter: Int = ABMultiValueGetCount(phonesRef)
            for i in 0..<counter {
                let label: CFStringRef = (ABMultiValueCopyLabelAtIndex(phonesRef, i) != nil) ? ABMultiValueCopyLabelAtIndex(phonesRef, i).takeUnretainedValue() as CFStringRef : ""
                let phone = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as! String
                let cfStr:CFTypeRef = label
                let nsTypeString = cfStr as! NSString
                let swiftString: String = ABPhoneUtility.normalizedPhoneLabelFromString(nsTypeString) as String
                //print(swiftString)
                //print(phone)
                    
                let normalizedString = ABPhoneUtility.normalizedPhoneStringFromString(phone) as String
                let phoneObj = HKPhoneNumber()
                phoneObj.label = swiftString
                phoneObj.formattedNumber = normalizedString
                phoneObj.number = phone
                self.phoneNumbers.append(phoneObj)
            }
        }
    }
    
    func readAddresses(fromRecord person: ABRecordRef, inRealm realm:Realm){
        if let addressesRef: ABMultiValueRef = ABRecordCopyValue(person, kABPersonAddressProperty)?.takeRetainedValue() {
            for counter in 0..<ABMultiValueGetCount(addressesRef){
                let dict = ABMultiValueCopyValueAtIndex(addressesRef, counter).takeRetainedValue() as! NSDictionary
                    
                let street = dict[String(kABPersonAddressStreetKey)] as? String ?? ""
                let city = dict[String(kABPersonAddressCityKey)] as? String ?? ""
                let state = dict[String(kABPersonAddressStateKey)] as? String ?? ""
                let country = dict[String(kABPersonAddressCountryKey)] as? String ?? ""
                let countryCode = dict[String(kABPersonAddressCountryCodeKey)] as? String ?? ""
                let zip = dict[String(kABPersonAddressZIPKey)] as? String ?? ""
                    
                let label = ABMultiValueCopyLabelAtIndex(addressesRef, counter)?.takeRetainedValue() as? String ?? ""
                let addressObj = realm.create(Address.self, value: ["label": label, "street": street, "city": city, "state": state, "country": country, "countryCode": countryCode, "zip": zip])
                self.addresses.append(addressObj)
            }
        }
    }
}
