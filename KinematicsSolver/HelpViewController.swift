//
//  HelpViewController.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 9/2/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let color0 = UIColor.whiteColor().CGColor as CGColorRef
        let color1 = UIColor(red: 228/255.0, green: 237/255.0, blue: 240/255.0, alpha: 0.7).CGColor as CGColorRef
        let color2 = UIColor(red: 201/255.0, green: 230/255.0, blue: 240/255.0, alpha: 0.5).CGColor as CGColorRef
        gradientLayer.colors = [color0, color1, color2]
        gradientLayer.locations = nil //spread evenly
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        self.modalTransitionStyle = .FlipHorizontal
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
