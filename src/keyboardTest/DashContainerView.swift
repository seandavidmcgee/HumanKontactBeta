//
//  DashContainerView.swift
//  keyboardTest
//
//  Created by Sean McGee on 8/26/15.
//  Copyright (c) 2015 Kannuu. All rights reserved.
//

import UIKit

class DashContainerView: UIViewController {
    var dashArray = Array<UIButton!>()
    var socialArray = Array<UIImage!>()
    let facebook = UIImage(named: "facebookDash")
    let twitter = UIImage(named: "twitterDash")
    let pinterest = UIImage(named: "pinterestDash")
    var socialXFirst: CGFloat = 62
    var dashBadgeStrings: Array<String> = ["12", "8", "20"]
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-85)
        let lightBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: lightBlur)
        blurView.frame = profilePicture.bounds
        
        let profileImage = UIImage(named: "profile")!
        profilePicture.contentMode = .ScaleToFill
        profilePicture.clipsToBounds = true
        profilePicture.image = profileImage
        profilePicture.addSubview(blurView)
        let dashProfile = UIImageView(frame: CGRect(x: 0, y: 0, width: profilePicture.frame.height, height: profilePicture.frame.height))
        dashProfile.clipsToBounds = true
        dashProfile.image = profileImage
        
        self.view.addSubview(dashProfile)
        
        //Social Icons + Badging//
        socialArray = [facebook, twitter, pinterest]
        var socialIndex: Int = 0
        for image in socialArray {
            let socialButton: MIBadgeButton! = MIBadgeButton(frame: CGRectMake(socialXFirst, 7, 28, 28))
            socialXFirst = socialXFirst + 52
            let insets = UIEdgeInsetsMake(10, 0, 0, 5)
            socialButton.setBackgroundImage(image, forState: UIControlState.Normal)
            socialButton.badgeString = dashBadgeStrings[socialIndex]
            socialButton.badgeEdgeInsets = insets
            dashArray.append(socialButton)
            
            self.view.addSubview(socialButton)
            socialIndex++
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

