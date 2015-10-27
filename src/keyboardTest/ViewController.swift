//
//  ViewController.swift
//  MMGooglePlayNewsStand
//
//  Created by mukesh mandora on 25/08/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//

import UIKit

class ViewController: UIViewController,MMPlayPageControllerDelegate {
let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var showDemoBut: UIButton!
    var navBar = UIView()
    var menuBut = UIButton()
    var searchBut = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initAddPlayViews()
        showDemoBut.tintColor=UIColor.whiteColor()
        showDemoBut.setImage(UIImage(named: "news")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        showDemoBut.backgroundColor=UIColor(hexString: "4caf50")
        showDemoBut.layer.cornerRadius=showDemoBut.frame.size.width/2
        
        //NavBut
        navBar.frame=CGRectMake(0, 0, self.view.frame.width, 64)
        navBar.backgroundColor=UIColor.clearColor()
        
        menuBut.frame = CGRectMake(20, 27 , 20, 20)
        menuBut.tintColor=UIColor.whiteColor()
        menuBut.setImage(UIImage(named: "KeyboardClose")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        menuBut.addTarget(self, action: "handleCloseBtn", forControlEvents: .TouchUpInside)
        
        searchBut.frame = CGRectMake(self.view.frame.width-40, 27 , 20, 20)
        searchBut.setImage(UIImage(named: "KeyboardSearch")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        searchBut.tintColor=UIColor.whiteColor()
        
        navBar.addSubview(menuBut)
        navBar.addSubview(searchBut)
        view.addSubview(navBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleCloseBtn() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func initAddPlayViews() {
        // Attach the pages to the master
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let page_zero = stb.instantiateViewControllerWithIdentifier("stand_one") as! MMSampleTableViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("stand_one") as! MMSampleTableViewController
        let page_two = stb.instantiateViewControllerWithIdentifier("stand_one")as! MMSampleTableViewController
        let page_three = stb.instantiateViewControllerWithIdentifier("stand_one") as! MMSampleTableViewController
        
        appDelegate.walkthrough?.delegate = self
        appDelegate.walkthrough?.addViewControllerWithTitleandColor(page_zero, title: "Photos", color: UIColor(hexString: "9c27b0"))
        appDelegate.walkthrough?.addViewControllerWithTitleandColor(page_one, title: "Videos", color:UIColor(hexString: "009688"))
        appDelegate.walkthrough?.addViewControllerWithTitleandColor(page_two, title: "Feeds", color:UIColor(hexString: "ff9800"))
        appDelegate.walkthrough?.addViewControllerWithTitleandColor(page_three, title: "Notes", color: UIColor(hexString: "03a9f4"))
        
        //header Color
        page_zero.tag=1
        page_one.tag=2
        page_two.tag=3
        page_three.tag=4
    }
    
    func initPlayStand(){
        self.presentViewController(appDelegate.walkthrough!, animated: true, completion: nil)
    }

    @IBAction func showDemoAction(sender: AnyObject) {
        
        initPlayStand()
    }
    
    
}

