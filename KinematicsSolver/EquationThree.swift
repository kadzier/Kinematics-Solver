//
//  EquationThree.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

// This class represents the equation: vf^2 = vi^2 + 2*a*x
class EquationThree: NSObject {
    var x: Double?
    var vi: Double?
    var vi2: Double? //if we have two roots, this is the second
    var vf: Double?
    var vf2: Double? //if we have two roots, this is the second
    var a: Double?
    
    //equation takes a dictionary with exactly three key/value pairs
    //key: a string, either 'x' 'vi' 'vf' or 'a'; value: the value
    //This equation is independent of 't' and thus it should never be an input!
    init(givens: [String:Double]){
        let variables = givens.keys
        let variableSet = Set(variables)
        
        if variableSet.contains("t"){
            print("Error! Equation is independent of t!")
        }
        else{
            
            //one of these values will be nil; that's what we solve for below
            x = givens["x"]
            vi = givens["vi"]
            vf = givens["vf"]
            a = givens["a"]
            
            if !variableSet.contains("x"){ //we're solving for x
                x = (vf!*vf! - vi!*vi!)/(2*a!)
            }
            else if !variableSet.contains("vi"){ //we're solving for vi
                vi = sqrt( vf!*vf! - 2*a!*x! )
                vi2 = -sqrt( vf!*vf! - 2*a!*x! )
            }
            else if !variableSet.contains("vf"){ //we're solving for vf
                vf = sqrt( vi!*vi! + 2*a!*x! )
                vf2 = -sqrt( vi!*vi! + 2*a!*x! )
            }
            else if !variableSet.contains("a"){ //we're solving for a
                a = (vf!*vf! - vi!*vi!) / (2*x!)
            }
            
        }
    }
}
