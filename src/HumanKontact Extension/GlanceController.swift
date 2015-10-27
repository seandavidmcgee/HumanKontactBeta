//
//  GlanceController.swift
//  HumanKontact Extension
//
//  Created by Sean McGee on 10/5/15.
//  Copyright © 2015 Kannuu. All rights reserved.
//

import WatchKit
import Foundation

class GlanceController: WKInterfaceController {
    @IBOutlet weak var favoritesTable: WKInterfaceTable!
    @IBOutlet weak var loadingGlanceImage: WKInterfaceImage!
    @IBOutlet weak var noFavorites: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

protocol ContactRowGlanceDelegate {
    func leftImageWasPressed(image: WKInterfaceImage, tag: Int, hasImage: Bool)
    func centerImageWasPressed(image: WKInterfaceImage, tag: Int, hasImage: Bool)
    func rightImageWasPressed(image: WKInterfaceImage, tag: Int, hasImage: Bool)
}

class TripleColumnGlanceRowController: NSObject {
    @IBOutlet weak var leftButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var leftButtonOutline: WKInterfaceGroup!
    @IBOutlet weak var leftButtonName: WKInterfaceLabel!
    @IBOutlet weak var leftInitials: WKInterfaceLabel!
    @IBOutlet weak var leftContactImage: WKInterfaceImage!
    
    @IBOutlet weak var centerButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var centerButtonOutline: WKInterfaceGroup!
    @IBOutlet weak var centerButtonName: WKInterfaceLabel!
    @IBOutlet weak var centerInitials: WKInterfaceLabel!
    @IBOutlet weak var centerContactImage: WKInterfaceImage!
    
    @IBOutlet weak var rightButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var rightButtonOutline: WKInterfaceGroup!
    @IBOutlet weak var rightButtonName: WKInterfaceLabel!
    @IBOutlet weak var rightInitials: WKInterfaceLabel!
    @IBOutlet weak var rightContactImage: WKInterfaceImage!
    
    @IBOutlet weak var rowControllerGroup: WKInterfaceGroup!
    
    var delegate: ContactRowGlanceDelegate?
    var leftTag: Int!
    var centerTag: Int!
    var rightTag: Int!
    var leftHasImage: Bool!
    var centerHasImage: Bool!
    var rightHasImage: Bool!
    
    func leftImagePressed() {
        if leftTag != nil {
            self.delegate?.leftImageWasPressed(leftContactImage, tag: leftTag, hasImage: leftHasImage)
        }
    }
    
    func centerImagePressed() {
        if centerTag != nil {
            self.delegate?.centerImageWasPressed(centerContactImage, tag: centerTag, hasImage: centerHasImage)
        }
    }
    
    func rightImagePressed() {
        if rightTag != nil {
            self.delegate?.rightImageWasPressed(rightContactImage, tag: rightTag, hasImage: rightHasImage)
        }
    }
}