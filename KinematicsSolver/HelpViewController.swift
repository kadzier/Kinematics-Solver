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
        gradientLayer.frame = UIScreen.main.bounds
        let color0 = UIColor.white.cgColor as CGColor
        let color1 = UIColor(red: 228/255.0, green: 237/255.0, blue: 240/255.0, alpha: 0.7).cgColor as CGColor
        let color2 = UIColor(red: 201/255.0, green: 230/255.0, blue: 240/255.0, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color0, color1, color2]
        gradientLayer.locations = nil //spread evenly
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.modalTransitionStyle = .flipHorizontal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func donePressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
