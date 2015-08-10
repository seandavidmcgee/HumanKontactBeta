//
//  DashboardBarViewController.swift
//  keyboardTest
//
//  Created by Sean McGee on 5/29/15.
//  Copyright (c) 2015 3 Callistos Services. All rights reserved.
//

import UIKit

class DashboardBarViewController: UIViewController {
    var dashArray = Array<UIButton!>()
    var socialArray = Array<UIImage!>()
    let facebook = UIImage(named: "facebookDash")
    let twitter = UIImage(named: "twitterDash")
    let pinterest = UIImage(named: "pinterestDash")
    var socialXFirst: CGFloat = 62
    var dashBadgeStrings: Array<String> = ["12", "8", "20"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var profileImage = UIImage(named: "profile")
        var dashBG = UIImageView(frame: CGRectMake(0, view.frame.height - 103, view.frame.width, 42 ))
        dashBG.backgroundColor = UIColor.blackColor()
        dashBG.image = profileImage?.blurredImageWithRadius(14, iterations: 20, tintColor: UIColor.clearColor())
        dashBG.contentMode = UIViewContentMode.ScaleAspectFill
        dashBG.clipsToBounds = true
        self.view = dashBG
        var dashProfile = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height))
        dashProfile.image = profileImage
        
        //Social Icons + Badging//
        socialArray = [facebook, twitter, pinterest]
        var socialIndex: Int = 0
        var y: CGFloat = (62 - view.frame.height) / 3.0
        for image in socialArray {
            let socialButton: MIBadgeButton! = MIBadgeButton(frame: CGRectMake(socialXFirst, y, 28, 28))
            socialXFirst = socialXFirst + 52
            let insets = UIEdgeInsetsMake(10, 0, 0, 5)
            socialButton.setBackgroundImage(image, forState: UIControlState.Normal)
            socialButton.badgeString = dashBadgeStrings[socialIndex]
            socialButton.badgeEdgeInsets = insets
            dashArray.append(socialButton)
            socialButton.addTarget(self, action: "dashPressed:", forControlEvents: UIControlEvents.TouchDown)
            
            self.view.addSubview(socialButton)
            socialIndex++
        }
        self.view.addSubview(dashProfile)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
