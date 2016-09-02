//
//  ShowWorkViewController.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 9/2/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

//This class is the view controller for the "show your work" section.
class ShowWorkViewController: UIViewController {

    //We will encode each of the 16 kinematics equations for a particular variable with a number.  The equationIndices array contains either 1 or 2 numbers, depending on the variables we solved for.
    
    //1-4: x = vi*t + 1/2*a*t^2
    //1: x
    //2: vi
    //3: a
    //4: t
    
    //5-8: vf = vi + a*t
    //5: vi
    //6: vf
    //7: a
    //8: t
    
    //9-12: vf^2 = vi^2 + 2*a*x
    //9: x
    //10: vi
    //11: vf
    //12: a
    
    //13-16: x = (vi + vf)/2 * t
    //13: x
    //14: vi
    //15: vf
    //16: t
    var equationIndices: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalTransitionStyle = .FlipHorizontal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
