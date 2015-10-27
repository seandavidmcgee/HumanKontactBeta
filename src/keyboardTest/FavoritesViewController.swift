//
//  FavoritesViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/11/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation

var pickedPerson : String!
var pickedImage : UIImage!
var pickedBG : UIImage!
var pickedInitials : String?
var pickedName : String?
var pickedCompany : String?
var pickedTitle : String?
var phonesArray = Array<Dictionary<String,String>>()
var emailsArray = Array<Dictionary<String,String>>()
var phonesProfileArray = Array<Dictionary<String,String>>()
var emailsProfileArray = Array<Dictionary<String,String>>()
var promptPhonesArray = Array<Dictionary<String,String>>()
var promptEmailsArray = Array<Dictionary<String,String>>()
var avatarView: DNVAvatarView!
var contactAvatar: DNVAvatar!
var avatarWidth: NSLayoutConstraint!
var bgSnapshot: UIImage!

class FavoritesViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
