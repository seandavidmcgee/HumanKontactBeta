//
//  contact.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/16/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit

class contact: UITableViewCell {
    
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet var searchName: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.searchImage.layer.masksToBounds = true
        self.searchImage.layer.cornerRadius = self.searchImage.frame.width / 2
        self.searchImage.layer.borderWidth = 0
        self.searchImage.highlighted = false
    }
}
