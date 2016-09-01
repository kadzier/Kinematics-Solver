//
//  EquationValidator.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

//This class contains class functions to assist in validating equations 
class EquationValidator: NSObject {

    //either returns "valid" if equation can be solved, or the specific error message if not
    //precondition: dict has EXACTLY three unique keys, taken from the strings x, vi, vf, a, or t
    class func validateEquation(dict: [String:Double]) -> String{
        let keys = dict.keys
        let variableSet = Set(keys)
        
        //can be solved by equation 1 only, for vi
        if variableSet.contains("x") && variableSet.contains("a") && variableSet.contains("t"){
            
            //invalid: either ambiguous vi or vi = infinity
            if dict["t"] == 0{
                if dict["x"] == 0{
                    return "Ambiguous solution! Because x and t = 0, initial velocity can be any value."
                }
                else{
                    return "Undefined solution! Initial velocity must be infinite in magnitude to satisfy the constraints."
                }
            }
        }
        
        //can be solved by equation 3 only, for vi
        else if variableSet.contains("x") && variableSet.contains("vf") && variableSet.contains("a"){
            let discriminant = dict["vf"]!*dict["vf"]! - 2*dict["a"]!*dict["x"]!
            //invalid: imaginary roots
            if discriminant < 0{
                return "Invalid solution!  Final velocity has imaginary roots, describing a non-physical situation.  Either re-check your assumptions or re-check for sign errors!"
            }
        }
        
        //can be solved by equation 4 only, for vi
        else if variableSet.contains("x") && variableSet.contains("vf") && variableSet.contains("t"){
            if dict["t"] == 0{
                if dict["x"] == 0{
                    return "Ambiguous solution! Because x and t = 0, initial velocity can be any value."
                }
                else{
                    return "Undefined solution! Initial velocity must be infinite in magnitude to satisfy the constraints."
                }
            }
        }
        
        //equation 1 or 4- invalid a and vf
        else if variableSet.contains("x") && variableSet.contains("vi") && variableSet.contains("t"){
            if dict["t"] == 0{
                if dict["x"] == 0{
                    return "Ambiguous solution! Because x and t = 0, acceleration and final velocity can be any value."
                }
                else{
                    return "Undefined solution! Acceleration must be infinite in magnitude to satisfy the constraints."
                }
            }
        }
        
        //equation 1 or 3- either imaginary roots or both vi and a are 0 -- invalid t and vf. (JUST a being 0 is okay because then it's x=vt)
        else if variableSet.contains("x") && variableSet.contains("vi") && variableSet.contains("a"){
            let discriminant = dict["vi"]!*dict["vi"]! + 2*dict["a"]!*dict["x"]!
            //invalid: imaginary roots
            if discriminant < 0{
                return "Invalid solution!  Final velocity has imaginary roots, describing a non-physical situation.  Either re-check your assumptions or re-check for sign errors!"
            }
            else{
                if dict["vi"] == 0 {
                    if dict["a"] == 0{
                        if dict["x"] == 0{ //degenerate case- all three are 0
                            return "Degenerate solution!  Final velocity = 0 but time can be any value."
                        }
                        else{ //ambiguous case- x has a magnitude but vi and a are 0
                            return "Ambiguous solution! Because vi and a = 0, time can be any value and final velocity is undefined."
                        }
                    }
                }
            }
        }
        
        //equation 2 invalid a
        else if variableSet.contains("vi") && variableSet.contains("vf") && variableSet.contains("t"){
            //t = 0 - infinite acceleration required
            if dict["t"] == 0{
                return "Undefined solution!  Acceleration must be infinite in magnitude to satisfy the constraints."
            }
        }
        
        //equaiton 2 invalid t
        else if variableSet.contains("vi") && variableSet.contains("vf") && variableSet.contains("a"){
            //a = 0 - either impossible situation or vf = vi
            if dict["a"] == 0{
                if dict["vf"] == dict["vi"]{
                    return "Ambiguous solution! Because vi = vf and a = 0, time and displacement can be any value."
                }
                else{
                    return "Invalid solution!  Because acceleration = 0, velocity is not changing and this describes a non-physical situation.  Consider re-checking your assumptions!"
                }
            }
        }
        return "valid"
    }
}
