//
//  MasterSearchController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/30/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit
import Foundation
import Contacts
import ContactsUI
import RealmSwift
import LNRSimpleNotifications
import Google_Material_Design_Icons_Swift
import WatchConnectivity
import SwiftyUserDefaults

var parentSearchNavigationController : UINavigationController?
var contactsSearchController: UISearchController! = nil
var normalSearchController: UISearchController! = nil

class MasterSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, CNContactViewControllerDelegate,UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, WCSessionDelegate, LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate, SwiftPromptsProtocol {
    private let addressBookModel = AddressBookModel()
    
    var parentNavigationController : UINavigationController?
    let transition = BubbleTransition()
    var scrollView = UIScrollView()
    var prompt = SwiftPromptsView()
    let mainPageSwitch = DGRunkeeperSwitch()
    let layoutSwitch = DGRunkeeperSwitch()
    var realmNotification: NotificationToken?
    var bodyView = UIView()
    var collectionWrapper: PullToBounceWrapper!
    var tableWrapper: PullToBounceWrapper!
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!
    var profileBGImageView = UIImageView()
    var button: HamburgerButton! = nil
    var favsBtn = UIButton()
    var subNavView = UIView()
    var blurredImageView = UIImageView()
    var session : WCSession!
    let realm = try! Realm()
    
    @IBOutlet weak var dashTransition: UIButton!
    @IBOutlet weak var dashContainer: UIView!
    @IBOutlet weak var keyboardButton: UIButton!
    
    lazy var masterCollectionView: UICollectionView = {
        var cv = UICollectionView(frame: CGRect(x: 0, y: 5, width: self.view.frame.width, height: self.view.frame.height - 157), collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.bounces = true
        cv.alwaysBounceVertical = true
        cv.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        cv.registerClass(FriendCollectionViewCell.self, forCellWithReuseIdentifier: "FriendCollectionViewCell")
        cv.backgroundColor = UIColor.clearColor()
        return cv
        }()
    
    lazy var masterTableView: UITableView = {
        var tv = UITableView(frame: CGRect(x: 0, y: 5, width: self.view.frame.width, height: self.view.frame.height - 157))
        tv.delegate = self
        tv.dataSource = self
        tv.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "FriendTableViewCell")
        tv.backgroundColor = UIColor.clearColor()
        tv.hidden = true
        return tv
        }()
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        var flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        flow.minimumLineSpacing = 5
        flow.minimumInteritemSpacing = 5
        flow.itemSize = CGSize(width: 63, height: 105)
        return flow
        }()
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(aDecoder)
    }
    
    init(_ coder: NSCoder? = nil) {
        
        if let coder = coder {
            super.init(coder: coder)!
        }
        else {
            super.init(nibName: nil, bundle:nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        addressBookModel.synchronize()
        
        if realmNotification == nil {
            realmNotification = realm.addNotificationBlock({ [weak self](notificationString, realm) -> Void in
                self?.showNotifications()
                self?.masterTableView.reloadData()
                self?.masterCollectionView.reloadData()
                print("refresh")
            })
        }
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self // conforms to WCSessionDelegate
            session.activateSession()
        }
        
        JTSplashView.splashViewWithBackgroundColor(nil, lineColor: nil)
        // Simulate state when we want to hide the splash view
        NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("hideSplashView"), userInfo: nil, repeats: false)
        
        parentSearchNavigationController = self.navigationController
        navigationController?.delegate = self
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        bodyView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        bodyView.frame.y += 44
        
        bodyView.addSubview(masterTableView)
        
        tableWrapper = PullToBounceWrapper(scrollView: masterTableView)
        tableWrapper.hidden = true
        bodyView.addSubview(tableWrapper)
        bodyView.sendSubviewToBack(tableWrapper)
        
        bodyView.addSubview(masterCollectionView)
        
        // Pull To Refresh
        collectionWrapper = PullToBounceWrapper(scrollView: masterCollectionView)
        bodyView.addSubview(collectionWrapper)
        
        collectionWrapper.didPullToRefresh = {
            self.masterCollectionView.reloadData()
            NSTimer.schedule(delay: 2) { timer in
                self.collectionWrapper.stopLoadingAnimation()
            }
        }
        
        tableWrapper.didPullToRefresh = {
            self.masterTableView.reloadData()
            NSTimer.schedule(delay: 2) { timer in
                self.tableWrapper.stopLoadingAnimation()
            }
        }
        
        self.view.addSubview(bodyView)
        
        self.addPagingViews()
        contactsSearchController = ({
            // Create the search results view controller and use it for the UISearchController.
            let searchBaseController = UISearchController(searchResultsController: nil)
            let textFieldInsideSearchBar = searchBaseController.searchBar.valueForKey("searchField") as? UITextField
            // Create the search controller and make it perform the results updating.
            searchBaseController.searchResultsUpdater = self
            searchBaseController.searchBar.barStyle = .BlackTranslucent
            searchBaseController.hidesNavigationBarDuringPresentation = false
            searchBaseController.dimsBackgroundDuringPresentation = false
            searchBaseController.searchBar.tintColor = UIColor.whiteColor()
            searchBaseController.searchBar.sizeToFit()
            
            textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
            textFieldInsideSearchBar?.delegate = self
            
            searchBaseController.searchBar.hidden = true
            return searchBaseController
        })()
        
        normalSearchController = ({
            let search = UISearchController(searchResultsController: nil)
            search.searchResultsUpdater = self
            search.hidesNavigationBarDuringPresentation = false
            search.searchBar.barStyle = .BlackTranslucent
            search.dimsBackgroundDuringPresentation = false
            search.searchBar.tintColor = UIColor.whiteColor()
            search.searchBar.sizeToFit()
            search.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
            
            return search
        })()
        
        self.button = HamburgerButton(frame: CGRectMake(6, 6, 38, 38))
        self.button.addTarget(self, action: "toggle:", forControlEvents:.TouchUpInside)
        
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = LiquidFloatingActionButton(frame: frame)
            floatingActionButton.layer.zPosition = 3
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            self.floatingActionButton = floatingActionButton
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            return LiquidFloatingCell(icon: UIImage(named: iconName)!, label: iconName)
        }
        cells.append(cellFactory("Add Person"))
        cells.append(cellFactory("Filter"))
        cells.append(cellFactory("Settings"))
        
        let floatingFrame = CGRect(x: self.view.frame.width - 42 - 16, y: 6, width: 42, height: 42)
        let topRightButton = createButton(floatingFrame, .Down)
        topRightButton.addSubview(button)
        self.view.addSubview(topRightButton)
        self.view.bringSubviewToFront(topRightButton)
        
        self.addKeyboardToggle()
    }
    
    deinit {
        realm.removeNotification(realmNotification!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        masterTableView.showsVerticalScrollIndicator = true
        masterTableView.delaysContentTouches = false
        masterTableView.backgroundColor = UIColor.clearColor()
        masterTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        masterCollectionView.showsVerticalScrollIndicator = true
        masterCollectionView.delaysContentTouches = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.masterTableView.reloadData()
        self.masterCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let keyControl = GlobalVariables.sharedManager.controller
        if contactsSearchController.active {
            keyControl.view.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {}
    
    // MARK: UIViewControllerTransitioningDelegate

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    func toggle(sender: AnyObject!) {
        if self.floatingActionButton.isClosed {
            self.floatingActionButton.open()
            self.blurredMenuSnapshot()
        } else {
            self.floatingActionButton.close()
            blurredImageView.removeFromSuperview()
        }
        self.button.showsMenu = !self.button.showsMenu
    }
    
    func blurredMenuSnapshot() {
        var backgroundImage = UIImage()
        var effectImage = UIImage()
        backgroundImage = self.view.snapshot(self.view)
        blurredImageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        effectImage = backgroundImage.applyDarkEffect()!
        bgSnapshot = effectImage
        blurredImageView.image = effectImage
        bodyView.addSubview(blurredImageView)
    }
    
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        if index == 2 {
            self.sortTableViewSettings()
        }
        blurredImageView.removeFromSuperview()
        self.button.showsMenu = !self.button.showsMenu
        floatingActionButton.close()
    }

    func sortTableViewSettings() {
        let content: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("settingsNav")
        let partialModal: EMPartialModalViewController = EMPartialModalViewController(rootViewController: content, contentHeight: 400)
        
        presentViewController(partialModal, animated: true) {
            print("presenting settings controller - done")
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = dashTransition.center
        transition.bubbleColor = .whiteColor()
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = dashTransition.center
        transition.bubbleColor = .whiteColor()
        return transition
    }
    
    func hideSplashView() {
        JTSplashView.finishWithCompletion { () -> Void in
            UIApplication.sharedApplication().statusBarHidden = false
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(false)
        super.touchesBegan(touches as Set<UITouch>, withEvent: event)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        // Reply handler, received message
        let value = message["request"] as? String
        let recentValue = message["recent"]
        
        if value == "Realm" {
            let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docsDir = dirPaths[0] as String
            let filemgr = NSFileManager.defaultManager()
            let documentsURL = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            
            if filemgr.fileExistsAtPath(docsDir + "/default.realm") {
                let fileURLs = try! filemgr.contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants)
                for file in fileURLs {
                    self.session.transferFile(file, metadata: nil)
                }
            } else {
                print("Error no file here")
            }
        }
        
        if recentValue != nil {
            let recordKey = recentValue as? String
            addRecent(recordKey!)
        }
        
        // Send a reply
        replyHandler(["reply": "Realm sent"])
    }
    
    func addRecent(key: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addRecentSubTask(key)
        })
    }
    
    func addRecentSubTask(key: String) {
        let person = realm.objectForPrimaryKey(HKPerson.self, key: key)
        let recentIndexCount = RecentPeople.recents.count
        
        realm.beginWrite()
        person!.recent = true
        person!.recentIndex = recentIndexCount + 1
        try! realm.commitWrite()
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        let msg = ["complete": "Realm"]
        
        self.session.sendMessage(msg, replyHandler: { (replyMessage) -> Void in
            // Reply handler - present the reply message on screen
            let value = replyMessage["reply"] as? String
            if value == "Realm added" {
                print("watch realm success")
            }
            }) { (error:NSError) -> Void in
                print(error.localizedDescription)
        }
        
        if let error = error {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func showNotifications() {
        let contactsUpdated = GlobalVariables.sharedManager.recordsModified
        if contactsUpdated != 0 {
            var contactVsContacts = "contacts"
            if contactsUpdated < 2 {
                contactVsContacts = "contact"
            }
            GlobalVariables.sharedManager.recordsModified = 0
            LNRSimpleNotifications.sharedNotificationManager.showNotification("\(contactsUpdated) \(contactVsContacts.capitalizedString) Updated", body: "HumanKontact has updated your \(contactVsContacts) successfully.", callback: { () -> Void in
                LNRSimpleNotifications.sharedNotificationManager.dismissActiveNotification({ () -> Void in
                    print("notification dismissed")
                })
            })
        } else {
            return
        }
    }
    
    func mainSwitchValueDidChange(sender:DGRunkeeperSwitch) {
        if sender.selectedIndex == 0 {
            if contactsSearchController.active {
                GlobalVariables.sharedManager.controller.view.hidden = true
            }
            if isViewLoaded() {
                let center: CGPoint = {
                    let itemFrame = self.navigationController?.navigationBar.frame
                    let itemCenter = CGPoint(x: itemFrame!.midX, y: itemFrame!.midY)
                    if !self.masterTableView.hidden {
                        var convertedCenter = self.masterTableView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                        convertedCenter.y = 0
                        
                        return convertedCenter
                    } else {
                        var convertedCenter = self.masterCollectionView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                        convertedCenter.y = 0
                        
                        return convertedCenter
                    }
                    }()
                
                let transition = CircularRevealTransition(layer: masterTableView.layer, center: center)
                transition.start()
                
                People.people = RecentPeople.recents
                masterTableView.reloadData()
                masterCollectionView.reloadData()
            }
        } else if sender.selectedIndex == 1 {
            if isViewLoaded() {
                let center: CGPoint = {
                    let itemFrame = self.navigationController?.navigationBar.frame
                    let itemCenter = CGPoint(x: itemFrame!.midX, y: itemFrame!.midY)
                    if !self.masterTableView.hidden {
                        var convertedCenter = self.masterTableView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                        convertedCenter.y = 0
                        
                        return convertedCenter
                    } else {
                        var convertedCenter = self.masterCollectionView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                        convertedCenter.y = 0
                        
                        return convertedCenter
                    }
                    }()
                
                let transition = CircularRevealTransition(layer: masterTableView.layer, center: center)
                transition.start()
                
                People.people = realm.objects(HKPerson).sorted("fullName")
                masterTableView.reloadData()
                masterCollectionView.reloadData()
            }
        } else {
            print("no selection")
        }
    }
    
    func layoutSwitchValueDidChange(sender:DGRunkeeperSwitch) {
        if sender.selectedIndex == 0 {
            if isViewLoaded() {
                let center: CGPoint = {
                    let itemFrame = self.navigationController?.navigationBar.frame
                    let itemCenter = CGPoint(x: itemFrame!.midX, y: itemFrame!.midY)
                    var convertedCenter = self.masterTableView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                    convertedCenter.y = 0
                
                    return convertedCenter
                    }()
            
                let transition = CircularRevealTransition(layer: masterTableView.layer, center: center)
                transition.start()
            
                masterTableView.hidden = true
                tableWrapper.hidden = true
                bodyView.bringSubviewToFront(collectionWrapper)
                bodyView.sendSubviewToBack(tableWrapper)
                masterCollectionView.reloadData()
                masterCollectionView.hidden = false
                collectionWrapper?.hidden = false
            }
        } else if sender.selectedIndex == 1 {
            if isViewLoaded() {
                let center: CGPoint = {
                    let itemFrame = self.navigationController?.navigationBar.frame
                    let itemCenter = CGPoint(x: itemFrame!.midX, y: itemFrame!.midY)
                    var convertedCenter = self.masterCollectionView.convertPoint(itemCenter, fromView: self.navigationController?.navigationBar)
                    convertedCenter.y = 0
                    
                    return convertedCenter
                    }()
                
                let transition = CircularRevealTransition(layer: masterCollectionView.layer, center: center)
                transition.start()
                
                masterCollectionView.hidden = true
                collectionWrapper.hidden = true
                bodyView.bringSubviewToFront(tableWrapper)
                bodyView.sendSubviewToBack(collectionWrapper)
                masterTableView.reloadData()
                masterTableView.hidden = false
                tableWrapper.hidden = false
            }
        } else {
            print("no selection")
        }
    }
    
    func addPagingViews() {
        var screenSize = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        profileBGImageView = UIImageView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        profileBGImageView.image = UIImage(named: "BlurredKeyBG")
        profileBGImageView.alpha = 0.7
        profileBGImageView.contentMode = .ScaleAspectFill
        
        view.addSubview(profileBGImageView)
        view.sendSubviewToBack(profileBGImageView)
        
        let BitmapOverlay = UIImage(named: "BitmapOverlayBG")
        let navImageView = UIImageView(image: BitmapOverlay)
        navImageView.frame = CGRectMake(0, -44, view.frame.width, 88)
        navImageView.contentMode = UIViewContentMode.ScaleAspectFill
        navImageView.alpha = 0.6
        navImageView.clipsToBounds = true
        
        navigationController?.navigationBar.addSubview(navImageView)
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 13/255, alpha: 0.8).CGColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        navigationController?.navigationBar.layer.shadowRadius = 5
        navigationController?.navigationBar.layer.shadowOpacity = 0.5
        
        favsBtn.frame = CGRect(x: 16, y: 5, width: 42, height: 42)
        favsBtn.setImage(UIImage(named: "love"), forState: UIControlState.Normal)
        favsBtn.setImage(UIImage(named: "love"), forState: UIControlState.Highlighted)
        favsBtn.tintColor = .whiteColor()
        favsBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        favsBtn.addTarget(self, action: Selector("showFavoritesModal"), forControlEvents:  UIControlEvents.TouchUpInside)
        
        mainPageSwitch.leftTitle = "Recents"
        mainPageSwitch.rightTitle = "Contacts"
        
        mainPageSwitch.backgroundColor = .whiteColor()
        mainPageSwitch.selectedBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0)
        mainPageSwitch.titleColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0)
        mainPageSwitch.selectedTitleColor = .whiteColor()
        mainPageSwitch.setSelectedIndex(1, animated: true)
        mainPageSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 15.0)
        mainPageSwitch.frame = CGRect(x: 30.0, y: 40.0, width: 200.0, height: 30.0)
        mainPageSwitch.addTarget(self, action: Selector("mainSwitchValueDidChange:"), forControlEvents: .ValueChanged)
        navigationItem.titleView = mainPageSwitch
        
        subNavView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 52))
        subNavView.backgroundColor = UIColor(hex: 0x00000d)
        let subImageView = UIImageView(image: BitmapOverlay)
        subImageView.frame = CGRectMake(0, 0, subNavView.frame.width, 52)
        subImageView.contentMode = UIViewContentMode.ScaleAspectFill
        subImageView.alpha = 0.4
        subImageView.clipsToBounds = true
        subNavView.addSubview(subImageView)
        subNavView.sendSubviewToBack(subImageView)
        
        layoutSwitch.leftTitle = "Grid"
        layoutSwitch.rightTitle = "List"
        layoutSwitch.backgroundColor = UIColor(red: 251.0/255.0, green: 33.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        layoutSwitch.selectedBackgroundColor = .whiteColor()
        layoutSwitch.titleColor = .whiteColor()
        layoutSwitch.setSelectedIndex(0, animated: true)
        layoutSwitch.selectedTitleColor = UIColor(red: 251.0/255.0, green: 33.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        layoutSwitch.titleFont = UIFont(name: "AvenirNext-Regular", size: 13.0)
        layoutSwitch.frame = CGRect(x: ((view.frame.width/2) - 75), y: 12.0, width: 150.0, height: 30.0)
        layoutSwitch.addTarget(self, action: Selector("layoutSwitchValueDidChange:"), forControlEvents: .ValueChanged)
        subNavView.addSubview(layoutSwitch)
        view.addSubview(subNavView)
        
        self.dashTransition.addTarget(self, action: "dashboardTouched", forControlEvents: .TouchUpInside)
        self.view.addSubview(favsBtn)
        self.view.bringSubviewToFront(dashContainer)
        self.view.bringSubviewToFront(dashTransition)
    }
    
    func addKeyboardToggle() {
        keyboardButton.layer.cornerRadius = keyboardButton.frame.width/2
        keyboardButton.clipsToBounds = true
        let shadowPath = UIBezierPath(roundedRect: keyboardButton.bounds, cornerRadius: keyboardButton.frame.width/2)
        keyboardButton.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 13/255, alpha: 1.0).CGColor
        keyboardButton.layer.shadowOffset = CGSize(width: 3, height: 2);
        keyboardButton.layer.shadowOpacity = 0.5
        keyboardButton.layer.shadowRadius = 5
        keyboardButton.layer.shadowPath = shadowPath.CGPath
        keyboardButton.layer.masksToBounds = false
        self.view.bringSubviewToFront(keyboardButton)
    }
    
    func dashboardTouched() {
        print("dashboard")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("dashView") as! ViewController
        //let nc = UINavigationController(rootViewController: vc)
        //nc.navigationBar.tintColor = UIColor.clearColor()
        //nc.navigationBarHidden = true
        vc.modalPresentationStyle = .OverCurrentContext
        self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showFavoritesModal() {
        if contactsSearchController.active {
            GlobalVariables.sharedManager.controller.dismissViewControllerAnimated(true, completion: nil)
        }
        let content: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("modalNav") 
        let partialModal: EMPartialModalViewController = EMPartialModalViewController(rootViewController: content, contentHeight: 400)
        
        presentViewController(partialModal, animated: true) {
            print("presenting view controller - done")
        }
    }
    
   @IBAction func keyboardButtonClicked() {
        if (mainPageSwitch.selectedIndex == 0) {
            mainPageSwitch.setSelectedIndex(1, animated: true)
        }
        if GlobalVariables.sharedManager.keyboardFirst == false && contactsSearchController.active == true {
            GlobalVariables.sharedManager.controller.view.hidden = false
        } else {
            GlobalVariables.sharedManager.controller.refreshData()
            GlobalVariables.sharedManager.controller.view.frame = CGRect(x: 0.0, y: self.view.frame.height - 310, width: self.view.frame.width, height: 310.0)
            presentViewController(contactsSearchController, animated: true, completion: nil)
            addChildViewController(GlobalVariables.sharedManager.controller)
            self.view.addSubview(GlobalVariables.sharedManager.controller.view)
            GlobalVariables.sharedManager.controller.didMoveToParentViewController(self)
            GlobalVariables.sharedManager.controller.view.hidden = false
            contactsSearchController.active = true
        }
    }
    
    func recentMessageToWatch(record: String) {
        let msg = ["recent": record]
        session.sendMessage(msg, replyHandler: { (replyMessage) -> Void in
            // Reply handler - present the reply message on screen
            let value = replyMessage["reply"] as? String
            if value == "Recent added" {
                print(value!)
            }
            }) { (error:NSError) -> Void in
                print(error.localizedDescription)
        }
    }
    
    func addNewPerson() {
        //let npvc = CNContact
        //npvc.newPersonViewDelegate = self
        //let nc = UINavigationController(rootViewController:npvc)
        //self.presentViewController(nc, animated:true, completion:nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(People.people.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let hkPerson = People.people[Int(indexPath.row)] as HKPerson
        
        let cellIdentifier:String = "FriendTableViewCell"
        let cell: FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FriendTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.photoImageView!.layer.borderColor = UIColor(hexString: hkPerson.nameColor).CGColor
        cell.backgroundColorView.backgroundColor = UIColor(hexString: hkPerson.nameColor)
        
        if hkPerson.avatar.length != 0 {
            cell.photoImageView!.image = UIImage(data: hkPerson.avatar)
        } else {
            cell.photoImageView!.image = UIImage(data: hkPerson.avatarColor)
            cell.initialsLabel!.text = hkPerson.initials
        }
        cell.person = hkPerson
        cell.nameLabel!.text = hkPerson.fullName
        
        // Phone Numbers
        if let hkPhone = hkPerson.phoneNumbers.first as HKPhoneNumber! {
            if hkPerson.phoneNumbers.count > 1 {
                for phone in hkPerson.phoneNumbers {
                    let phoneStrings: String = phone.formattedNumber
                    if let profileLabel = phone.label as String! {
                        let localPhone = [profileLabel: phone.formattedNumber]
                        cell.phoneCell(phoneStrings, label: profileLabel)
                        phonesArray.append(localPhone)
                    } else {
                        let profileLabel = "phone"
                        let localPhone = [profileLabel: phone.formattedNumber]
                        phonesArray.append(localPhone)
                    }
                }
            } else {
                let phoneString: String = hkPhone.formattedNumber
                if let profileLabel = hkPhone.label as String! {
                    let localPhone = [profileLabel: hkPhone.formattedNumber]
                    cell.phoneCell(phoneString, label: profileLabel)
                    phonesArray.append(localPhone)
                } else {
                    let profileLabel = "phone"
                    let localPhone = [profileLabel: hkPhone.formattedNumber]
                    phonesArray.append(localPhone)
                }
            }
        } else {
            cell.phoneCell("", label: "")
        }
        
        // Emails
        
        if hkPerson.emails.first != nil {
            cell.emailCell(hkPerson, emailCount: hkPerson.emails.count)
        } else {
            cell.emailCell(hkPerson, emailCount: 0)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hkPerson = People.people[Int(indexPath.row)] as HKPerson
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        recentMessageToWatch("\(hkPerson.uuid)")
        
        backgroundAddRecent(hkPerson)
        
        var imageBG: UIImage!
        var image: UIImage!
        
        if hkPerson.avatar.length != 0 {
            imageBG = UIImage(data: hkPerson.avatar)
            image = imageBG
            pickedInitials = ""
        } else {
            imageBG = UIImage(named: "placeBG")
            image = UIImage(data: hkPerson.avatarColor)
            pickedInitials = hkPerson.initials
        }
        let name = hkPerson.fullName
        pickedName = name
        pickedBG = imageBG
        pickedImage = image
        
        // Phone Numbers
        if hkPerson.phoneNumbers.first != nil {
            if hkPerson.phoneNumbers.count > 0 {
                for phone in hkPerson.phoneNumbers {
                    if let profileLabel = phone.label as String! {
                        let localPhone = [profileLabel: phone.formattedNumber]
                        phonesProfileArray.append(localPhone)
                    } else {
                        let profileLabel = "phone"
                        let localPhone = [profileLabel: phone.formattedNumber]
                        phonesProfileArray.append(localPhone)
                    }
                }
            }
        }
        
        // Emails
        
        if hkPerson.emails.first != nil {
            if hkPerson.emails.count > 0 {
                for email in hkPerson.emails {
                    let currentEmail = email as HKEmail!
                    let profileEmailString: String = profileEmail(currentEmail.email)
                    let localEmail = ["email": profileEmailString]
                    emailsProfileArray.append(localEmail)
                }
            }
        }
        let company = hkPerson.company
        pickedCompany = company
        
        let jobTitle = hkPerson.jobTitle
        pickedTitle = jobTitle
        
        let personUUID = hkPerson.uuid
        pickedPerson = personUUID
        
        vc.selectedPerson = pickedPerson
        vc.image = pickedImage
        vc.imageBG = pickedBG
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.jobTitleLabel = pickedTitle
        vc.initials = pickedInitials
        
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        autoreleasepool {
            dispatch_async(dispatch_get_main_queue()) {
                if normalSearchController.active || contactsSearchController.active {
                    self.view.window!.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
                self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
            }
        }
        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Return the number of sections.
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Int(People.people.count)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let hkPerson = People.people[Int(indexPath.row)] as HKPerson
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCollectionViewCell", forIndexPath: indexPath) as! FriendCollectionViewCell
        
        cell.backgroundImageView.layer.borderColor = UIColor(hexString: hkPerson.nameColor).CGColor
        cell.backgroundColorView.backgroundColor = UIColor(hexString: hkPerson.nameColor)
        
        if hkPerson.avatar.length != 0 {
            cell.backgroundImageView.image = UIImage(data: hkPerson.avatar)
        } else {
            cell.backgroundImageView.image = UIImage(data: hkPerson.avatarColor)
            cell.initialsLabel!.text = hkPerson.initials
        }
        
        let firstName = hkPerson.firstName
        let lastName = hkPerson.lastName
        
        if firstName.characters.count >= 8 {
            cell.firstNameTitleLabel.textAlignment = .Left
        }
        if lastName.characters.count >= 8 {
            cell.lastNameTitleLabel.textAlignment = .Left
        }
        
        cell.firstNameTitleLabel!.text = firstName ?? ""
        
        if (cell.firstNameTitleLabel!.text == "") {
            cell.firstNameTitleLabel!.text = lastName
            cell.lastNameTitleLabel!.hidden = true
        } else {
            cell.lastNameTitleLabel!.text = lastName ?? ""
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let hkPerson = People.people[Int(indexPath.row)] as HKPerson
        
        let size = CGSizeMake(50, 50)
        let hasAlpha = false
        let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
        
        var avatarNeeded: Bool! = false
        
        //Create an instance of SwiftPromptsView and assign its delegate
        prompt = SwiftPromptsView(frame: self.view.bounds)
        prompt.delegate = self
        
        //Set the properties for the background
        prompt.setColorWithTransparency(UIColor.clearColor())
        
        //Reset profile action properties
        prompt.callButton.hidden = true
        prompt.messageButton.hidden = true
        prompt.emailButton.hidden = true
        prompt.callButton.setTitle("", forState: UIControlState.Normal)
        prompt.messageButton.setTitle("", forState: UIControlState.Normal)
        prompt.emailButton.setTitle("", forState: UIControlState.Normal)
        prompt.callButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.messageButton.transform = CGAffineTransformMakeTranslation(0, 0)
        prompt.emailButton.transform = CGAffineTransformMakeTranslation(0, 0)
        
        recentMessageToWatch("\(hkPerson.uuid)")
        
        backgroundAddRecent(hkPerson)
        
        if contactsSearchController.active == true
        {
            GlobalVariables.sharedManager.controller.view.hidden = true
        }
        var imageBG: UIImage!
        var image: UIImage!
        
        if hkPerson.avatar.length != 0 {
            imageBG = UIImage(data: hkPerson.avatar)
            image = imageBG
            pickedInitials = ""
        } else {
            avatarNeeded = true
            imageBG = UIImage(named: "placeBG")
            image = UIImage(data: hkPerson.avatarColor)
            pickedInitials = hkPerson.initials
        }
        let name = hkPerson.fullName
        pickedName = name
        pickedBG = imageBG
        pickedImage = image
        
        let personUUID = hkPerson.uuid
        pickedPerson = personUUID
        
        // Phone Numbers
        if hkPerson.phoneNumbers.first != nil {
            if hkPerson.phoneNumbers.count > 0 {
                for phone in hkPerson.phoneNumbers {
                    if let profileLabel = phone.label as String! {
                        let localPhone = [profileLabel: phone.formattedNumber]
                        phonesProfileArray.append(localPhone)
                        promptPhonesArray.append(localPhone)
                    } else {
                        let profileLabel = "phone"
                        let localPhone = [profileLabel: phone.formattedNumber]
                        phonesProfileArray.append(localPhone)
                        promptPhonesArray.append(localPhone)
                    }
                }
            }
        }
        
        // Emails
        
        if hkPerson.emails.first != nil {
            if hkPerson.emails.count > 0 {
                for email in hkPerson.emails {
                    let currentEmail = email as HKEmail!
                    let profileEmailString: String = self.profileEmail(currentEmail.email)
                    let localEmail = ["email": profileEmailString]
                    emailsProfileArray.append(localEmail)
                    promptEmailsArray.append(localEmail)
                }
            }
        }
        
        let company = hkPerson.company
        pickedCompany = company
        
        let jobTitle = hkPerson.jobTitle
        pickedTitle = jobTitle
        
        for phone in promptPhonesArray {
            let valI = phone["iPhone"]
            let valM = phone["Mobile"]
            // Grab each key, value pair from the person dictionary
            if valI != nil || valM != nil {
                prompt.callIncluded = true
                prompt.messageIncluded = true
                prompt.enableCallButtonOnPrompt()
                prompt.enableMessageButtonOnPrompt()
                prompt.callButton.hidden = false
                prompt.callButton.setTitle(pickedPerson, forState: UIControlState.Normal)
                prompt.messageButton.transform = CGAffineTransformMakeTranslation(60, 0)
                prompt.messageButton.hidden = false
                prompt.messageButton.setTitle(pickedPerson, forState: UIControlState.Normal)
                prompt.emailButton.transform = CGAffineTransformMakeTranslation(120, 0)
            }
            else {
                prompt.callIncluded = true
                prompt.messageIncluded = false
                prompt.enableCallButtonOnPrompt()
                prompt.callButton.hidden = false
                prompt.callButton.setTitle(pickedPerson, forState: UIControlState.Normal)
                prompt.emailButton.transform = CGAffineTransformMakeTranslation(60, 0)
            }
        }
        
        if (emailsProfileArray.count > 0) {
            prompt.emailButton.setTitle(pickedPerson, forState: UIControlState.Normal)
            prompt.emailIncluded = true
            prompt.enableEmailButtonOnPrompt()
            prompt.emailButton.hidden = false
        }
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        pickedImage!.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Set the properties of the promt
        prompt.setPromtHeader(pickedName!)
        prompt.setPromptHeaderTxtSize(18.0)
        prompt.setPromptContentTxtSize(18.0)
        prompt.setPromptContentTextFont("AvenirNext-Regular")
        prompt.setPromptContentTextRectY(26.0)
        prompt.setPromptContentTxtColor(UIColor.whiteColor())
        prompt.setPromptContentText("Contact Info")
        prompt.setPromptDismissIconColor(UIColor(patternImage: scaledImage))
        prompt.setPromptDismissIconVisibility(true)
        prompt.setPromptTopBarVisibility(true)
        prompt.setPromptBottomBarVisibility(false)
        prompt.setPromptTopLineVisibility(false)
        prompt.setPromptBottomLineVisibility(true)
        prompt.setPromptWidth(self.view.bounds.width * 0.75)
        prompt.setPromptHeight(self.view.bounds.width * 0.55)
        prompt.setPromptBackgroundColor(UIColor(red: 94.0/255.0, green: 100.0/255.0, blue: 112.0/255.0, alpha: 0.85))
        prompt.setPromptHeaderBarColor(UIColor(red: 50.0/255.0, green: 58.0/255.0, blue: 71.0/255.0, alpha: 0.8))
        prompt.setPromptHeaderTxtColor(UIColor.whiteColor())
        prompt.setPromptBottomLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.setPromptButtonDividerColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.enableDoubleButtonsOnPrompt()
        prompt.setMainButtonText("View Profile")
        prompt.setMainButtonColor(UIColor.whiteColor())
        prompt.setSecondButtonColor(UIColor.whiteColor())
        prompt.setSecondButtonText("Cancel")
        
        if (avatarNeeded == true) {
            prompt.setPromptInitialsVisibility(true)
            prompt.setPromptInitialsText(pickedInitials!)
        } else {
            prompt.setPromptInitialsVisibility(false)
            prompt.setPromptInitialsText("")
        }
        
        self.view.addSubview(prompt)
        collectionView.reloadData()
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func clickedOnTheMainButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        vc.selectedPerson = pickedPerson
        vc.image = pickedImage
        vc.imageBG = pickedBG
        vc.nameLabel = pickedName
        vc.coLabel = pickedCompany
        vc.jobTitleLabel = pickedTitle
        vc.initials = pickedInitials
        
        autoreleasepool {
            dispatch_async(dispatch_get_main_queue()) {
                self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                if normalSearchController.active || contactsSearchController.active {
                    self.view.window!.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
                self.view.window!.rootViewController!.presentViewController(vc, animated: true, completion: nil)
                self.prompt.dismissPrompt()
                promptPhonesArray.removeAll(keepCapacity: false)
                promptEmailsArray.removeAll(keepCapacity: false)
            }
        }
    }
    
    func clickedOnTheSecondButton() {
        print("Clicked on the second button")
        prompt.dismissPrompt()
        phonesProfileArray.removeAll(keepCapacity: false)
        emailsProfileArray.removeAll(keepCapacity: false)
        promptPhonesArray.removeAll(keepCapacity: false)
        promptEmailsArray.removeAll(keepCapacity: false)
    }
    
    func promptWasDismissed() {
        print("Dismissed the prompt")
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let keyEntry = searchController.searchBar.text!
        var searchString: String! = ""
        if let spaceIndex = keyEntry.characters.indexOf(" ") {
            let lastName: String = keyEntry.substringToIndex(spaceIndex)
            let firstName: String = keyEntry.substringFromIndex(spaceIndex.successor())
            if firstName.characters.count > 0 && lastName.characters.count > 0 {
                searchString = firstName + " " + lastName
            } else if firstName.characters.count == 0 && lastName.characters.count > 0 {
                searchString = lastName
            } else if lastName.characters.count == 0 && firstName.characters.count > 0 {
                searchString = firstName
            }
        }
        
        if keyEntry == "" {
            //if GlobalVariables.sharedManager.sortOrdering == "alpha" {
                //People.people = realm.objects(HKPerson).sorted("fullName")
            //} else {
                //People.people = realm.objects(HKPerson).sorted("indexedOrder", ascending: true)
            //}
        }
        else if searchString == "" {
            print("searchstring one word")
            let indexSort = realm.objects(HKPerson).filter("firstName BEGINSWITH[c] '\(keyEntry)' OR lastName BEGINSWITH[c] '\(keyEntry)' OR fullName BEGINSWITH[c] '\(keyEntry)'").sorted("indexedOrder", ascending: true)
            let usage = indexSort.sorted("flUsageWeight", ascending: false)
            People.people = usage
        } else {
            let indexSort = realm.objects(HKPerson).filter("fullName BEGINSWITH[c] '\(keyEntry)' OR fullName BEGINSWITH[c] '\(searchString)' OR firstName BEGINSWITH[c] '\(searchString)' OR lastName BEGINSWITH[c] '\(searchString)' OR fullName == '\(keyEntry)' OR fullName == '\(searchString)'").sorted("indexedOrder", ascending: true)
            People.people = indexSort.sorted("flUsageWeight")
        }
        if masterTableView.hidden == false {
            masterTableView.reloadData()
        } else {
            masterCollectionView.reloadData()
        }
    }
}


