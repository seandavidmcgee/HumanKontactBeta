//
//  SyncAddressBookOperation.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/20/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import RealmSwift

class SyncAddressBookContactsOperation: NSOperation {
    
    var adbk: ABAddressBook!
    
    override func main() {
        if self.cancelled {
            return
        }
        
        if !self.determineStatus() {
            print("not authorized")
            return
        }
        
        importContacts()
        
        if self.cancelled {
            return
        }
    }
    
    var lastSyncDate:NSDate?{
        get{
            return NSUserDefaults.standardUserDefaults().objectForKey("modifiedDate") as? NSDate
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey:"modifiedDate")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func importContacts(){
        do {
            let realm = try Realm()
            realm.beginWrite()
            let allPeople = ABAddressBookCopyArrayOfAllPeople(
                adbk).takeRetainedValue() as NSArray
            
            if let _ = lastSyncDate {
                //Not first sync
                let deleted = findDeletedPersons(inRealm: realm)
                print("Deleted: \(deleted.count)")
                for person in deleted{
                    person.deleteWithChildren(inRealm: realm)
                }
                
                for personRec: ABRecordRef in allPeople{
                    let recordId = ABRecordGetRecordID(personRec)
                    
                    let queryRecordID = realm.objects(HKPerson).filter("record == \(recordId)")
                    let foundRecID = queryRecordID.first
                    if let foundRecID = foundRecID{
                        if Int(recordId) == foundRecID.record{
                            print("Existing person in AB.")
                            foundRecID.updateIfNeeded(fromRecord: personRec, inRealm: realm)
                        }
                    }else{
                        print("New person was created in AB, let's add it too.")
                        let newPerson = HKPerson()
                        newPerson.update(fromRecord: personRec, inRealm: realm)
                        realm.add(newPerson)
                    }
                }
            }else{
                print("First sync with AB. Add all contacts.")
                for personRec: ABRecordRef in allPeople{
                    //First sync
                    let newPerson = HKPerson()
                    newPerson.update(fromRecord: personRec, inRealm: realm)
                    realm.add(newPerson)
                }
            }
            let index = HKPerson()
            index.createIndex(false)
            try realm.commitWrite()
            lastSyncDate = NSDate()
        } catch {
            print("Something went wrong!")
        }
    }
    
    func findDeletedPersons(inRealm realm:Realm) -> [HKPerson]{
        let realm = try! Realm()
        
        var allRecordsIds = [Int]()
        let allPeople = ABAddressBookCopyArrayOfAllPeople(
            adbk).takeRetainedValue() as NSArray
        for personRec: ABRecordRef in allPeople{
            let recordId = ABRecordGetRecordID(personRec)
            allRecordsIds.append(Int(recordId))
        }
        let allPersons = realm.objects(HKPerson)
        var missingPersons = [HKPerson]()
        
        for person in allPersons{
            let isPersonFound = allRecordsIds.filter { $0 == person.record }.count > 0
            if !isPersonFound{
                let foundPerson: ABRecord? = lookup(person: person) as ABRecord?
                if  foundPerson == nil{
                    missingPersons.append(person)
                }
            }
        }
        
        print("Missing Persons in AB sync: \(missingPersons)")
        return missingPersons
    }
    
    func lookup(person person:HKPerson!) -> ABRecord?{
        var rec : ABRecord! = nil
        let people = ABAddressBookCopyPeopleWithName(self.adbk, person.fullName).takeRetainedValue() as NSArray
        
        for personRec in people {
            if let createdDate = ABRecordCopyValue(personRec, kABPersonCreationDateProperty).takeRetainedValue() as? NSDate {
                if createdDate == person.createdDate {
                    let recordId = ABRecordGetRecordID(personRec)
                    person.record == Int(recordId)
                    rec = personRec
                    break
                }
            }
        }
        if rec != nil {
            print("found person and updated recordID")
        }
        return rec
    }
    
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            print(err)
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        return true
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            adbk = nil
            return false
        case .Restricted:
            adbk = nil
            return false
        case .Denied:
            
            let alert = UIAlertController(title: "Need Authorization", message: "Wouldn't you like to authorize this app to use your Contacts?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
                _ in
                let url = NSURL(string:UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(url)
            }))
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(alert, animated:true, completion:nil)
            adbk = nil
            return false
        }
    }
    
}
