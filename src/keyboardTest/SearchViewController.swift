//
//  SearchViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/16/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//
import UIKit

class SearchViewController: SearchBaseController {
    // MARK: Properties
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.TopToBottom, withFrame: self.view.frame, andColors: [FlatHKDark(), FlatHKLight()])
    }
    
    // searchController is set when the search button is clicked.
    var searchController: UISearchController!
    
    // MARK: Actions
    
    @IBAction func searchButtonClicked(button: UIBarButtonItem) {
        // Create the search results view controller and use it for the UISearchController.
        let searchResultsController = storyboard!.instantiateViewControllerWithIdentifier(SearchResultsViewController.StoryboardConstants.identifier) as! SearchResultsViewController
        
        // Create the search controller and make it perform the results updating.
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Present the view controller.
        presentViewController(searchController, animated: true, completion: nil)
    }
}
