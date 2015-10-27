//
//  HandoffViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 8/7/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import Foundation
import WatchKit
import RealmSwift

class HandoffViewController: WKInterfaceController {
    @IBOutlet weak var handoffLoading: WKInterfaceImage!
    @IBOutlet weak var loadingText: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        timelineQueue()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func timelineQueue() {
        Timeline.with("Loading") { (queue) -> Void in
            queue.add(delay: 0.0, duration: 2.5, execution: {
                self.loadingHandoff()
                // some code that will executes after the top block + 'delay' time
                
            }, completion: {
                self.loadingText.setText("Handoff Ready!")
                self.handoffLoading.stopAnimating()
            })
            // any code between queue adding functions will executes immediately
            queue.add(delay: 1.0, duration: 0.1, execution: {
                WKInterfaceController.reloadRootControllersWithNames(["Landing"], contexts: nil)
                first = true
                People.people = try! Realm().objects(HKPerson).filter("recent == true").sorted("recentIndex", ascending: false)
                contactLimit = 15
            })
            }.start
    }
    
    func loadingHandoff() {
        handoffLoading.setImageNamed("Handoff_")
        handoffLoading.startAnimatingWithImagesInRange(NSRange(location: 1,length: 3), duration: 3, repeatCount: 0)
    }
}
