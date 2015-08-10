//
//  DoubleColumnRowController.swift
//  keyboardTest
//
//  Created by Sean McGee on 7/6/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import WatchKit

class DoubleColumnRowController: NSObject {
    @IBOutlet weak var topLeftKey: WKInterfaceButton!
    @IBOutlet weak var topLeftKeyGroup: WKInterfaceGroup!
    @IBOutlet weak var topLeftKeyLabel: WKInterfaceLabel!

    @IBOutlet weak var topRightKey: WKInterfaceButton!
    @IBOutlet weak var topRightKeyGroup: WKInterfaceGroup!
    @IBOutlet weak var topRightKeyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bottomLeftKey: WKInterfaceButton!
    @IBOutlet weak var bottomLeftKeyGroup: WKInterfaceGroup!
    @IBOutlet weak var bottomLeftKeyLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bottomRightKey: WKInterfaceButton!
    @IBOutlet weak var bottomRightKeyGroup: WKInterfaceGroup!
    @IBOutlet weak var bottomRightKeyLabel: WKInterfaceLabel!

}