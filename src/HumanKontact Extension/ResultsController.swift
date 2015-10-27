//
//  ResultsController.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/23/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

var peopleLimit = 15
var peopleInit = 0

class ResultsController: WKInterfaceController, ContactRowDelegate {
    @IBOutlet weak var headerGroup: WKInterfaceGroup!
    @IBOutlet weak var contactsTable: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    @IBOutlet weak var searchResultsLabel: WKInterfaceLabel!
    @IBOutlet weak var homeButton: WKInterfaceButton!
    
    var indexSet = NSIndexSet()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self._loadMoreButton.setHidden(true)
        self.loadingImage!.setImageNamed("circleani1_")
        self.timelineQueue(context)
    }
    
    override func willActivate() {
        super.willActivate()
        if People.people.count < 15 {
            contactLimit = People.people.count
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        contactInit = 0
        contactLimit = 15
    }
    
    func timelineQueue(context: AnyObject?) {
        Timeline.with("Loading") { (queue) -> Void in
            self.searchResultsLabel.setText(activeSearch)
            activeSearch = ""
            selectionValues.removeAll(keepCapacity: false)
            queue.add(delay: 0, duration: 1.0, execution: {
                // some code that will take assumed 2.0 seconds
                self.loadingContacts()
                self.indexReset()
                }, completion: {
                    // some code that will excutes after 'delay' + 'duration'
                    self.loadingImage!.stopAnimating()
                    self.loadingImage!.setHidden(true)
                    self.homeButton!.setEnabled(true)
                    self.reloadTableData(false)
                })
            // any code between queue adding functions will executes immediately
            }.start
    }
    
    func loadingContacts() {
        loadingImage.startAnimatingWithImagesInRange(NSRange(location: 1,length: 9), duration: 1, repeatCount: 50)
    }
    
    func indexReset() {
        lookupWatchController?.restart()
        self.roundToFour(keyValues.count)
        overFlow = self.remFromFour(keyValues.count)
    }
    
    func reloadTableData(more: Bool) {
        if more == true {
            contactsTable.insertRowsAtIndexes(indexSet, withRowType: "TripleColumnRowController")
        } else {
            let contactRows = Int(self.roundUp(contactLimit, divisor: 3) / 3)
            contactsTable.setNumberOfRows(contactRows, withRowType: "TripleColumnRowController")
        }
        for _ in 0..<1 {
            autoreleasepool({ () -> () in
                for index in peopleInit..<peopleLimit {
                    let hkPerson = People.people[Int(index)] as HKPerson
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
                                    print("done")
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
                                    print("done")
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
        first = true
        peopleLimit = 15
        contactInit = 0
        contactLimit = 15
        WKInterfaceController.reloadRootControllersWithNames(["Landing"], contexts: ["No"])
    }
    
    @IBOutlet weak var _loadMoreButton: WKInterfaceButton!
    lazy var loadMoreButton: WKUpdatableButton = WKUpdatableButton(self._loadMoreButton, defaultHidden: true)
    
    @IBAction func loadMore() {
        if (People.people.count - peopleLimit) > 15 {
            peopleInit = peopleLimit
            peopleLimit += 15
        } else {
            let contactsLeft = People.people.count - peopleLimit
            peopleInit = peopleLimit
            peopleLimit += contactsLeft
        }
        let moreInit = roundDown(peopleInit, divisor: 3) / 3
        let moreLimit = roundUp(peopleLimit, divisor: 3) / 3
        indexSet = NSIndexSet(indexesInRange: NSRange(moreInit..<moreLimit))
        self.reloadTableData(true)
    }
    
    func updateLoadMoreButton() {
        let moreToLoad = People.people.count > peopleLimit
        print(moreToLoad)
        loadMoreButton.updateHidden(!moreToLoad)
    }
    
    func leftButtonWasPressed(button: WKInterfaceButton, tag: Int, image: Bool) {
        if let index = tag as Int! {
            let selectedIndex = index
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
            let selectedIndex = index
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
            let selectedIndex = index
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
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        
        if let contactSelected = People.people[Int(index)] as HKPerson! {
            let profileData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName,
                "avatar": contactSelected.avatar, "color": UIColor(hex: contactSelected.nameColor), "phone": contactSelected.phoneNumbers, "person": contactSelected.fullName]
            let profileEmailData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName, "avatar": contactSelected.avatar, "color": UIColor(hex: contactSelected.nameColor), "email": contactSelected.emails, "person": contactSelected.uuid]
            
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
                print("too many numbers")
            }
            self.addRecent("\(contactSelected.uuid)")
            appDelegate.sendRecentToPhone("\(contactSelected.uuid)")
            self.presentControllerWithNames(profilePages, contexts: profileContexts)
        }
    }
    
    func selectContactWithoutImage(index: Int) {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        
        if let contactSelected = People.people[Int(index)] as HKPerson! {
            let profileData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName,
                "initials": avatarInitials(contactSelected.firstName, lastName: contactSelected.lastName), "color": UIColor(hex: contactSelected.nameColor), "phone": contactSelected.phoneNumbers, "person": contactSelected.fullName]
            let profileEmailData = ["firstName": contactSelected.firstName, "lastName": contactSelected.lastName,
                "initials": avatarInitials(contactSelected.firstName, lastName: contactSelected.lastName), "color": UIColor(hex: contactSelected.nameColor), "email": contactSelected.emails, "person": contactSelected.uuid]
            
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
                print("too many numbers")
            }
            self.addRecent("\(contactSelected.uuid)")
            appDelegate.sendRecentToPhone("\(contactSelected.uuid)")
            self.presentControllerWithNames(profilePages, contexts: profileContexts)
        }
    }
    
    func addRecent(key: String) {
        self.addRecentSubTask(key)
    }
    
    func addRecentSubTask(key: String) {
        let person = peopleRealm.objectForPrimaryKey(HKPerson.self, key: key)
        let recentIndexCount = People.contacts.first?.recentIndex
        
        do {
            peopleRealm.beginWrite()
            person!.recent = true
            person!.recentIndex = recentIndexCount! + 1
            try peopleRealm.commitWrite()
        } catch let error as NSError {
            print("Error moving file: \(error.description)")
        }
    }
}
