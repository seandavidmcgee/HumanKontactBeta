//
//  KeyboardControllerPage7.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/15/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

class KeyboardControllerSeventh: WKInterfaceController {
    @IBOutlet weak var searchEntry: WKInterfaceGroup!
    
    @IBOutlet weak var topLeftKey: WKInterfaceButton!
    @IBOutlet weak var topLeftKeyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var topRightKey: WKInterfaceButton!
    @IBOutlet weak var topRightKeyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bottomLeftKey: WKInterfaceButton!
    @IBOutlet weak var bottomLeftKeyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bottomRightKey: WKInterfaceButton!
    @IBOutlet weak var bottomRightKeyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var searchLabel2: WKInterfaceLabel!
    @IBOutlet weak var closeButton: WKInterfaceButton!
    @IBOutlet weak var deleteButton: WKInterfaceButton!
    
    @IBAction func backToSearch() {
        self.goToResults()
    }
    
    @IBAction func deleteSearch() {
        if activeSearch.characters.count == 1 {
            self.indexReset()
            firstActivation = true
            keyEntry = ""
            activeSearch = ""
            if selectionValues.count != 0 {
                selectionValues.removeAll(keepCapacity: false)
            }
            self.roundToFour(keyValues.count)
            overFlow = self.remFromFour(keyValues.count)
            self.dynamicKeyboardLayout()
            self.reloadTableData()
        } else {
            keyEntry = keyEntry.substringToIndex(keyEntry.endIndex.predecessor())
            activeSearch = keyEntry
            self.backBranch()
        }
    }
    
    func refreshData() {
        if let indexController = lookupWatchController {
            selectionValues.removeAll(keepCapacity: false)
            selectionValues = indexController.options!
            let selections = indexController.branchSelecions!
            myResults += selections
            activeSearch = indexController.entrySoFar!
            self.searchLabel2.setText(activeSearch)
            self.roundToFour(selectionValues.count)
            overFlow = self.remFromFour(selectionValues.count)
            self.dynamicKeyboardLayout()
        }
    }
    
    func goToResults() {
        if activeSearch.isEmpty {
            WKInterfaceController.reloadRootControllersWithNames(["Landing"], contexts: ["No"])
            first = true
        } else {
            self.presentControllerWithName("Results", context: "No")
            firstActivation = true
            keyEntry = ""
            self.searchLabel2.setText("")
            returnFromResults = true
        }
    }
    
    var currentPage: Int = 7
    var populateKeys = [WKInterfaceLabel]()
    var keysToDisplay = Int()
    var selectedIndex: String!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        if firstActivation {
            keysAppear(context!)
        }
        if returnFromResults == true {
            searchEntry.setBackgroundImageNamed("KeyTopBarInactive")
        }
    }
    
    override func willActivate() {
        super.willActivate()
        if !firstActivation {
            keysAppear(pageContexts[currentPage - 1])
        }
        if !activeSearch.isEmpty {
            deleteButton.setHidden(false)
            self.searchLabel2.setText(activeSearch)
        }
        if returnFromResults == true {
            self.dynamicKeyboardLayout()
            returnFromResults = false
        }
        self.reloadTableData()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func keysAppear(context: AnyObject?) {
        if let contextDict:Dictionary = context as! Dictionary<String,Int>! {
            keysToDisplay = contextDict["keys"]! as Int
            switch keysToDisplay {
            case 4:
                topLeftKey.setHidden(false)
                topRightKey.setHidden(false)
                bottomLeftKey.setHidden(false)
                bottomRightKey.setHidden(false)
            case 3:
                topLeftKey.setHidden(false)
                topRightKey.setHidden(false)
                bottomLeftKey.setHidden(false)
            case 2:
                topLeftKey.setHidden(false)
                topRightKey.setHidden(false)
            case 1:
                topLeftKey.setHidden(false)
            default:
                print("no keys")
            }
        }
    }
    
    func reloadTableData() {
        let pageIndex = ((currentPage - 1) * 4)
        populateKeys = [self.topLeftKeyLabel, self.topRightKeyLabel, self.bottomLeftKeyLabel, self.bottomRightKeyLabel]
        var indexCount = 0
        if firstActivation {
            for index in pageIndex..<pageIndex + keysToDisplay {
                let keyValue = keyValues[index] as! String
                let stringCount = keyValue.characters.count
                if stringCount < 15 {
                    let key = populateKeys[indexCount]
                    key.setText("\(keyValue.capitalizedString)")
                    self.responsiveKeys(stringCount, indexCount: indexCount)
                } else {
                    self.responsiveLongKeys(keyValue.capitalizedString, indexCount: indexCount)
                }
                indexCount++
            }
        } else {
            for index in pageIndex..<pageIndex + keysToDisplay {
                let keyValue = "\(activeSearch)" + "\(selectionValues[index] as! String)"
                let stringCount = keyValue.characters.count
                if stringCount < 15 {
                    let key = populateKeys[indexCount]
                    key.setText("\(keyValue.capitalizedString)")
                    self.responsiveKeys(stringCount, indexCount: indexCount)
                } else {
                    self.responsiveLongKeys(keyValue.capitalizedString, indexCount: indexCount)
                }
                indexCount++
            }
        }
        if !activeSearch.isEmpty {
            searchEntry.setBackgroundImageNamed("KeyEntryBarLight")
        } else {
            searchEntry.setBackgroundImageNamed("KeyTopBarLight")
        }
        self.closeButton.setEnabled(true)
    }
    
    func branchOptions(index: Int) {
        let pageIndex = ((currentPage - 1) * 4)
        let selectionIndex: Int = pageIndex + index
        lookupWatchController?.selectOption(selectionIndex)
    }
    
    func responsiveKeys(stringCount: Int, indexCount: Int) {
        if stringCount <= 2 {
            switch indexCount {
            case 0:
                topLeftKey.setAlpha(1.0)
                topLeftKey.setEnabled(true)
            case 1:
                topRightKey.setAlpha(1.0)
                topRightKey.setEnabled(true)
            case 2:
                bottomLeftKey.setAlpha(1.0)
                bottomLeftKey.setEnabled(true)
            case 3:
                bottomRightKey.setAlpha(1.0)
                bottomRightKey.setEnabled(true)
            default:
                print("not long enough")
            }
        }
        else if stringCount > 2 && stringCount < 8 {
            switch indexCount {
            case 0:
                topLeftKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                topLeftKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                topLeftKey.setAlpha(1.0)
                topLeftKey.setEnabled(true)
            case 1:
                topRightKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                topRightKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                topRightKey.setAlpha(1.0)
                topRightKey.setEnabled(true)
            case 2:
                bottomLeftKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                bottomLeftKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
                bottomLeftKey.setAlpha(1.0)
                bottomLeftKey.setEnabled(true)
            case 3:
                bottomRightKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                bottomRightKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
                bottomRightKey.setAlpha(1.0)
                bottomRightKey.setEnabled(true)
            default:
                print("not long enough")
            }
        } else if stringCount >= 8 && stringCount < 15 {
            switch indexCount {
            case 0:
                topLeftKey.setWidth(72)
                topLeftKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
                topLeftKey.setAlpha(1.0)
                topLeftKey.setEnabled(true)
            case 1:
                topRightKey.setWidth(72)
                topRightKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
                topRightKey.setAlpha(1.0)
                topRightKey.setEnabled(true)
            case 2:
                bottomLeftKey.setWidth(72)
                bottomLeftKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
                bottomLeftKey.setAlpha(1.0)
                bottomLeftKey.setEnabled(true)
            case 3:
                bottomRightKey.setWidth(72)
                bottomRightKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
                bottomRightKey.setAlpha(1.0)
                bottomRightKey.setEnabled(true)
            default:
                print("not long enough")
            }
        }
    }
    
    func responsiveLongKeys(value: String, indexCount: Int) {
        let stringCountLong = 10
        
        var ellipsisString: String! = ""
        if let spaceIndex = value.characters.indexOf(" ") {
            let index = value.startIndex.advancedBy(6)
            let label: String = value.substringToIndex(index) + ".."
            let remainder: String = value.substringFromIndex(spaceIndex.successor())
            ellipsisString = label + remainder
        }
        
        switch indexCount {
        case 0:
            topLeftKey.setWidth(72)
            topLeftKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            topLeftKeyLabel.setText(ellipsisString)
            topLeftKey.setAlpha(1.0)
            topLeftKey.setEnabled(true)
        case 1:
            topRightKey.setWidth(72)
            topRightKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            topRightKeyLabel.setText(ellipsisString)
            topRightKey.setAlpha(1.0)
            topRightKey.setEnabled(true)
        case 2:
            bottomLeftKey.setWidth(72)
            bottomLeftKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            bottomLeftKeyLabel.setText(ellipsisString)
            bottomLeftKey.setAlpha(1.0)
            bottomLeftKey.setEnabled(true)
        case 3:
            bottomRightKey.setWidth(72)
            bottomRightKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            bottomRightKeyLabel.setText(ellipsisString)
            bottomRightKey.setAlpha(1.0)
            bottomRightKey.setEnabled(true)
        default:
            print("not long enough")
        }
    }
    
    @IBAction func clearSearch() {
        People.people = People.realm.filter("recent == true").sorted("recentIndex", ascending: false)
        contactLimit = 15
        peopleLimit = 15
        People.contacts = People.realm.sorted("indexedOrder", ascending: true)
        keyEntry = ""
        activeSearch = ""
        keyValues.removeAll(keepCapacity: false)
        if selectionValues.count != 0 {
            selectionValues.removeAll(keepCapacity: false)
        }
        first = true
        self.indexReset()
        WKInterfaceController.reloadRootControllersWithNames(["Search"], contexts: ["No"])
    }
    
    @IBAction func topLeftKeyPressed() {
        self.buttonPressed(0)
    }
    
    @IBAction func topRightKeyPressed() {
        self.buttonPressed(1)
    }
    
    func buttonPressed(index: Int) {
        firstActivation = false
        let pageIndex = ((currentPage - 1) * 4)
        keyIndexSelected = pageIndex + index
        baseKey = keyEntry
        var keyEntered: String!
        
        if baseKey == "" {
            keyEntered = keyValues[keyIndexSelected] as! String
            keyEntry = keyEntered.capitalizedString
        } else {
            keyEntered = "\(baseKey)" + "\(selectionValues[keyIndexSelected] as! String)"
            keyEntry = keyEntered.capitalizedString
        }
        // Query using a predicate string
        
        var searchString: String! = ""
        if let spaceIndex = keyEntry.characters.indexOf(" ") {
            let lastName: String = keyEntry.substringToIndex(spaceIndex)
            let firstName: String = keyEntry.substringFromIndex(spaceIndex.successor())
            if firstName.characters.count > 0 && lastName.characters.count > 0 {
                searchString = firstName + " " + lastName
            } else if firstName.characters.count == 0 && lastName.characters.count > 0 {
                searchString = lastName
            } else if lastName.characters.count == 0 && firstName.characters.count > 0 {
                searchString = firstName
            }
        }
        
        var queriedSearch: Results<HKPerson>
        if searchString == "" {
            queriedSearch = People.realm.filter("firstName BEGINSWITH[c] '\(keyEntry)' OR lastName BEGINSWITH[c] '\(keyEntry)' OR fullName BEGINSWITH[c] '\(keyEntry)'")
        } else {
            queriedSearch = People.realm.filter("fullName BEGINSWITH[c] '\(keyEntry)' OR fullName BEGINSWITH[c] '\(searchString)' OR firstName BEGINSWITH[c] '\(searchString)' OR lastName BEGINSWITH[c] '\(searchString)' OR fullName == '\(keyEntry)' OR fullName == '\(searchString)'")
        }
        
        People.people = queriedSearch
        activeSearch = keyEntry
        peopleLimit = queriedSearch.count
        if peopleLimit <= 6 {
            self.goToResults()
        } else {
            self.branchOptions(index)
            self.refreshData()
        }
    }
    
    func indexReset() {
        lookupWatchController?.restart()
        dispatch_async(dispatch_get_main_queue()) {
            if let indexController = lookupWatchController {
                keyValues = indexController.options!
                let selections = indexController.branchSelecions!
                myResults += selections
                activeSearch = indexController.entrySoFar!
                self.searchLabel2.setText(activeSearch)
                self.roundToFour(keyValues.count)
                overFlow = self.remFromFour(keyValues.count)
                self.dynamicKeyboardLayout()
                self.reloadTableData()
            }
        }
    }
    
    func backBranch() {
        lookupWatchController?.back()
        self.refreshData()
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
                    pages = ["Results"]
                    pageContexts = []
                    pageNoContext = ["No"]
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
                    pages = ["Results"]
                    pageContexts = []
                    pageNoContext = ["No"]
                }
            }
        }
        if pageContexts.isEmpty {
            self.presentControllerWithNames(pages, contexts: pageNoContext)
            keyEntry = ""
            activeSearch = ""
            keyValues.removeAll(keepCapacity: false)
            selectionValues.removeAll(keepCapacity: false)
        } else {
            WKInterfaceController.reloadRootControllersWithNames(pages, contexts: pageContexts)
        }
    }
}
