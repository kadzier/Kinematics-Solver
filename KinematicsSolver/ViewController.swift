//
//  ViewController.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var viTextField: UITextField!
    @IBOutlet weak var vfTextField: UITextField!
    @IBOutlet weak var aTextField: UITextField!
    @IBOutlet weak var tTextField: UITextField!
    
    //textual representation of the entered values- empty string if empty 
    var xVal = ""
    var viVal = ""
    var vfVal = ""
    var aVal = ""
    var tVal = ""
    
    //solve/reset state.  Default is false; have not yet solved
    var solved: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        //text field delegates 
        xTextField.delegate = self
        viTextField.delegate = self
        vfTextField.delegate = self
        aTextField.delegate = self
        tTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: Solve/Reset
    
    @IBAction func solveResetPressed(sender: AnyObject) {
        
        //need to solve
        if !solved{
            //build up our values dict.
            var valuesDict: [String:Double] = [:]
            var valsArray: [String] = [xVal, viVal, vfVal, aVal, tVal]
            for i in 0..<valsArray.count{
                let val = valsArray[i]
                if val.characters.count > 0{
                    if i == 0{ //x
                        valuesDict["x"] = Double(xVal)
                    }
                    else if i == 1{ //vi
                        valuesDict["vi"] = Double(viVal)
                    }
                    else if i == 2{ //vf
                        valuesDict["vf"] = Double(vfVal)
                    }
                    else if i == 3{ //a
                        valuesDict["a"] = Double(aVal)
                    }
                    else if i == 4{ //t
                        valuesDict["t"] = Double(tVal)
                    }
                }
            }
            //must have exactly 3 values to solve
            if valuesDict.count == 3{
                let validString = EquationValidator.validateEquation(valuesDict)
                print(validString)
            }
        }
        //need to reset
        else{
        }
    }

    
    
    //MARK: Text field delegate
    //we want to disable editing if 3 fields are already filled and we're trying to edit the fourth and beyond
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        var emptyCount = 0
        let valuesArray: [String] = [xVal,viVal,vfVal,aVal,tVal]
        for value in valuesArray{
            if value.characters.count == 0{
                emptyCount += 1
            }
        }
        print(emptyCount)
        if emptyCount >= 3{ //still enough empty; editing is fine!
            return true
        }
        else{ //we've already filled up 3; don't let us edit a new one!
            if textField.text!.characters.count == 0{
                return false
            }
            else{ //this is an old one we're trying to edit
                return true
            }
        }
    }

    //set the entered values in the text field
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == xTextField{
            xVal = textField.text!
        }
        else if textField == viTextField{
            viVal = textField.text!
        }
        else if textField == vfTextField{
            vfVal = textField.text!
        }
        else if textField == aTextField{
            aVal = textField.text!
        }
        else if textField == tTextField{
            tVal = textField.text!
        }
    }
    
    //callbacks for when the text in the text field changes while editing
    @IBAction func xTextChanged(sender: UITextField) {
        xVal = sender.text!
    }
    @IBAction func viTextChanged(sender: UITextField) {
        viVal = sender.text!
    }
    @IBAction func vfTextChanged(sender: UITextField) {
        vfVal = sender.text!
    }
    @IBAction func aTextChanged(sender: UITextField) {
        aVal = sender.text!
    }
    @IBAction func tTextChanged(sender: UITextField) {
        tVal = sender.text!
    }
    
    
    
}

