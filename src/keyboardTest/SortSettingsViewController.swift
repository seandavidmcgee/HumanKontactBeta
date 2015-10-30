//
//  SortSettingsViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 10/3/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyUserDefaults

class SortSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    let orientSwitch = DGRunkeeperSwitch()
    let sortNameSwitch = DGRunkeeperSwitch()
    let orderNameSwitch = DGRunkeeperSwitch()
    let backupSwitch = DGRunkeeperSwitch()

    var dismissBut = UIButton()
    var barTitle = UILabel()
    let sortCellIdentifier = "Sort"
    let realm = try! Realm()
    var masterTableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: 0xF8F8F8)
        navigationController?.delegate = self
        masterTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        masterTableView.delegate = self
        masterTableView.dataSource = self
        masterTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: sortCellIdentifier)
        masterTableView.separatorStyle = .None
        view.addSubview(masterTableView)
        
        //NavBut
        dismissBut.frame = CGRectMake(20, 7 , 20, 10)
        dismissBut.tintColor = UIColor.whiteColor()
        dismissBut.setImage(UIImage(named: "Dismiss")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        dismissBut.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        
        let leftItem = UIBarButtonItem(customView: dismissBut)
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initSettings()
        self.automaticallyAdjustsScrollViewInsets = false
        masterTableView.showsVerticalScrollIndicator = true
        masterTableView.delaysContentTouches = false
        masterTableView.backgroundColor = UIColor.clearColor()
        
        //if People.people == People.names {
            //orderNameSwitch.setSelectedIndex(1, animated: true)
        //}
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        self.masterTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Sort", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        cell.textLabel!.frame = CGRectMake(15, 17, masterTableView.frame.width - 215, 20)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        switch (indexPath.row) {
        case 0:
            let sortSwitch = sortSwitchSetup()
            cell.textLabel!.text = "Search Sorting"
            cell.addSubview(sortSwitch)
        case 1:
            let orderSwitch = orderSwitchSetup()
            cell.textLabel!.text = "Contacts Ordering"
            cell.addSubview(orderSwitch)
        case 2:
            let orientSwitch = orientSwitchSetup()
            cell.textLabel!.text = "Keyboard Orientation"
            cell.addSubview(orientSwitch)
            print("orient setup")
        case 3:
            let backupSwitch = backupSwitchSetup()
            cell.textLabel!.text = "Data Backup"
            cell.addSubview(backupSwitch)
        default:
            cell.textLabel!.text = "None Available"
        }
        return cell
    }
    
    func orientSwitchSetup() -> DGRunkeeperSwitch {
        let switchX = masterTableView.frame.width - 165
        orientSwitch.leftTitle = "Left"
        orientSwitch.rightTitle = "Right"
        orientSwitch.backgroundColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        orientSwitch.selectedBackgroundColor = .whiteColor()
        orientSwitch.titleColor = .whiteColor()
        orientSwitch.selectedTitleColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        orientSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        orientSwitch.frame = CGRect(x: switchX, y: 12.0, width: 150.0, height: 30.0)
        orientSwitch.addTarget(self, action: Selector("orientValueDidChange:"), forControlEvents: .ValueChanged)
        return orientSwitch
    }
    
    func sortSwitchSetup() -> DGRunkeeperSwitch {
        let switchX = masterTableView.frame.width - 215
        sortNameSwitch.switchTitle = "sortName"
        sortNameSwitch.leftTitle = "First, Last"
        sortNameSwitch.rightTitle = "Last, First"
        sortNameSwitch.backgroundColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        sortNameSwitch.selectedBackgroundColor = .whiteColor()
        sortNameSwitch.titleColor = .whiteColor()
        sortNameSwitch.selectedTitleColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        sortNameSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        sortNameSwitch.frame = CGRect(x: switchX, y: 12.0, width: 200.0, height: 30.0)
        sortNameSwitch.addTarget(self, action: Selector("sortValueDidChange:"), forControlEvents: .ValueChanged)
        return sortNameSwitch
    }
    
    func orderSwitchSetup() -> DGRunkeeperSwitch {
        let switchX = masterTableView.frame.width - 165
        orderNameSwitch.switchTitle = "orderName"
        orderNameSwitch.leftTitle = "A - Z"
        orderNameSwitch.rightTitle = "Indexed"
        orderNameSwitch.backgroundColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        orderNameSwitch.selectedBackgroundColor = .whiteColor()
        orderNameSwitch.titleColor = .whiteColor()
        orderNameSwitch.selectedTitleColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        orderNameSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        orderNameSwitch.frame = CGRect(x: switchX, y: 12.0, width: 150.0, height: 30.0)
        orderNameSwitch.addTarget(self, action: Selector("orderValueDidChange:"), forControlEvents: .ValueChanged)
        return orderNameSwitch
    }
    
    func backupSwitchSetup() -> DGRunkeeperSwitch {
        let switchX = masterTableView.frame.width - 115
        backupSwitch.leftTitle = "No"
        backupSwitch.rightTitle = "Yes"
        backupSwitch.backgroundColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        backupSwitch.selectedBackgroundColor = .whiteColor()
        backupSwitch.titleColor = .whiteColor()
        backupSwitch.selectedTitleColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
        backupSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        backupSwitch.frame = CGRect(x: switchX, y: 12.0, width: 100.0, height: 30.0)
        backupSwitch.addTarget(self, action: Selector("backupValueDidChange:"), forControlEvents: .ValueChanged)
        return backupSwitch
    }
    
    func dismiss() {
        parentViewController?.dismissViewControllerAnimated(true) {
            print("dismissing view controller - done")
        }
    }
    
    func initSettings() {
        orientSettings()
        sortSettings()
        orderSettings()
        backupSettings()
    }
    
    func orientSettings() {
        if Defaults[.orient] == "left" {
            orientSwitch.setSelectedIndex(0, animated: true)
        } else {
            orientSwitch.setSelectedIndex(1, animated: true)
        }
    }
    
    func sortSettings() {
        if Defaults[.sort] == "flName" {
            sortNameSwitch.setSelectedIndex(0, animated: true)
        } else {
            sortNameSwitch.setSelectedIndex(1, animated: true)
        }
    }
    
    func orderSettings() {
        if Defaults[.order] == "alpha" {
            orderNameSwitch.setSelectedIndex(0, animated: true)
        } else {
            orderNameSwitch.setSelectedIndex(1, animated: true)
        }
    }
    
    func backupSettings() {
        if Defaults[.backup] == "yes" {
            backupSwitch.setSelectedIndex(1, animated: true)
        } else {
            backupSwitch.setSelectedIndex(0, animated: true)
        }
    }
    
    func orientValueDidChange(sender:DGRunkeeperSwitch) {
        print("orient changed")
        GlobalVariables.sharedManager.keyboardOrientChanged = true
        if sender.selectedIndex == 0 {
            Defaults[.orient] = "left"
        } else if sender.selectedIndex == 1 {
            Defaults[.orient] = "right"
        }
    }
    
    func sortValueDidChange(sender:DGRunkeeperSwitch) {
        if sender.selectedIndex == 0 {
            Defaults[.sort] = "flName"
        } else if sender.selectedIndex == 1 {
            Defaults[.sort] = "lfName"
        }
    }
    
    func orderValueDidChange(sender:DGRunkeeperSwitch) {
        if sender.selectedIndex == 0 {
            Defaults[.order] = "alpha"
        } else if sender.selectedIndex == 1 {
            Defaults[.order] = "index"
        }
    }
    
    func backupValueDidChange(sender:DGRunkeeperSwitch) {
        if sender.selectedIndex == 0 {
            Defaults[.backup] = "no"
        } else if sender.selectedIndex == 1 {
            Defaults[.backup] = "yes"
        }
    }
}