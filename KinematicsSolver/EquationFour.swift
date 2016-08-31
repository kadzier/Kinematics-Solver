//
//  EquationFour.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

// This class represents the equation x = [(vi+vf)*t]/2
class EquationFour: NSObject {
    var x: Double?
    var vi: Double?
    var vf: Double?
    var t: Double?
    
    //equation takes a dictionary with exactly three key/value pairs
    //key: a string, either 'x' 'vi' 'vf' or 't'; value: the value
    //This equation is independent of 'a' and thus it should never be an input!
    init(givens: [String:Double]){
        let variables = givens.keys
        let variableSet = Set(variables)
        
        if variableSet.contains("a"){
            print("Error! Equation is independent of a!")
        }
        else{
            
            //one of these values will be nil; that's what we solve for below
            x = givens["x"]
            vi = givens["vi"]
            vf = givens["vf"]
            t = givens["t"]
            
            if !variableSet.contains("x"){ //we're solving for x
                x = ((vi! + vf!)*t!) / 2
            }
            else if !variableSet.contains("vi"){ //we're solving for vi
                vi = (2*x!)/t! - vf!
            }
            else if !variableSet.contains("vf"){ //we're solving for vf
                vf = (2*x!)/t! - vi!
            }
            else if !variableSet.contains("t"){ //we're solving for t
                t = (2*x!) / (vf! + vi!)
            }
            
        }
    }
}
