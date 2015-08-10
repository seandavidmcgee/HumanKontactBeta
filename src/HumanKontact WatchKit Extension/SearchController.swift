//
//  SearchController.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

var contact: Int = Int()
var avatarProfileColors : Array<UInt32> = [0x2A93EB, 0x07E36D, 0xFF9403, 0x9E80FF, 0xACF728, 0xFF5968, 0x17BAF0, 0xF7F00E, 0xFA8EC7, 0xE41931, 0x04E5E0, 0xBD10E0]
var current: UInt32!
let realm = ABWatchManager.abRealm()
var contactIndex: Int = Int()
var firstActivation = true
var contactLimit = 15
var roundedNum: Int!
var overFlow: Int!
var pageContexts = Array<Dictionary<String,Int>>()
var profileContexts = Array<Dictionary<String,AnyObject>>()
var profilePages = [String]()
var pageNoContext = Array<String>()
var pages = [String]()
var contactInit = 0
var first: Bool = true

class SearchController: WKInterfaceController, ContactRowDelegate {
    @IBOutlet weak var headerGroup: WKInterfaceGroup!
    @IBOutlet weak var contactsTable: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    
    var realmToken: NotificationToken?
    var indexSet = NSIndexSet()
    
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        if let notificationIdentifier = identifier {
            if notificationIdentifier == "callContact" {
                println("fired")
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.timelineQueue()
        
        //realmToken = ABWatchManager.abRealm().addNotificationBlock { note, realm in
            //self.reloadTableData(false)
        //}
        
    }
    
    override func willActivate() {
        if !firstActivation {
            self.reloadTableData(false)
        }
        firstActivation = true
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func timelineQueue() {
        Timeline.with(identifier: "Loading") { (queue) -> Void in
            self.loadingContacts()
            if returnFromResults == false {
                self.indexOptions()
            } else {
                returnFromResults = false
            }
            queue.add(delay: 0.5, duration: 2.0, execution: {
                // some code that will take assumed 2.0 seconds
                self.reloadTableData(false)
                }, completion: {
                    // some code that will excutes after 'delay' + 'duration'
            })
            
            queue.add(delay: 0.0, duration: 0.1, execution: {
                // some code that will executes after the top block + 'delay' time
                self.loadingImage.stopAnimating()
                self.loadingImage.setHidden(true)
            })
            // any code between queue adding functions will executes immediately
            
            }.start
    }
    
    func loadingContacts() {
        loadingImage.setImageNamed("circleani1_")
        loadingImage.startAnimatingWithImagesInRange(NSRange(location: 1,length: 9), duration: 1, repeatCount: 50)
    }
    
    func indexOptions() {
        let keyDictionary = ["keys" : ""]
        WKInterfaceController.openParentApplication(keyDictionary) {
            (replyDictionary, error) -> Void in
            
            if let castedResponseDictionary = replyDictionary as? [String: [AnyObject]],
                responseMessage = castedResponseDictionary["keys"]
            {
                keyValues = responseMessage
                self.roundToFour(keyValues.count)
                overFlow = self.remFromFour(keyValues.count)
            }
        }
    }
    
    func indexReset() {
        let keyDictionary = ["clearkeys" : ""]
        
        WKInterfaceController.openParentApplication(keyDictionary) {
            (replyDictionary, error) -> Void in
            
            if let castedResponseDictionary = replyDictionary as? [String: [AnyObject]],
                responseMessage = castedResponseDictionary["clearkeys"]
            {
                keyValues = responseMessage
                self.roundToFour(keyValues.count)
                overFlow = self.remFromFour(keyValues.count)
            }
        }
    }
    
    func reloadTableData(more: Bool) {
        var contactRows = Int(self.roundUp(contactLimit, divisor: 3) / 3)
        if more == true {
            contactsTable.insertRowsAtIndexes(indexSet, withRowType: "TripleColumnRowController")
        } else {
            contactsTable.setNumberOfRows(contactRows, withRowType: "TripleColumnRowController")
        }
        for i in 0..<1 {
            autoreleasepool({ () -> () in
                for index in contactInit..<contactLimit {
                    var hkPerson = People.people[Int(index)] as HKPerson
                    contactIndex = roundDown(index, divisor: 3) / 3
                    if let hkAvatar = hkPerson.avatar as NSData! {
                        if let person = self.contactsTable.rowControllerAtIndex(contactIndex) as? TripleColumnRowController {
                            person.delegate = self
                            person.rowControllerGroup.setHidden(false)
                            var imageIndex: Int!
                            if hkAvatar.length > 0 {
                                switch index {
                                case let index where index == 0:
                                    imageIndex = index
                                    setImageWithData(person.leftContactImage, data: hkAvatar)
                                    populateTableAvatars(imageIndex)
                                    person.leftTag = index
                                    person.leftHasImage = true
                                case let index where index == 1:
                                    imageIndex = index
                                    setImageWithData(person.centerContactImage, data: hkAvatar)
                                    populateTableAvatars(imageIndex)
                                    person.centerTag = index
                                    person.centerHasImage = true
                                case let index where index == 2:
                                    imageIndex = index
                                    setImageWithData(person.rightContactImage, data: hkAvatar)
                                    populateTableAvatars(imageIndex)
                                    person.rightTag = index
                                    person.rightHasImage = true
                                case let index where index % 3 == 0:
                                    imageIndex = index
                                    setImageWithData(person.leftContactImage, data: hkAvatar)
                                    populateTableAvatars(imageIndex)
                                    person.leftTag = index
                                    person.leftHasImage = true
                                case let index where index % 3 == 1:
                                    imageIndex = index
                                    setImageWithData(person.centerContactImage, data: hkAvatar)
                                    populateTableAvatars(imageIndex)
                                    person.centerTag = index
                                    person.centerHasImage = true
                                case let index where index % 3 == 2:
                                    imageIndex = index
                                    setImageWithData(person.rightContactImage, data: hkAvatar)
                                    populateTableAvatars(imageIndex)
                                    person.rightTag = index
                                    person.rightHasImage = true
                                default:
                                    println("done")
                                }
                            }
                            if hkAvatar.length == 0 {
                                switch index {
                                case let index where index == 0:
                                    imageIndex = index
                                    populateTableAvatars(imageIndex)
                                    person.leftTag = index
                                    person.leftHasImage = false
                                case let index where index == 1:
                                    imageIndex = index
                                    populateTableAvatars(imageIndex)
                                    person.centerTag = index
                                    person.centerHasImage = false
                                case let index where index == 2:
                                    imageIndex = index
                                    populateTableAvatars(imageIndex)
                                    person.rightTag = index
                                    person.rightHasImage = false
                                case let index where index % 3 == 0:
                                    imageIndex = index
                                    populateTableAvatars(imageIndex)
                                    person.leftTag = index
                                    person.leftHasImage = false
                                case let index where index % 3 == 1:
                                    imageIndex = index
                                    populateTableAvatars(imageIndex)
                                    person.centerTag = index
                                    person.centerHasImage = false
                                case let index where index % 3 == 2:
                                    imageIndex = index
                                    populateTableAvatars(imageIndex)
                                    person.rightTag = index
                                    person.rightHasImage = false
                                default:
                                    println("done")
                                }
                            }
                        }
                    }
                }
                updateLoadMoreButton()
            })
        }
    }
    @IBAction func callKeyboard() {
        if first && selectionValues == nil {
            self.dynamicKeyboardLayout()
        } else if first && selectionValues != nil {
            self.indexReset()
            keyEntry = ""
            activeSearch = ""
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("dynamicKeyboardLayout"), userInfo: nil, repeats: false)
        } else {
            self.presentControllerWithNames(pages, contexts: pageContexts)
        }
        first = false
    }
    
    func dynamicKeyboardLayout() {
        if let numberOfKeyControllers = roundedNum as Int! {
            if overFlow == 0 {
                switch numberOfKeyControllers {
                case 1:
                    pages = ["Keyboard1"]
                    pageContexts = [["keys":4]]
                case 2:
                    pages = ["Keyboard1", "Keyboard2"]
                    pageContexts = [["keys":4],["keys":4]]
                case 3:
                    pages = ["Keyboard1", "Keyboard2", "Keyboard3"]
                    pageContexts = [["keys":4],["keys":4],["keys":4]]
                case 4:
                    pages = ["Keyboard1", "Keyboard2", "Keyboard3", "Keyboard4"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":4]]
                case 5:
                    pages = ["Keyboard1", "Keyboard2", "Keyboard3", "Keyboard4", "Keyboard5"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":4],["keys":4]]
                case 6:
                    pages = ["Keyboard1", "Keyboard2", "Keyboard3", "Keyboard4", "Keyboard5", "Keyboard6"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":4],["keys":4],["keys":4]]
                default:
                    pages = []
                    pageContexts = []
                }
            }
            else {
                switch numberOfKeyControllers {
                case 0:
                    pages = ["Keyboard1"]
                    pageContexts = [["keys":overFlow]]
                case 1:
                    pages = ["Keyboard1","Keyboard2"]
                    pageContexts = [["keys":4],["keys":overFlow]]
                case 2:
                    pages = ["Keyboard1","Keyboard2", "Keyboard3"]
                    pageContexts = [["keys":4],["keys":4],["keys":overFlow]]
                case 3:
                    pages = ["Keyboard1","Keyboard2", "Keyboard3", "Keyboard4"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":overFlow]]
                case 4:
                    pages = ["Keyboard1","Keyboard2", "Keyboard3", "Keyboard4", "Keyboard5"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":4],["keys":overFlow]]
                case 5:
                    pages = ["Keyboard1","Keyboard2","Keyboard3","Keyboard4","Keyboard5","Keyboard6"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":4],["keys":4],["keys":overFlow]]
                case 6:
                    pages = ["Keyboard1","Keyboard2","Keyboard3","Keyboard4","Keyboard5","Keyboard6","Keyboard7"]
                    pageContexts = [["keys":4],["keys":4],["keys":4],["keys":4],["keys":4],["keys":4],["keys":overFlow]]
                default:
                    pages = []
                    pageContexts = []
                }
            }
        }
        self.presentControllerWithNames(pages, contexts: pageContexts)
    }
    
    @IBOutlet weak var _loadMoreButton: WKInterfaceButton!
    lazy var loadMoreButton: WKUpdatableButton = WKUpdatableButton(self._loadMoreButton, defaultHidden: false)
    
    @IBAction func loadMore() {
        if (People.people.count - contactLimit) > 15 {
            contactInit = contactLimit
            contactLimit += 15
        } else {
            var contactsLeft = People.people.count - contactLimit
            contactInit = contactLimit
            contactLimit += contactsLeft
        }
        var moreInit = roundDown(contactInit, divisor: 3) / 3
        var moreLimit = roundDown(contactLimit, divisor: 3) / 3
        indexSet = NSIndexSet(indexesInRange: NSRange(moreInit..<moreLimit))
        self.reloadTableData(true)
    }
    
    @IBAction func clearSearch() {
        People.people = realm.objects(HKPerson)
        contactLimit = 15
        keyEntry = ""
        activeSearch = ""
        keyValues.removeAll(keepCapacity: false)
        if selectionValues != nil {
            selectionValues.removeAll(keepCapacity: false)
        }
        first = true
        self.indexReset()
        WKInterfaceController.reloadRootControllersWithNames(["Landing"], contexts: nil)
    }
    
    func updateLoadMoreButton() {
        let moreToLoad = People.people.count > contactLimit
        loadMoreButton.updateHidden(!moreToLoad)
    }
    
    func leftButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool) {
        if let index = tag as Int! {
            var selectedIndex = index
            if image != false {
                self.selectContactWithImage(selectedIndex)
            } else  {
                self.selectContactWithoutImage(selectedIndex)
            }
        } else {
            return
        }
    }
    
    func centerButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool) {
        if let index = tag as Int! {
            var selectedIndex = index
            if image != false {
                self.selectContactWithImage(selectedIndex)
            } else {
                self.selectContactWithoutImage(selectedIndex)
            }
        } else {
            return
        }
    }
    
    func rightButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool) {
        if let index = tag as Int! {
            var selectedIndex = index
            if image != false {
                self.selectContactWithImage(selectedIndex)
            } else {
                self.selectContactWithoutImage(selectedIndex)
            }
        } else {
            return
        }
    }
    
    func selectContactWithImage(index: Int) {
        var selectedColorIndex = avatarProfileColor(index)
        if let contactSelected = People.people[Int(index)] as HKPerson! {
            var profileData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName,
                "avatar": contactSelected.avatar, "color": UIColor(hex: contactSelected.nameColor), "phone": contactSelected.phoneNumbers]
            var profileEmailData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName, "avatar": contactSelected.avatar, "color": UIColor(hex: contactSelected.nameColor), "email": contactSelected.emails]
            
            switch contactSelected.phoneNumbers.count {
                case 0:
                    if contactSelected.emails.count != 0 {
                        profilePages = ["ProfileEmail"]
                        profileContexts = [profileEmailData]
                    } else {
                        profilePages = ["Profile"]
                        profileContexts = [profileData]
                    }
                case 1:
                    if contactSelected.emails.count != 0 {
                        profilePages = ["Profile","ProfileEmail"]
                        profileContexts = [profileData, profileEmailData]
                    } else {
                        profilePages = ["Profile"]
                        profileContexts = [profileData]
                    }
                case 2:
                    if contactSelected.emails.count != 0 {
                        profilePages = ["Profile","Profile2","ProfileEmail"]
                        profileContexts = [profileData, profileData, profileEmailData]
                    } else {
                        profilePages = ["Profile","Profile2"]
                        profileContexts = [profileData, profileData]
                    }
                case 3:
                    if contactSelected.emails.count != 0 {
                        profilePages = ["Profile","Profile2","Profile3","ProfileEmail"]
                        profileContexts = [profileData, profileData, profileData, profileEmailData]
                    } else {
                        profilePages = ["Profile","Profile2","Profile3"]
                        profileContexts = [profileData, profileData, profileData]
                    }
                default:
                    println("too many numbers")
            }
            self.presentControllerWithNames(profilePages, contexts: profileContexts)
        }
    }
    
    func selectContactWithoutImage(index: Int) {
        var selectedColorIndex = avatarProfileColor(index)
        if let contactSelected = People.people[Int(index)] as HKPerson! {
            var profileData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName,
                "initials": avatarInitials(contactSelected.firstName, lastName: contactSelected.lastName), "color": UIColor(hex: contactSelected.nameColor), "phone": contactSelected.phoneNumbers]
            var profileEmailData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName,
                "initials": avatarInitials(contactSelected.firstName, lastName: contactSelected.lastName), "color": UIColor(hex: contactSelected.nameColor), "email": contactSelected.emails]
            
            switch contactSelected.phoneNumbers.count {
            case 0:
                if contactSelected.emails.count != 0 {
                    profilePages = ["ProfileEmail"]
                    profileContexts = [profileEmailData]
                } else {
                    profilePages = ["Profile"]
                    profileContexts = [profileData]
                }
            case 1:
                if contactSelected.emails.count != 0 {
                    profilePages = ["Profile","ProfileEmail"]
                    profileContexts = [profileData, profileEmailData]
                } else {
                    profilePages = ["Profile"]
                    profileContexts = [profileData]
                }
            case 2:
                if contactSelected.emails.count != 0 {
                    profilePages = ["Profile","Profile2","ProfileEmail"]
                    profileContexts = [profileData, profileData, profileEmailData]
                } else {
                    profilePages = ["Profile","Profile2"]
                    profileContexts = [profileData, profileData]
                }
            case 3:
                if contactSelected.emails.count != 0 {
                    profilePages = ["Profile","Profile2","Profile3","ProfileEmail"]
                    profileContexts = [profileData, profileData, profileData, profileEmailData]
                } else {
                    profilePages = ["Profile","Profile2","Profile3"]
                    profileContexts = [profileData, profileData, profileData]
                }
            default:
                println("too many numbers")
            }
            self.presentControllerWithNames(profilePages, contexts: profileContexts)
        }
    }
}

protocol ContactRowDelegate {
    func leftButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool)
    func centerButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool)
    func rightButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool)
}

class TripleColumnRowController: NSObject {
    @IBOutlet weak var leftButton: WKInterfaceButton!
    @IBOutlet weak var leftButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var leftButtonOutline: WKInterfaceGroup!
    @IBOutlet weak var leftButtonName: WKInterfaceLabel!
    @IBOutlet weak var leftInitials: WKInterfaceLabel!
    @IBOutlet weak var leftContactImage: WKInterfaceImage!
    
    @IBOutlet weak var centerButton: WKInterfaceButton!
    @IBOutlet weak var centerButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var centerButtonOutline: WKInterfaceGroup!
    @IBOutlet weak var centerButtonName: WKInterfaceLabel!
    @IBOutlet weak var centerInitials: WKInterfaceLabel!
    @IBOutlet weak var centerContactImage: WKInterfaceImage!
    
    @IBOutlet weak var rightButton: WKInterfaceButton!
    @IBOutlet weak var rightButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var rightButtonOutline: WKInterfaceGroup!
    @IBOutlet weak var rightButtonName: WKInterfaceLabel!
    @IBOutlet weak var rightInitials: WKInterfaceLabel!
    @IBOutlet weak var rightContactImage: WKInterfaceImage!
    
    @IBOutlet weak var rowControllerGroup: WKInterfaceGroup!
    
    var delegate: ContactRowDelegate?
    var leftTag: Int!
    var centerTag: Int!
    var rightTag: Int!
    var leftHasImage: Bool!
    var centerHasImage: Bool!
    var rightHasImage: Bool!
    
    @IBAction func leftButtonPressed() {
        if leftTag != nil {
            self.delegate?.leftButtonWasPressed(leftButton, tag: leftTag, image: leftHasImage)
        }
    }
    
    @IBAction func centerButtonPressed() {
        if centerTag != nil {
            self.delegate?.centerButtonWasPressed(centerButton, tag: centerTag, image: centerHasImage)
        }
    }
    
    @IBAction func rightButtonPressed() {
        if rightTag != nil {
            self.delegate?.rightButtonWasPressed(rightButton, tag: rightTag, image: rightHasImage)
        }
    }
}

class ABWatchManager : NSObject {
    class func abRealm() -> Realm {
        // Switch return statements for in-memory vs. persisted Realms
        //return Realm(inMemoryIdentifier: "OSTABManagerRealm")
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.kannuu.humankontact")!
        let realmPath = directory.path!.stringByAppendingPathComponent("default.realm")
        Realm.defaultPath = realmPath
        return Realm(path: Realm.defaultPath)
    }
}
