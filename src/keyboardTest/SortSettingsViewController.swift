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
        self.view.backgroundColor = UIColor(hex: 0x00000d)
        navigationController?.delegate = self
        masterTableView.frame = CGRect(x: 0, y: 46, width: self.view.frame.width, height: 354)
        masterTableView.delegate = self
        masterTableView.dataSource = self
        masterTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: sortCellIdentifier)
        masterTableView.separatorStyle = .None
        view.addSubview(masterTableView)
        
        //NavBut
        dismissBut.frame = CGRectMake(20, 7 , 20, 20)
        dismissBut.tintColor=UIColor.whiteColor()
        dismissBut.setImage(UIImage(named: "Dismiss")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        dismissBut.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        
        let dismissBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        dismissBtn.setImage(UIImage(named: "Dismiss"), forState: UIControlState.Normal)
        dismissBtn.setImage(UIImage(named: "Dismiss"), forState: UIControlState.Highlighted)
        dismissBtn.tintColor = .whiteColor()
        dismissBtn.addTarget(self, action: Selector("dismiss"), forControlEvents:  UIControlEvents.TouchUpInside)
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
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(hex: 0xe7e8e9)
        header.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 17)!
        header.textLabel!.textColor = UIColor.blackColor()
    }
    
    func tableView( tableView : UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "Search Sorting"
        case 1:
            return "Contacts Ordering"
        case 2:
            return "Keyboard Orientation"
        case 3:
            return "Data Backup"
        default:
            return "None Available"
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Sort", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        switch (indexPath.section) {
        case 0:
            let sortSwitch = sortSwitchSetup()
            cell.addSubview(sortSwitch)
        case 1:
            let orderSwitch = orderSwitchSetup()
            cell.addSubview(orderSwitch)
        case 2:
            let orientSwitch = orientSwitchSetup()
            cell.addSubview(orientSwitch)
            print("orient setup")
        case 3:
            let backupSwitch = backupSwitchSetup()
            cell.addSubview(backupSwitch)
        default:
            cell.textLabel!.text = "None Available"
        }
        return cell
    }
    
    func orientSwitchSetup() -> DGRunkeeperSwitch {
        orientSwitch.leftTitle = "Left-handed"
        orientSwitch.rightTitle = "Right-handed"
        orientSwitch.backgroundColor = UIColor(hex: 0xFB2155)
        orientSwitch.selectedBackgroundColor = .whiteColor()
        orientSwitch.titleColor = .whiteColor()
        orientSwitch.selectedTitleColor = UIColor(hex: 0xFB2155)
        orientSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        orientSwitch.frame = CGRect(x: 44.0, y: 17.0, width: 225.0, height: 30.0)
        orientSwitch.addTarget(self, action: Selector("orientValueDidChange:"), forControlEvents: .ValueChanged)
        return orientSwitch
    }
    
    func sortSwitchSetup() -> DGRunkeeperSwitch {
        sortNameSwitch.switchTitle = "sortName"
        sortNameSwitch.leftTitle = "First, Last"
        sortNameSwitch.rightTitle = "Last, First"
        sortNameSwitch.backgroundColor = UIColor(hex: 0xFB2155)
        sortNameSwitch.selectedBackgroundColor = .whiteColor()
        sortNameSwitch.titleColor = .whiteColor()
        sortNameSwitch.selectedTitleColor = UIColor(hex: 0xFB2155)
        sortNameSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        sortNameSwitch.frame = CGRect(x: 44.0, y: 17.0, width: 200.0, height: 30.0)
        sortNameSwitch.addTarget(self, action: Selector("sortValueDidChange:"), forControlEvents: .ValueChanged)
        return sortNameSwitch
    }
    
    func orderSwitchSetup() -> DGRunkeeperSwitch {
        orderNameSwitch.switchTitle = "orderName"
        orderNameSwitch.leftTitle = "A - Z"
        orderNameSwitch.rightTitle = "Indexed"
        orderNameSwitch.backgroundColor = UIColor(hex: 0xFB2155)
        orderNameSwitch.selectedBackgroundColor = .whiteColor()
        orderNameSwitch.titleColor = .whiteColor()
        orderNameSwitch.selectedTitleColor = UIColor(hex: 0xFB2155)
        orderNameSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        orderNameSwitch.frame = CGRect(x: 44.0, y: 17.0, width: 150.0, height: 30.0)
        orderNameSwitch.addTarget(self, action: Selector("orderValueDidChange:"), forControlEvents: .ValueChanged)
        return orderNameSwitch
    }
    
    func backupSwitchSetup() -> DGRunkeeperSwitch {
        backupSwitch.leftTitle = "No"
        backupSwitch.rightTitle = "Yes"
        backupSwitch.backgroundColor = UIColor(hex: 0xFB2155)
        backupSwitch.selectedBackgroundColor = .whiteColor()
        backupSwitch.titleColor = .whiteColor()
        backupSwitch.selectedTitleColor = UIColor(hex: 0xFB2155)
        backupSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        backupSwitch.frame = CGRect(x: 44.0, y: 17.0, width: 100.0, height: 30.0)
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