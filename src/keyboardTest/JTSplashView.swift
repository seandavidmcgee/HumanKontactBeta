//
//  JTSplashView.swift
//  JTSplashView Example
//
//  Created by Jakub Truhlar on 25.07.15.
//  Copyright (c) 2015 Jakub Truhlar. All rights reserved.
//

import UIKit
import Foundation
import LiquidLoader

class JTSplashView: UIView {
    
    // MARK: Properties
    static let sharedInstance = JTSplashView()
    static let screenSize = UIScreen.mainScreen().bounds.size
    static var image = UIImage(named: "splash")
    static let bgImage = image?.applyDarkEffect()
    static let BitmapOverlay = UIImage(named: "BitmapOverlayBG")
    static let circleBG = UIColor(red: 77 / 255.0, green: 255 / 255.0, blue: 182 / 255.0, alpha: 1.0)
    static let line = UIColor(red: 77 / 255.0, green: 255 / 255.0, blue: 182 / 255.0, alpha: 1.0)
    
    let duration = 0.3
    let borderWidth : CGFloat = 10.0
    
    var lineColor = line
    var bgImageView = bgImage
    var bgColor = UIColor(patternImage: bgImage!)
    var circleColor = circleBG
    var vibrateAgain = true
    var completionBlock:(() -> Void)?
    
    //var circlePathInitial = UIBezierPath(ovalInRect: CGRect(x: screenSize.width / 2, y: screenSize.height / 2, width: 0.0, height: 0.0))
    //var circlePathFinal = UIBezierPath(ovalInRect: CGRect(x: (screenSize.width / 2) - 35.0, y: (screenSize.height / 2) - 35.0, width: 70.0, height: 70.0))
    //var circlePathShrinked = UIBezierPath(ovalInRect: CGRect(x: screenSize.width / 2 - 5.0, y: screenSize.height / 2 - 5.0, width: 10.0, height: 10.0))
    //var circlePathSqueezeVertical = UIBezierPath(ovalInRect: CGRect(x: (screenSize.width / 2) - 34.0, y: (screenSize.height / 2) - 36.0, width: 68.0, height: 72.0))
    //var circlePathSqueezeHorizontal = UIBezierPath(ovalInRect: CGRect(x: (screenSize.width / 2) - 36.0, y: (screenSize.height / 2) - 34.0, width: 72.0, height: 68.0))
    
    var baseCircleLayer = CAShapeLayer()
    var bgWithoutMask = UIView()
    var lineLoader: LiquidLoader? = nil
    
    // MARK: Initializers
    init() {
        super.init(frame:CGRectZero)
        self.alpha = 0.0
        UIApplication.sharedApplication().delegate?.window??.makeKeyAndVisible()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        doInit()
    }
    
    func doInit() {
        // 1x with mask and above 1x without mask BG
        bgWithoutMask = createBackgroundWithMask(nil)
        let lineLoaderOverBG = createBaseLineLoader()
        
        addSubview(bgWithoutMask)
        addSubview(lineLoaderOverBG)
        //createBaseCircle()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("addToWindow"), name: UIWindowDidBecomeVisibleNotification, object: nil)
    }
    
    /**
    Class function to create the splash view.
    
    This function takes three optional arguments and generate splash view above everything in keyWindow. StatusBar is hidden during the process, so you should make it visible in finish function block.
    
    :param:  backgroundColor Background color of the splash view. Default is asphalt color.
    :param:  circleColor Color of the animated circle. Default is blue color.
    :param:  circleSize Size of the animated circle. 10pt border will be added, but the size remains the same. Width should be same as height. Default is CGSize(70, 70).
    */
    class func splashViewWithBackgroundColor(backgroundColor: UIColor?, lineColor: UIColor?) {
        
        if isVisible() {
            return
        }
        
        sharedInstance.alpha = 1.0
        
        // Redefine properties
        if (backgroundColor != nil) {
            sharedInstance.bgColor = backgroundColor!
        }
        
        if (lineColor != nil) {
            sharedInstance.lineColor = lineColor!
        }
        
        sharedInstance.doInit()
    }
    
    // MARK: Public functions
    
    /**
    Class function to hide the splash view.
    
    This function hide the splash view. Should be called in the right time after the app is ready.
    */
    class func finish() {
        finishWithCompletion(nil)
    }
    
    /**
    Class function to hide the splash view with completion handler.
    
    This function hide the splash view and call the completion block afterward. Should be called in the right time after the app is ready.
    
    :param: completion The completion block
    */
    class func finishWithCompletion(completion: (() -> Void)?) {
        
        if !isVisible() {
            return
        }
        
        if (completion != nil) {
            sharedInstance.completionBlock = completion
        }
    }
    
    /**
    Class function obtains the splashView visibility state.
    
    This function will tell you if the splashView is visible or not.
    
    :returns: Bool Tells us if is the splashView visible.
    */
    class func isVisible() -> Bool {
        return (sharedInstance.alpha != 0.0)
    }
    
    // MARK: Private functions
    @objc private func addToWindow() {
        UIApplication.sharedApplication().keyWindow?.addSubview(JTSplashView.sharedInstance)
        NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("finalAnimation"), userInfo: nil, repeats: false)
    }
    
    @objc private func finalAnimation() {
        NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("fadeOut"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("zoomIn"), userInfo: nil, repeats: false)
    }
    
    private func createBaseLineLoader() -> LiquidLoader {
        let lineFrame = CGRect(x: UIScreen.mainScreen().bounds.size.width * 0.5 - 100, y: UIScreen.mainScreen().bounds.size.height * 0.5 - 50, width: 200, height: 100)
        lineLoader = LiquidLoader(frame: lineFrame, effect: .GrowLine(lineColor))
        return lineLoader!
    }
    
    private func createBackgroundWithMask(mask: CAShapeLayer?) -> UIView {
        let backgroundView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        let bgView = UIImageView()
        bgView.frame = backgroundView.frame
        bgView.contentMode = .ScaleToFill
        bgView.clipsToBounds = true
        bgView.image = bgImageView
        backgroundView.addSubview(bgView)
        backgroundView.userInteractionEnabled = false
        
        return backgroundView
    }
    
    // Animations
    @objc private func zoomIn() {
        UIView.animateWithDuration(NSTimeInterval(self.duration * 0.5), delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            // The rest of the transformation will not be visible due completion block alpha = 0 part. But it will look like it just continued faster
            let cornerCorrection : CGFloat = 1.25
            let multiplier = (JTSplashView.screenSize.height / self.borderWidth) * cornerCorrection
            
            self.bgWithoutMask.transform = CGAffineTransformMakeScale(multiplier, multiplier)
            self.bgWithoutMask.center = CGPointMake(JTSplashView.screenSize.width / 2, JTSplashView.screenSize.height / 2)
            
            }) { (Bool) -> Void in
                
                // Run optional block if exists
                if (self.completionBlock != nil) {
                    self.completionBlock!()
                }
                
                self.bgWithoutMask.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.bgWithoutMask.center = CGPointMake(JTSplashView.screenSize.width / 2, JTSplashView.screenSize.height / 2)
        }
    }
    
    @objc private func fadeOut() {
        self.bgWithoutMask.alpha = 0.0
        lineLoader?.removeFromSuperview()
        lineLoader = nil
    }
}