//
//  GridViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

var promptPhonesArray = Array<Dictionary<String,String>>()
var promptEmailsArray = Array<Dictionary<String,String>>()

class GridViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, SwiftPromptsProtocol {
    
    var collectionView: UICollectionView?
    var scrollView: UIScrollView!
    var currentController: UICollectionViewController?
    var parentNavigationController : UINavigationController?
    var prompt = SwiftPromptsView()
    var textFieldInsideSearchBar = contactsSearchController.searchBar.valueForKey("searchField") as? UITextField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 58, height: 102)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.registerClass(FriendCollectionViewCell.self, forCellWithReuseIdentifier: "FriendCollectionViewCell")
        self.view.addSubview(collectionView!)
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshTable()
        collectionView!.showsVerticalScrollIndicator = false
        collectionView!.showsVerticalScrollIndicator = true
        collectionView!.delaysContentTouches = false
        
        contactsSearchController.searchResultsUpdater = self
        normalSearchController.searchResultsUpdater = self
        
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        textFieldInsideSearchBar?.delegate = self
        
        if (keyboardButton.enabled == false) {
            keyboardButton.enabled = true
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(false)
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        realm.refresh()
        self.collectionView!.reloadData()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    func backgroundAddRecent() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            recentResults.fetchRecents()
        }
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func avatarImage(index: Int) -> UIImage {
        var colorIndex = avatarProfileColor(index)
        var currentColor = avatarColors[colorIndex]
        var avatarImage = getImageWithColor(UIColor(hex: currentColor), size: CGSize(width: 150, height: 150))
        return avatarImage
    }
    
    func avatarProfileColor(value: Int) -> Int {
        let rems = value % 12
        return rems
    }
    
    func profilePhone(number: String) -> String {
        let rangeOfLabel = number.rangeOfString(":")
        var phoneNumber: String!
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            phoneNumber = number.substringFromIndex(labelIndex + 1)
        }
        return phoneNumber
    }
    
    func profilePhoneLabel(number: String) -> String {
        let rangeOfLabel = number.rangeOfString(":")
        var phoneLabel: String!
        if let labelIndex = number.indexOfCharacter(":") {
            let index: String.Index = advance(number.startIndex, labelIndex)
            let label: String = number.substringToIndex(index)
            phoneLabel = label
        } else {
            phoneLabel = "phone"
        }
        return phoneLabel
    }
    
    func profileEmail(email: String) -> String {
        let rangeOfLabel = email.rangeOfString(":")
        var emailString: String!
        if let labelIndex = email.indexOfCharacter(":") {
            let index: String.Index = advance(email.startIndex, labelIndex)
            let label: String = email.substringToIndex(index)
            emailString = email.substringFromIndex(labelIndex + 1)
        } else {
            emailString = "\(email)"
        }
        return emailString
    }
}
