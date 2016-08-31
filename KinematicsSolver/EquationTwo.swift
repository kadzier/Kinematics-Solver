//
//  EquationTwo.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

//This class represents the equation: vf = vi + a*t 
class EquationTwo: NSObject {
    var vi: Double?
    var vf: Double?
    var a: Double?
    var t: Double?
    
    //equation takes a dictionary with exactly three key/value pairs
    //key: a string, either 'vi' 'vf' 'a' or 't'; value: the value
    //This equation is independent of 'x' and thus it should never be an input!
    init(givens: [String:Double]){
        let variables = givens.keys
        let variableSet = Set(variables)
        
        if variableSet.contains("x"){
            print("Error! Equation is independent of x!")
        }
        else{
            
            //one of these values will be nil; that's what we solve for below
            vi = givens["vi"]
            vf = givens["vf"]
            a = givens["a"]
            t = givens["t"]
            
            if !variableSet.contains("vi"){ //we're solving for vi
                vi = vf! - a!*t!
            }
            else if !variableSet.contains("vf"){ //we're solving for vf
                vf = vi! + a!*t!
            }
            else if !variableSet.contains("a"){ //we're solving for a
                a = (vf! - vi!)/t!
            }
            else if !variableSet.contains("t"){ //we're solving for t
                t = (vf! - vi!)/a!
            }
            
        }
    }
}
