//
//  InterfaceController.swift
//  HumanKontact Extension
//
//  Created by Sean McGee on 10/5/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    @IBOutlet weak var loadingTxt: WKInterfaceLabel!
    @IBOutlet weak var searchButtonMain: WKInterfaceButton!
    @IBOutlet weak var searchButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var loadingImageGroup: WKInterfaceGroup!
    
    @IBAction func searchButton() {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        let filemgr = NSFileManager.defaultManager()
        
        if filemgr.fileExistsAtPath(docsDir + "/default.realm") {
            pushControllerWithName("Search", context: nil)
        } else {
            self.loadingContacts()
            appDelegate.requestToPhone()
        }
    }
    
    override func handleUserActivity(userInfo: [NSObject : AnyObject]!) {
        if let glance = userInfo["glance"] as? Int {
            if glance == 2 {
                pushControllerWithName("Search", context: nil)
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        self.loadingImage!.setImageNamed("circleani1_")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.loadingImage!.stopAnimating()
        self.loadingImageGroup!.setHidden(true)
        self.searchButtonGroup!.setHidden(false)
    }
    
    func loadingContacts() {
        self.searchButtonGroup!.setHidden(true)
        self.loadingImageGroup!.setHidden(false)
        self.loadingImage!.startAnimatingWithImagesInRange(NSRange(location: 1,length: 9), duration: 1, repeatCount: 100)
    }
}
