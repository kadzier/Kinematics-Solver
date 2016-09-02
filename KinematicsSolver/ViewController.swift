//
//  ViewController.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit

enum Units{
    case SI
    case Eng1
    case Eng2
}

class ViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var displacementLabel: UILabel!
    @IBOutlet weak var initVelLabel: UILabel!
    @IBOutlet weak var finalVelLabel: UILabel!
    @IBOutlet weak var accelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var viTextField: UITextField!
    @IBOutlet weak var vfTextField: UITextField!
    @IBOutlet weak var aTextField: UITextField!
    @IBOutlet weak var tTextField: UITextField!
    
    @IBOutlet weak var showFullX: UIButton!
    @IBOutlet weak var showFullVi: UIButton!
    @IBOutlet weak var showFullVf: UIButton!
    @IBOutlet weak var showFullA: UIButton!
    @IBOutlet weak var showFullT: UIButton!
    
    //defaut to SI units
    var units: Units = .SI
    
    let maxChars = 16 //"cutoff" point for chars in text field
    
    
    //textual representation of the entered values- empty string if empty 
    var xVal = ""
    var viVal = ""
    var vi2Val = ""
    var vfVal = ""
    var vf2Val = ""
    var aVal = ""
    var tVal = ""
    var t2Val = ""
    
    //solve/reset state.  Default is false; have not yet solved
    var solved: Bool = false
    
    //show work button
    @IBOutlet weak var showWorkButton: UIButton!
    
    //MARK: View lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let color0 = UIColor.whiteColor().CGColor as CGColorRef
        let color1 = UIColor.groupTableViewBackgroundColor().CGColor as CGColorRef
        let color2 = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor as CGColorRef
        gradientLayer.colors = [color0, color1, color2]
        gradientLayer.locations = nil //spread evenly
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        //superscript on acceleration
        self.accelLabel.text = "Acceleration (m/s\u{00B2})"
        
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
        
        //show full buttons
        self.showFullX.hidden = true
        self.showFullVi.hidden = true
        self.showFullVf.hidden = true
        self.showFullA.hidden = true
        self.showFullT.hidden = true
        
        //show work button
        self.showWorkButton.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: Present alert controller with message
    func presentAlertWithMessage(title title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Solve/Reset
    
    @IBAction func solveResetPressed(sender: AnyObject) {
        
        let button = sender as! UIButton
        
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
            //must have exactly 3 valid input values to solve
            if valuesDict.count == 3{
                
                //validate inputs to see if we'll have a valid solution
                let validString = EquationValidator.validateEquation(valuesDict)
                if validString != "valid"{ //invalid solution, display specific error
                    self.presentAlertWithMessage(title: "Error", message: validString)
                }
                else{ //we have a valid solution! Time to solve
                    solved = true
                    button.setTitle("Reset", forState: .Normal)
                    self.showWorkButton.hidden = false
                    let solutionValues = EquationValidator.solveForUnknowns(valuesDict)
                    self.fillInValues(solutionValues)
                }
            }
            else{
                self.presentAlertWithMessage(title: "Whoops!", message: "Please enter 3 valid values.")
            }
        }
        //need to reset
        else{
            solved = false
            button.setTitle("Solve!", forState: .Normal)
            self.showWorkButton.hidden = true
            self.resetValues()
        }
    }

    //MARK: Show work
    
    @IBAction func showWorkPressed(sender: AnyObject) {
    }
    
    //MARK: Change units
    @IBAction func changeUnitsPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Choose Units", preferredStyle: .ActionSheet)
        let siAction = UIAlertAction(title: "SI (meters, seconds)", style: .Default) { (action) in
            self.displacementLabel.text = "Displacement (m)"
            self.initVelLabel.text = "Initial Velocity (m/s)"
            self.finalVelLabel.text = "Final Velocity (m/s)"
            self.accelLabel.text = "Acceleration (m/s\u{00B2})"
            self.timeLabel.text = "Time (s)"
            
            self.switchToSIUnits()
        }
        let eng1Action = UIAlertAction(title: "English (feet, seconds)", style: .Default) { (action) in
            self.displacementLabel.text = "Displacement (ft)"
            self.initVelLabel.text = "Initial Velocity (ft/s)"
            self.finalVelLabel.text = "Final Velocity (ft/s)"
            self.accelLabel.text = "Acceleration (ft/s\u{00B2})"
            self.timeLabel.text = "Time (s)"
            
            self.switchToEngUnits1()
        }
        let eng2Action = UIAlertAction(title: "English (miles, hours)", style: .Default) { (action) in
            self.displacementLabel.text = "Displacement (mi)"
            self.initVelLabel.text = "Initial Velocity (mi/hr)"
            self.finalVelLabel.text = "Final Velocity (mi/hr)"
            self.accelLabel.text = "Acceleration (mi/hr\u{00B2})"
            self.timeLabel.text = "Time (hr)"
            
            self.switchToEngUnits2()
        }
        alertController.addAction(siAction)
        alertController.addAction(eng1Action)
        alertController.addAction(eng2Action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func switchToSIUnits(){
        let currentUnits = self.units
        //if already SI, do nothing
        if currentUnits == .SI{
            return
        }
        //eng1 to SI
        else if currentUnits == .Eng1{
            //feet to meters
            let feetMeterFactor = 0.3048
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal] //the values affected by this conversion
            for stringValue in valsArray{
                //if value isn't blank, convert and fill in
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    doubleValue *= feetMeterFactor
                    let finalDoubleValue = self.roundToThreePlaces(doubleValue)
                    let finalDoubleString = String(finalDoubleValue)
                    let index = valsArray.indexOf(stringValue)!
                    
                    switch index{
                    case 0:
                        self.xVal = finalDoubleString
                    case 1:
                        self.viVal = finalDoubleString
                    case 2:
                        self.vi2Val = finalDoubleString
                    case 3:
                        self.vfVal = finalDoubleString
                    case 4:
                        self.vf2Val = finalDoubleString
                    case 5:
                        self.aVal = finalDoubleString
                    default:
                        return
                    }
                }
            }
            
            
        }
        //eng2 to SI
        else if currentUnits == .Eng2{
            
        }
        self.units = .SI
        self.updateTextFieldValues()
    }
    func switchToEngUnits1(){
        self.units = .Eng1
    }
    func switchToEngUnits2(){
        self.units = .Eng2
    }
    
    //MARK: Help
    @IBAction func helpPressed(sender: AnyObject) {
    }
    
    
    //MARK: Text field delegate
    //we want to disable editing if we're in the "reset" state
    //we want to disable editing if 3 fields are already filled and we're trying to edit the fourth and beyond
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if solved == true{
            return false
        }
        else{
            var emptyCount = 0
            let valuesArray: [String] = [xVal,viVal,vfVal,aVal,tVal]
            for value in valuesArray{
                if value.characters.count == 0{
                    emptyCount += 1
                }
            }
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
    
    //when we've solved the equation, this updates the values variables.  We also handle rounding here.
    func fillInValues(valuesDict: [String:Double]){
        
        //get rid of clear buttons
        xTextField.clearButtonMode = .Never
        viTextField.clearButtonMode = .Never
        vfTextField.clearButtonMode = .Never
        aTextField.clearButtonMode = .Never
        tTextField.clearButtonMode = .Never
        
        if valuesDict["x"] != nil{
            let x = roundToThreePlaces(valuesDict["x"]!)
            xVal = String(x)
        }
        if valuesDict["vi"] != nil{
            let vi = roundToThreePlaces(valuesDict["vi"]!)
            viVal = String(vi)
            if valuesDict["vi2"] != nil{
                let vi2 = roundToThreePlaces(valuesDict["vi2"]!)
                vi2Val = String(vi2)
            }
        }
        if valuesDict["vf"] != nil{
            let vf = roundToThreePlaces(valuesDict["vf"]!)
            vfVal = String(vf)
            if valuesDict["vf2"] != nil{
                let vf2 = roundToThreePlaces(valuesDict["vf2"]!)
                vf2Val = String(vf2)
            }
        }
        if valuesDict["a"] != nil{
            let a = roundToThreePlaces(valuesDict["a"]!)
            aVal = String(a)
        }
        if valuesDict["t"] != nil{
            let t = roundToThreePlaces(valuesDict["t"]!)
            tVal = String(t)
            if valuesDict["t2"] != nil{
                let t2 = roundToThreePlaces(valuesDict["t2"]!)
                t2Val = String(t2)
            }
        }
        
        self.updateTextFieldValues()
    }
    //helper function to round to three places
    func roundToThreePlaces(num: Double) -> Double{
        return Double(round(1000*num)/1000)
    }
    //when we've updated our values variables, this updates the text field values.  Also handle display of the "show full" buttons.
    func updateTextFieldValues(){
        xTextField.text = xVal
        if xTextField.text?.characters.count > maxChars{
            showFullX.hidden = false
        }
        viTextField.text = viVal
        if vi2Val != ""{
            viTextField.text = viTextField.text! + " or " + vi2Val
        }
        if viTextField.text?.characters.count > maxChars{
            showFullVi.hidden = false
        }
        vfTextField.text = vfVal
        if vf2Val != ""{
            vfTextField.text = vfTextField.text! + " or " + vf2Val
        }
        if vfTextField.text?.characters.count > maxChars{
            showFullVf.hidden = false
        }
        aTextField.text = aVal
        if aTextField.text?.characters.count > maxChars{
            showFullA.hidden = false
        }
        tTextField.text = tVal
        if t2Val != ""{
            tTextField.text = tTextField.text! + " or " + t2Val
        }
        if tTextField.text?.characters.count > maxChars{
            showFullT.hidden = false
        }
    }
    //showing full values
    @IBAction func showFullXPressed(sender: AnyObject) {
        self.presentAlertWithMessage(title: "Displacement", message: xTextField.text!)
    }
    @IBAction func showFullViPressed(sender: AnyObject) {
        self.presentAlertWithMessage(title: "Initial Velocity", message: viTextField.text!)
    }
    @IBAction func showFullVfPressed(sender: AnyObject) {
        self.presentAlertWithMessage(title: "Final Velocity", message: vfTextField.text!)
    }
    @IBAction func showFullAPressed(sender: AnyObject) {
        self.presentAlertWithMessage(title: "Acceleration", message: aTextField.text!)
    }
    @IBAction func showFullTPressed(sender: AnyObject) {
        self.presentAlertWithMessage(title: "Time", message: tTextField.text!)
    }
    
    
    //we're resetting the text fields and values
    func resetValues(){
        xVal = ""
        viVal = ""
        vi2Val = ""
        vfVal = ""
        vf2Val = ""
        aVal = ""
        tVal = ""
        t2Val = ""
        
        xTextField.text = ""
        viTextField.text = ""
        vfTextField.text = ""
        aTextField.text = ""
        tTextField.text = ""
        
        //restore clear buttons
        xTextField.clearButtonMode = .Always
        viTextField.clearButtonMode = .Always
        vfTextField.clearButtonMode = .Always
        aTextField.clearButtonMode = .Always
        tTextField.clearButtonMode = .Always
        
        //get rid of show full buttons
        showFullX.hidden = true
        showFullVi.hidden = true
        showFullVf.hidden = true
        showFullA.hidden = true
        showFullT.hidden = true
    }
    
}

