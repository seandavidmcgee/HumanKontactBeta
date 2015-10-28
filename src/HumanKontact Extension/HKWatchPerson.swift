//
//  HKWatchPerson.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/20/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift
import Contacts

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