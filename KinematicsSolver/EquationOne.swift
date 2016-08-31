//
//  EquationOne.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

// This class reqpresents the equation: x = vi*t + 1/2*a*t^2
class EquationOne: NSObject {

    var x: Double?
    var vi: Double?
    var a: Double?
    var t: Double?
    var t2: Double? //if we have two roots for time, this is the second
    
    //equation takes a dictionary with exactly three key/value pairs
    //key: a string, either 'x' 'vi' 'a' or 't'; value: the value
    //This equation is independent of 'vf' and thus it should never be an input!
    init(givens: [String:Double]){
        let variables = givens.keys
        let variableSet = Set(variables)
        
        if variableSet.contains("vf"){
            print("Error! Equation is independent of vf!")
        }
        else{
            
            //one of these values will be nil; that's what we solve for below
            x = givens["x"]
            vi = givens["vi"]
            a = givens["a"]
            t = givens["t"]
            
            if !variableSet.contains("x"){ //we're solving for x
                x = vi!*t! + 0.5*a!*t!*t!
            }
            else if !variableSet.contains("vi"){ //we're solving for vi
                vi = x!/t! - 0.5*a!*t!
            }
            else if !variableSet.contains("a"){ //we're solving for a
                a = (2*x!)/(t!*t!) - 2*vi!/t!
            }
            else if !variableSet.contains("t"){ //we're solving for t
                t = -vi!/a! + sqrt( (4*vi!*vi!)/(a!*a!) + 8*x!/a! ) / 2.0
                t2 = -vi!/a! - sqrt( (4*vi!*vi!)/(a!*a!) + 8*x!/a! ) / 2.0
            }
            
        }
    }
}
