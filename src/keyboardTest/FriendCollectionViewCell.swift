//
//  FriendCollectionViewCell.swift
//  keyboardTest
//
//  Created by Sean McGee on 6/15/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation

class FriendCollectionViewCell: UICollectionViewCell {
    var person: HKPerson! = nil
    var backgroundImageView = UIImageView()
    var backgroundClipView = UIView()
    var backgroundColorView = UIView()
    var initialsLabel: UILabel! = UILabel()
    var firstNameTitleLabel: UILabel! = UILabel()
    var lastNameTitleLabel: UILabel! = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = UIViewContentMode.Center
        self.userInteractionEnabled = true
        
        backgroundImageView.frame = CGRect(x: 0, y: 5, width: 58, height: 58)
        backgroundImageView.tag = 200
        backgroundImageView.layer.cornerRadius = backgroundImageView.frame.width / 2.0
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.opaque = true
        backgroundImageView.layer.borderWidth = 2
        
        backgroundClipView.frame = CGRect(x: 0, y: 0, width: 58, height: 58)
        backgroundClipView.clipsToBounds = true
        
        backgroundColorView.frame = CGRect(x: 0, y: 5, width: 58, height: 58)
        backgroundColorView.layer.cornerRadius = backgroundColorView.frame.width / 2.0
        backgroundColorView.clipsToBounds = true
        
        initialsLabel.frame = CGRect(x: 0, y: 0, width: backgroundImageView.frame.width, height: backgroundImageView.frame.height)
        initialsLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 21)!
        initialsLabel.textColor = UIColor.blackColor()
        initialsLabel.textAlignment = NSTextAlignment.Center
        backgroundImageView.addSubview(initialsLabel)
        backgroundClipView.addSubview(backgroundImageView)
        contentView.addSubview(backgroundColorView)
        contentView.sendSubviewToBack(backgroundColorView)
        contentView.addSubview(backgroundClipView)
        
        firstNameTitleLabel.frame = CGRect(x: 0, y: 63, width: 58, height: 18)
        firstNameTitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
        firstNameTitleLabel.textColor = UIColor.whiteColor()
        firstNameTitleLabel.textAlignment = .Center
        firstNameTitleLabel.numberOfLines = 1
        firstNameTitleLabel.lineBreakMode = .ByTruncatingTail

        contentView.addSubview(firstNameTitleLabel)
        
        lastNameTitleLabel.frame = CGRect(x: 0, y: 81, width: 58, height: 18)
        lastNameTitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)!
        lastNameTitleLabel.textColor = UIColor.whiteColor()
        lastNameTitleLabel.textAlignment = .Center
        lastNameTitleLabel.numberOfLines = 1
        lastNameTitleLabel.lineBreakMode = .ByTruncatingTail

        contentView.addSubview(lastNameTitleLabel)
        self.addSubview(contentView)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        
    }
    
    override func prepareForReuse() {
        initialsLabel.text = ""
        firstNameTitleLabel.text = ""
        firstNameTitleLabel.hidden = false
        firstNameTitleLabel.textAlignment = .Center
        lastNameTitleLabel.text = ""
        lastNameTitleLabel.hidden = false
        lastNameTitleLabel.textAlignment = .Center
    }
}