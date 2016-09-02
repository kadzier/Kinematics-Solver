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

    @IBOutlet weak var initialLabel: UILabel!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.displaySolutionLabels()
    }
    
    func displaySolutionLabels(){
        
        //one-half in unicode: \u{00B9}\u{2044}\u{2082}
        //squared in unicode: \u{00B2}
        //fraction sign in unicode: \u{2044}
        //square root sign unicode: \u{221A}
        //plus or minus unicode: \u{207A}\u{2044}-
        
        //first equation
        //3, 4, 6, 7, 8, 16 cannot currently be the first equation (always paired second with something else when object is created)
        let equation1 = equationIndices[0]
        //header label
        var headerText = ""
        switch equation1 {
        case 1:
            headerText = "We are given initial velocity, acceleration, and time.  To solve for displacement, we use the equation: \n"
            headerText += "x = Vi*t + \u{00B9}\u{2044}\u{2082}*a*t\u{00B2}"
        case 2:
            headerText = "We are given displacement, acceleration, and time.  To solve for initial velocity, we start with the equation: \n"
            headerText += "x = Vi*t + \u{00B9}\u{2044}\u{2082}*a*t\u{00B2}"
            headerText += "\n Solving the equation for Vi, we end up with: \n"
            headerText += "Vi = x\u{2044}t - \u{00B9}\u{2044}\u{2082}*a*t"
        case 5:
            headerText = "We are given final velocity, acceleration, and time.  To solve for initial velocity, we start with the equation: \n"
            headerText += "Vf = Vi + a*t \n"
            headerText += "Solving the equation for Vi, we end up with: \n"
            headerText += "Vi = Vf - a*t"
        case 9:
            headerText = "We are given the initial velocity, final velocity, and acceleration.  To solve for displacement, we start with the equation: \n"
            headerText += "Vf\u{00B2} = Vi\u{00B2} + 2*a*x \n"
            headerText += "Solving the equation for x, we end up with: \n"
            headerText += "x = (Vf\u{00B2} - Vi\u{00B2}) \u{2044} (2a)"
        case 10:
            headerText = "We are given the displacement, final velocity, and acceleration.  To solve for initial velocity, we start with the equation: \n"
            headerText += "Vf\u{00B2} = Vi\u{00B2} + 2*a*x \n"
            headerText += "Solving the equation for Vi, we end up with: \n"
            headerText += "Vi = \u{207A}\u{2044}- \u{221A}[Vf\u{00B2} - 2*a*x]"
        default:
            return
        }
        self.initialLabel.text = headerText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
