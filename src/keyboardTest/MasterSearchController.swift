//
//  MasterSearchController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import AddressBookUI
import RealmSwift

var parentSearchNavigationController : UINavigationController?
var contactsSearchController = UISearchController()
var normalSearchController = UISearchController()
let controller = KeyboardViewController()
var recentPeople = [HKPerson]()
var favPeople = [HKPerson]()
var keyboardOpen : Int = 0
var keyboardButton = UIButton()
var avatarColors : Array<UInt32> = [0x2A93EB, 0x07E36D, 0xFF9403, 0x9E80FF, 0xACF728, 0xFF5968, 0x17BAF0, 0xF7F00E, 0xFA8EC7, 0xE41931, 0x04E5E0, 0xBD10E0]
var nameColors : Array<String> = ["0x2A93EB", "0x07E36D", "0xFF9403", "0x9E80FF", "0xACF728", "0xFF5968", "0x17BAF0", "0xF7F00E", "0xFA8EC7", "0xE41931", "0x04E5E0", "0xBD10E0"]
var searchControllerArray : [UIViewController] = []
var searchpageMenu : CAPSPageMenu?
var listResults = FavoritesViewController()
let gridResults = GridViewController()
let recentResults = RecentsSubViewController()
let favResults = AddedFavsViewController()
var recentsIndex = Int()
var favoritesIndex = Int()

class MasterSearchController: UIViewController {
    var parentNavigationController : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentSearchNavigationController = self.navigationController
        self.addPagingViews()
        contactsSearchController = ({
            // Create the search results view controller and use it for the UISearchController.
            let searchController = UISearchController(searchResultsController: nil)
            let textFieldInsideSearchBar = searchController.searchBar.valueForKey("searchField") as? UITextField
            // Create the search controller and make it perform the results updating.
            searchController.searchResultsUpdater = listResults
            searchController.searchBar.barStyle = .BlackTranslucent
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.tintColor = UIColor.whiteColor()
            searchController.searchBar.sizeToFit()
            
            textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
            textFieldInsideSearchBar?.delegate = listResults
            
            searchController.searchBar.hidden = true
            return searchController
        })()
        
        normalSearchController = ({
            let search = UISearchController(searchResultsController: nil)
            search.searchResultsUpdater = gridResults
            search.hidesNavigationBarDuringPresentation = false
            search.searchBar.barStyle = .BlackTranslucent
            search.dimsBackgroundDuringPresentation = false
            search.searchBar.tintColor = UIColor.whiteColor()
            search.searchBar.sizeToFit()
            search.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
            
            return search
        })()
        
        self.showDashboardView()
        self.addKeyboardToggle()
    }
    
    override func didReceiveMemoryWarning() {}
    
    func addPagingViews() {
        var BitmapOverlay = UIImage(named: "BitmapOverlayBG")
        var navImageView = UIImageView(image: BitmapOverlay)
        navImageView.frame = CGRect(x: 0, y: -20, width: self.view.frame.width, height: 94)
        navImageView.contentMode = UIViewContentMode.ScaleAspectFill
        navImageView.alpha = 0.5
        navImageView.clipsToBounds = true
        self.navigationController?.navigationBar.addSubview(navImageView)
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.title = "Search Contacts"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18.0)!]
        
        searchpageMenu?.controllerScrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height - 74)
        searchpageMenu?.controllerScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(searchControllerArray.count), self.view.frame.height)
        
        var searchParameters: [CAPSPageMenuOption] = [
            .ViewBackgroundColor(UIColor.blackColor()),
            .SelectionIndicatorColor(UIColor.whiteColor()),
            .AddBottomMenuHairline(false),
            .MenuItemFont(UIFont(name: "AvenirNext-Regular", size: 17.0)!),
            .MenuMargin(20.0),
            .MenuHeight(30.0),
            .SelectionIndicatorHeight(2.0),
            .MenuItemWidthBasedOnTitleTextWidth(true),
            .SelectedMenuItemLabelColor(UIColor.whiteColor()),
            .UnselectedMenuItemLabelColor(UIColor.lightTextColor())
        ]
        
        searchpageMenu = CAPSPageMenu(viewControllers: searchControllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: searchParameters)
        
        // Optional delegate
        
        self.view.addSubview(searchpageMenu!.view)
        
        var menuBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        menuBtn.setImage(UIImage(named: "drawerMenu"), forState: UIControlState.Normal)
        menuBtn.setImage(UIImage(named: "drawerMenu"), forState: UIControlState.Highlighted)
        menuBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        menuBtn.addTarget(self, action: "toggleRightDrawer:", forControlEvents:  UIControlEvents.TouchDown)
        
        var item = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.rightBarButtonItem = item
    }
    
    func addKeyboardToggle() {
        var image = UIImage(named: "KeyboardSearch") as UIImage!
        keyboardButton.frame = CGRectMake(self.view.frame.width - 72, self.view.bounds.height - 132, 65, 65)
        keyboardButton.setImage(image, forState: UIControlState.Normal)
        keyboardButton.layer.backgroundColor = UIColor(red: 251/255, green: 22/255, blue: 80/255, alpha: 1.0).CGColor
        keyboardButton.layer.cornerRadius = keyboardButton.frame.width/2.0
        keyboardButton.addTarget(self, action: "keyboardButtonClicked:", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(keyboardButton)
    }
    
    func keyboardButtonClicked(sender: UIButton!) {
        let listIndex = find(searchControllerArray, listResults)
        
        var currentIndex = searchpageMenu?.currentPageIndex
        if (currentIndex == recentsIndex || currentIndex == favoritesIndex) {
            searchpageMenu?.moveToPage(listIndex!)
        }
        if (keyboardOpen < 1) {
            controller.populateKeys()
        }
        if (keyboardOpen > 0 && contactsSearchController.active) {
            controller.view.hidden = false
        } else {
            controller.refreshData()
            self.presentViewController(contactsSearchController, animated: true, completion: nil)
            addChildViewController(controller)
            controller.view.frame = CGRect(x: 0.0, y: self.view.frame.height - 310, width: self.view.frame.width, height: 310.0)
            self.view.addSubview(controller.view)
            controller.didMoveToParentViewController(self)
            controller.view.hidden = false
            contactsSearchController.active = true
            keyboardOpen++
        }
    }
    
    func showDashboardView() {
        let vc = DashboardBarViewController()
        self.view.addSubview(vc.view)
        self.view.bringSubviewToFront(vc.view)
    }
    
    func toggleRightDrawer(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.toggleRightDrawer(sender, animated: true)
        let rightDrawer = RightDrawerTableViewController()
        initialContext++
        if initialContext > 0 {
            var contextIndex = searchpageMenu?.currentPageIndex as Int!
            rightDrawer.contextMenu(contextIndex)
        }
    }
}

extension UIViewController {
    func executeUserActivity(url: NSURL, activity: NSUserActivity) {
        switch activity.activityType {
        case ActivityKeys.ChooseCall:
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            } else {
                let message = "This phone number is not currently available. Please try again."
                let alertView = UIAlertView(title: "Sorry!", message: message, delegate: nil, cancelButtonTitle: "Dismiss")
                alertView.show()
            }
        case ActivityKeys.ChooseText:
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            } else {
                let message = "This phone number is not currently available. Please try again."
                let alertView = UIAlertView(title: "Sorry!", message: message, delegate: nil, cancelButtonTitle: "Dismiss")
                alertView.show()
            }
        case ActivityKeys.ChooseEmail:
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            } else {
                let message = "This email address is not currently available. Please try again."
                let alertView = UIAlertView(title: "Sorry!", message: message, delegate: nil, cancelButtonTitle: "Dismiss")
                alertView.show()
            }
        default:
            let message = "The connection to your other device may have been interrupted. Please try again."
            let alertView = UIAlertView(title: "Handoff Error", message: message, delegate: nil, cancelButtonTitle: "Dismiss")
            alertView.show()
        }
    }
}


