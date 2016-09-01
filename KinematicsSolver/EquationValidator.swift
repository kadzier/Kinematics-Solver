//
//  EquationValidator.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

//Extension for Set that adds the capability to test membership for an array of strings 
//Input is an array of Strings.  Returns true iff ALL strings in input are in set.
extension Set{
    func containsStrings(array: [String]) -> Bool{
        for item in array{
            if !self.contains(item as! Element){
                return false
            }
        }
        return true
    }
}

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
        
        //equation 2- invalid a.  OK if vi = vf; because then equation will just return a = 0.
        else if variableSet.contains("vi") && variableSet.contains("vf") && variableSet.contains("t"){
            //t = 0 and vi =/= vf infinite acceleration required
            if dict["t"] == 0 && (dict["vi"] != dict["vf"]){
                return "Undefined solution!  Acceleration must be infinite in magnitude to satisfy the constraints."
            }
        }
        
        //equaiton 2 or 3- invalid t or x
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
        
        //equation 3 or 4- invalid a or t
        else if variableSet.contains("x") && variableSet.contains("vi") && variableSet.contains("vf"){
            //x = 0 - either impossible situation or vi = vf (then a = 0)
            if dict["x"] == 0{
                if !(dict["vi"] == dict["vf"]){
                    return "Undefined solution!  Acceleration must be infinite in magnitude to satisfy these constraints."
                }
            }
            else if dict["vi"]! == -dict["vf"]!{ //vi = -vf- either x = 0 or t must be infinite
                if dict["x"] == 0{
                    return "Ambiguous solution!  Because vi = -vf and x = 0, time can be any value."
                }
                else{
                    return "Undefined solution!  Time must be infinite in magnitude to satisfy the constraints."
                }
            }
        }
        return "valid"
    }
    
    //Use the equation classes to solve for the unknowns 
    //Input is a dictionary with exactly three key/value pairs where the keys are unique strings x, vi, vf, a, or t
    //Output is another dictionary with key/value pairs for the remaining variables; the answers might have the keys vi2, vf2 or t2 for situations with multiple roots
    class func solveForUnknowns(varsDict: [String:Double]) -> [String: Double] {
        
        let variables = varsDict.keys
        let variableSet = Set(variables)
        
        var answerDict: [String: Double] = [:]
        
        var eqn1: EquationOne?
        var eqn2: EquationTwo?
        var eqn3: EquationThree?
        var eqn4: EquationFour?
        
        //equation 1 is independent of vf
        if !variableSet.contains("vf"){
            eqn1 = EquationOne(givens: varsDict)
        }
        //equation 2 is independent of x
        if !variableSet.contains("x"){
            eqn2 = EquationTwo(givens: varsDict)
        }
        //equation 3 is independent of t
        if !variableSet.contains("t"){
            eqn3 = EquationThree(givens: varsDict)
        }
        //equation 4 is independent of a
        if !variableSet.contains("a"){
            eqn4 = EquationFour(givens: varsDict)
        }
        
        //x, vi, vf
        //use 3, 4 to solve for a, t
        if variableSet.containsStrings(["x", "vi", "vf"]){
            answerDict["a"] = eqn3!.a!
            answerDict["t"] = eqn4!.t!
        }
        
        //x, vi, a
        //use 3, 1 to solve for vf, t
        else if variableSet.containsStrings(["x", "vi", "a"]){
            answerDict["vf"] = eqn3!.vf!
            answerDict["vf2"] = eqn3!.vf2!
            answerDict["t"] = eqn1!.t!
            answerDict["t2"] = eqn1!.t2!
        }
        
        //x, vi, t
        //use 4, 1 to solve for vf, a
        else if variableSet.containsStrings(["x", "vi", "t"]){
            answerDict["vf"] = eqn4!.vf!
            answerDict["a"] = eqn1!.t!
        }
        
        //x, vf, a
        //use 3 to solve for vi
        else if variableSet.containsStrings(["x", "vf", "a"]){
            answerDict["vi"] = eqn3!.vi!
            answerDict["vi2"] = eqn3!.vi2!
        }
        
        //x, vf, t
        //use 4 to solve for vi
        else if variableSet.containsStrings(["x", "vf", "t"]){
            answerDict["vi"] = eqn4!.vi!
        }
        
        //x, a, t
        //use 1 to solve for vi
        else if variableSet.containsStrings(["x", "a", "t"]){
            answerDict["vi"] = eqn1!.vi!
        }
        
        //vi, vf, a
        //use 3 and 2 to solve for x and t
        else if variableSet.containsStrings(["vi", "vf", "a"]){
            answerDict["x"] = eqn3!.x!
            answerDict["t"] = eqn2!.t!
        }
        
        //vi, vf, t
        //use 4 and 2 to solve for x and a
        else if variableSet.containsStrings(["vi", "vf", "t"]){
            answerDict["x"] = eqn4!.x!
            answerDict["a"] = eqn2!.a!
        }
        
        //vi, a, t
        //use 1 and 2 to solve for x and vf
        else if variableSet.containsStrings(["vi", "a", "t"]){
            answerDict["x"] = eqn1!.x!
            answerDict["vf"] = eqn2!.a!
        }
        
        //vf, a, t
        //use 2 to solve for vi
        else if variableSet.containsStrings(["vf", "a", "t"]){
            answerDict["vi"] = eqn2!.vi!
        }
        
        print(answerDict)
        return answerDict
    }
}
