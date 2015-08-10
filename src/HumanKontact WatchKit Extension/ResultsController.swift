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

class ResultsController: WKInterfaceController, ContactRowDelegate {
    @IBOutlet weak var headerGroup: WKInterfaceGroup!
    @IBOutlet weak var contactsTable: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    @IBOutlet weak var searchResultsLabel: WKInterfaceLabel!
    
    var indexSet = NSIndexSet()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.timelineQueue(context)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func timelineQueue(context: AnyObject?) {
        Timeline.with(identifier: "Loading") { (queue) -> Void in
            self.searchResultsLabel.setText(activeSearch)
            activeSearch = ""
            selectionValues.removeAll(keepCapacity: false)
            self.loadingContacts()
            self.indexReset()
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
        WKInterfaceController.reloadRootControllersWithNames(["Search"], contexts: ["No"])
        first = true
        People.people = realm.objects(HKPerson)
        contactLimit = 15
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
