//
//  KeyboardControllerPage3.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/15/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift

class KeyboardControllerThird: WKInterfaceController {
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
        if count(activeSearch) == 1 {
            self.indexReset(true)
            firstActivation = true
            keyEntry = ""
            activeSearch = ""
            if selectionValues != nil {
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
    
    func goToResults() {
        if activeSearch.isEmpty {
            WKInterfaceController.reloadRootControllersWithNames(["Search"], contexts: ["No"])
            first = true
            People.people = realm.objects(HKPerson)
            contactLimit = 15
        } else {
            self.presentControllerWithName("Results", context: "No")
            firstActivation = true
            keyEntry = ""
            self.searchLabel2.setText("")
            returnFromResults = true
        }
    }
    
    var currentPage: Int = 3
    var populateKeys = [WKInterfaceLabel]()
    var keysToDisplay: Int!
    var selectedIndex: String!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        let systemFont: UIFontDescriptor = UIFontDescriptor(name: UIFontTextStyleSubheadline, size: 17)
        let baseFont = UIFont(descriptor: systemFont, size: 17)
        fontAttrs = [NSFontAttributeName : baseFont]
        
        if firstActivation {
            keysAppear(context!)
        }
        if returnFromResults == true {
            searchEntry.setBackgroundImageNamed("ReturnFromResultsBar")
        }
    }
    
    override func willActivate() {
        super.willActivate()
        if !firstActivation {
            keysAppear(pageContexts[currentPage - 1])
        }
        if !activeSearch.isEmpty {
            searchEntry.setBackgroundImageNamed("KeyEntryBarLight")
            deleteButton.setHidden(false)
            var attrString = NSAttributedString(string: "\(activeSearch)", attributes: fontAttrs)
            self.searchLabel2.setAttributedText(attrString)
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
                println("no keys")
            }
        }
    }
    
    func reloadTableData() {
        var pageIndex = ((currentPage - 1) * 4)
        populateKeys = [self.topLeftKeyLabel, self.topRightKeyLabel, self.bottomLeftKeyLabel, self.bottomRightKeyLabel]
        var indexCount = 0
        if firstActivation {
            for index in pageIndex..<pageIndex + keysToDisplay {
                var keyValue = keyValues[index] as! String
                var stringCount = count(keyValue)
                if stringCount < 15 {
                    self.responsiveKeys(stringCount, indexCount: indexCount)
                    var key = populateKeys[indexCount]
                    key.setText("\(keyValue.capitalizedString)")
                } else {
                    self.responsiveLongKeys(keyValue.capitalizedString, indexCount: indexCount)
                }
                indexCount++
            }
        } else {
            for index in pageIndex..<pageIndex + keysToDisplay {
                var keyValue = "\(activeSearch)" + "\(selectionValues[index] as! String)"
                var stringCount = count(keyValue)
                if stringCount < 15 {
                    self.responsiveKeys(stringCount, indexCount: indexCount)
                    var key = populateKeys[indexCount]
                    key.setText("\(keyValue.capitalizedString)")
                } else {
                    self.responsiveLongKeys(keyValue.capitalizedString, indexCount: indexCount)
                }
                indexCount++
            }
        }
    }
    
    func branchOptions(index: Int, entry: String) {
        var pageIndex = ((currentPage - 1) * 4)
        var selectionIndex: Int = pageIndex + index
        if selectionIndex <= 9 {
            selectedIndex = "0\(selectionIndex)"
        } else {
            selectedIndex = "\(selectionIndex)"
        }
        let selectionDictionary = ["selections" : "\(entry)" + selectedIndex]
        WKInterfaceController.openParentApplication(selectionDictionary) {
            (replyDictionary, error) -> Void in
            
            if let castedResponseDictionary = replyDictionary as? [String: [AnyObject]],
                responseMessage = castedResponseDictionary["selections"]
            {
                selectionValues = responseMessage
                self.roundToFour(selectionValues.count)
                overFlow = self.remFromFour(selectionValues.count)
                self.dynamicKeyboardLayout()
            }
        }
    }
    
    func responsiveKeys(stringCount: Int, indexCount: Int) {
        if stringCount > 2 && stringCount < 8 {
            switch indexCount {
            case 0:
                topLeftKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                topLeftKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
            case 1:
                topRightKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                topRightKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
            case 2:
                bottomLeftKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                bottomLeftKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
            case 3:
                bottomRightKey.setWidth(45.0 + (5.0 * (CGFloat(stringCount) - 2.0)))
                bottomRightKeyLabel.setWidth(45.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
            default:
                println("not long enough")
            }
        } else if stringCount >= 8 && stringCount < 15 {
            switch indexCount {
            case 0:
                topLeftKey.setWidth(72)
                topLeftKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
            case 1:
                topRightKey.setWidth(72)
                topRightKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
            case 2:
                bottomLeftKey.setWidth(72)
                bottomLeftKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
            case 3:
                bottomRightKey.setWidth(72)
                bottomRightKeyLabel.setWidth(55.0 + (5.0 * (CGFloat(stringCount/2) - 2.0)))
            default:
                println("not long enough")
            }
        }
    }
    
    func responsiveLongKeys(value: String, indexCount: Int) {
        var stringCountLong = 10
        
        var ellipsisString: String! = ""
        if let spaceIndex = value.indexOfCharacter(" ") {
            let index: String.Index = advance(value.startIndex, 6)
            let label: String = value.substringToIndex(index) + ".."
            let remainder: String = value.substringFromIndex(spaceIndex + 1)
            ellipsisString = label + remainder
        }
        
        switch indexCount {
        case 0:
            topLeftKey.setWidth(72)
            topLeftKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            topLeftKeyLabel.setText(ellipsisString)
        case 1:
            topRightKey.setWidth(72)
            topRightKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            topRightKeyLabel.setText(ellipsisString)
        case 2:
            bottomLeftKey.setWidth(72)
            bottomLeftKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            bottomLeftKeyLabel.setText(ellipsisString)
        case 3:
            bottomRightKey.setWidth(72)
            bottomRightKeyLabel.setWidth(52.0 + (5.0 * (CGFloat(stringCountLong/2) - 2.0)))
            bottomRightKeyLabel.setText(ellipsisString)
        default:
            println("not long enough")
        }
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
        self.indexReset(false)
        WKInterfaceController.reloadRootControllersWithNames(["Search"], contexts: ["No"])
    }
    
    @IBAction func topLeftKeyPressed() {
        self.buttonPressed(0)
    }
    
    @IBAction func topRightKeyPressed() {
        self.buttonPressed(1)
    }
    
    @IBAction func bottomLeftKeyPressed() {
        self.buttonPressed(2)
    }
    
    @IBAction func bottomRightKeyPressed() {
        self.buttonPressed(3)
    }
    
    func buttonPressed(index: Int) {
        firstActivation = false
        var pageIndex = ((currentPage - 1) * 4)
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
            queriedSearch = realm.objects(HKPerson).filter("firstName BEGINSWITH[c] '\(keyEntry)' OR lastName BEGINSWITH[c] '\(keyEntry)'")
        } else {
            queriedSearch = realm.objects(HKPerson).filter("fullName CONTAINS[c] '\(keyEntry)' OR fullName CONTAINS[c] '\(searchString)' OR firstName CONTAINS[c] '\(searchString)' OR lastName CONTAINS[c] '\(searchString)'")
        }
        
        People.people = queriedSearch
        activeSearch = keyEntry
        contactLimit = People.people.count
        if contactLimit <= 6 {
            self.goToResults()
        } else {
            self.branchOptions(index, entry: keyEntry)
        }
    }
    
    func indexReset(delete: Bool) {
        let keyDictionary = ["clearkeys" : ""]
        
        WKInterfaceController.openParentApplication(keyDictionary) {
            (replyDictionary, error) -> Void in
            
            if let castedResponseDictionary = replyDictionary as? [String: [AnyObject]],
                responseMessage = castedResponseDictionary["clearkeys"]
            {
                if delete == false {
                    keyValues = responseMessage
                    self.roundToFour(keyValues.count)
                    overFlow = self.remFromFour(keyValues.count)
                }
            }
        }
    }
    
    func backBranch() {
        let keyDictionary = ["backkeys" : ""]
        
        WKInterfaceController.openParentApplication(keyDictionary) {
            (replyDictionary, error) -> Void in
            
            if let castedResponseDictionary = replyDictionary as? [String: [AnyObject]],
                responseMessage = castedResponseDictionary["backkeys"]
            {
                selectionValues = responseMessage
                self.roundToFour(selectionValues.count)
                overFlow = self.remFromFour(selectionValues.count)
                self.dynamicKeyboardLayout()
            }
        }
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
