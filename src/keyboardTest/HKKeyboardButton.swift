//
//  HKKeyboardButton.swift
//  keyboardTest
//
//  Created by Sean McGee on 4/2/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit

class HKKeyboardButton: UIButton {
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        let borderColor:UIColor = UIColor( red: 0.004, green: 0.078, blue: 0.216, alpha: 1.000 );
        layer.borderColor = borderColor.CGColor;
        layer.borderWidth = 1
    }
}