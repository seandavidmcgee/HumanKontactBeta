//
//  RightDrawerViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/10/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import AddressBookUI

var initialContext: Int = 0
var currentContextBtns = [UIButton]()
var currentContextLabels = [UILabel]()
var clearIndex: Int!

class RightDrawerTableViewController: UITableViewController, ABNewPersonViewControllerDelegate {
    @IBOutlet weak var clearRecents: UITableViewCell!
    @IBOutlet weak var clearFavorites: UITableViewCell!
    @IBOutlet weak var editSettings: UITableViewCell!
    
    @IBOutlet var drawerBtns: [UIButton]!
    
    @IBOutlet var drawerContextBtns: [UIButton]!
    @IBOutlet var drawerContextLabels: [UILabel]!
    
    var contextCurrentIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        if initialContext == 0 {
            self.drawerItems()
            contextCurrentIndex = 0
            self.contextMenu(contextCurrentIndex)
        }
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: <TableViewDataSource>
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if indexPath.row == 2 {
            appDelegate.toggleRightDrawer(self, animated: true)
            self.addNewPerson()
        }; if indexPath.row == 3 {
            appDelegate.toggleRightDrawer(self, animated: true)
        }; if indexPath.row == 4 {
            appDelegate.toggleRightDrawer(self, animated: true)
        };
        
        switch clearIndex {
        case let clearIndex where clearIndex == recentsIndex:
            if indexPath.row == 5 {
                recentRealm.beginWrite()
                recentRealm.deleteAll()
                recentRealm.commitWrite()
                appDelegate.centerViewController = appDelegate.drawerFavsViewController()
            }; if indexPath.row == 6 {
                appDelegate.toggleRightDrawer(self, animated: true)
                //appDelegate.centerViewController = appDelegate.drawerSettingsViewController()
            }
            
        case let clearIndex where clearIndex == favoritesIndex:
            if indexPath.row == 5 {
                favRealm.beginWrite()
                favRealm.deleteAll()
                favRealm.commitWrite()
                appDelegate.centerViewController = appDelegate.drawerFavsViewController()
            }; if indexPath.row == 6 {
                appDelegate.toggleRightDrawer(self, animated: true)
                //appDelegate.centerViewController = appDelegate.drawerSettingsViewController()
            }
        default:
            if indexPath.row == 5 {
                appDelegate.toggleRightDrawer(self, animated: true)
                //appDelegate.centerViewController = appDelegate.drawerSettingsViewController()
            }
        }
    }
    
    func addNewPerson() {
        let npvc = ABNewPersonViewController()
        npvc.newPersonViewDelegate = self
        let nc = UINavigationController(rootViewController:npvc)
        self.presentViewController(nc, animated:true, completion:nil)
    }
    
    func personViewController(personViewController: ABPersonViewController!, shouldPerformDefaultActionForPerson person: ABRecord!, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {
        return true
    }
    
    func newPersonViewController(newPersonView: ABNewPersonViewController!, didCompleteWithNewPerson person: ABRecord!) {
        //listResults.queueFunctions()
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func drawerItems() {
        for button in drawerBtns {
            button.layer.cornerRadius = button.frame.width/2
            button.clipsToBounds = true
        }
        
        for button in drawerContextBtns {
            currentContextBtns.append(button)
        }
        
        for label in drawerContextLabels {
            currentContextLabels.append(label)
        }
    }
    
    func contextMenu(currentIndex: Int) {
        clearIndex = currentIndex
        switch currentIndex {
        case let currentIndex where currentIndex == recentsIndex:
            for (index, button) in enumerate(currentContextBtns) {
                switch index {
                case let index where index == 0:
                    contextBtnAdjust(button, clear: false)
                    button.setImage(UIImage(named: "ClearRecents"), forState: .Normal)
                case let index where index == 1:
                    contextBtnAdjust(button, clear: false)
                    button.setImage(UIImage(named: "Settings"), forState: .Normal)
                case let index where index == 2:
                    contextBtnAdjust(button, clear: true)
                    button.setImage(nil, forState: .Normal)
                default:
                    break
                }
            }
            
            for (index, label) in enumerate(currentContextLabels) {
                switch index {
                case let index where index == 0:
                    label.text = "Clear Recents"
                case let index where index == 1:
                    label.text = "Settings"
                case let index where index == 2:
                    label.text = ""
                default:
                    break
                }
            }
        case let currentIndex where currentIndex == favoritesIndex:
            for (index, button) in enumerate(currentContextBtns) {
                switch index {
                case let index where index == 0:
                    contextBtnAdjust(button, clear: false)
                    button.setImage(UIImage(named: "ClearFavs"), forState: .Normal)
                case let index where index == 1:
                    contextBtnAdjust(button, clear: false)
                    button.setImage(UIImage(named: "Settings"), forState: .Normal)
                case let index where index == 2:
                    contextBtnAdjust(button, clear: true)
                    button.setImage(nil, forState: .Normal)
                default:
                    break
                }
            }
            
            for (index, label) in enumerate(currentContextLabels) {
                switch index {
                case let index where index == 0:
                    label.text = "Clear Favorites"
                case let index where index == 1:
                    label.text = "Settings"
                case let index where index == 2:
                    label.text = ""
                default:
                    break
                }
            }
        default:
            for (index, button) in enumerate(currentContextBtns) {
                switch index {
                case let index where index == 0:
                    contextBtnAdjust(button, clear: false)
                    button.setImage(UIImage(named: "Settings"), forState: .Normal)
                case let index where index == 1:
                    contextBtnAdjust(button, clear: true)
                    button.setImage(nil, forState: .Normal)
                case let index where index == 2:
                    contextBtnAdjust(button, clear: true)
                    button.setImage(nil, forState: .Normal)
                default:
                    break
                }
            }
            
            for (index, label) in enumerate(currentContextLabels) {
                switch index {
                case let index where index == 0:
                    label.text = "Settings"
                case let index where index == 1:
                    label.text = ""
                case let index where index == 2:
                    label.text = ""
                default:
                    break
                }
            }
        }
    }
    
    func contextBtnAdjust(button: UIButton, clear: Bool) {
        if clear == false {
            button.layer.cornerRadius = button.frame.width/2
            button.clipsToBounds = true
        }
    }
}

