//
//  SearchResultsViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/16/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class SearchResultsViewController: SearchTableViewController, UISearchResultsUpdating  {
    // MARK: Types
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.TopToBottom, withFrame: self.view.frame, andColors: [FlatHKDark(), FlatHKLight()])
    }
    
    struct StoryboardConstants {
        /// The identifier string that corresponds to the SearchResultsViewController's view controller defined in the main storyboard.
        static let identifier = "SearchResultsViewControllerIdentifier"
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // updateSearchResultsForSearchController(_:) is called when the controller is being dismissed to allow those who are using the controller they are search as the results controller a chance to reset their state. No need to update anything if we're being dismissed.
        if !searchController.active {
            return
        }
        
        filterString = searchController.searchBar.text
    }
}