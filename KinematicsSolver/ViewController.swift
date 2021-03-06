//
//  ViewController.swift
//  KinematicsSolver
//
//  Created by Kahlil Dozier on 8/31/16.
//  Copyright © 2016 Kahlil Dozier. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum Units{
    case si //meters, seconds
    case eng1 //feet, seconds
    case eng2 //miles, hours
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
    var units: Units = .si
    
    let maxChars = 18 //"cutoff" point for chars in text field
    
    
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
    var solutionValues: [String: Double] = [:] //when we've pressed solve, this dict holds the solution values
    //TODO: Change solution values with unit changes!
    
    //show work button
    @IBOutlet weak var showWorkButton: UIButton!
    
    //MARK: View lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        let color0 = UIColor.white.cgColor as CGColor
        let color1 = UIColor.groupTableViewBackground.cgColor as CGColor
        let color2 = UIColor.lightGray.withAlphaComponent(0.5).cgColor as CGColor
        gradientLayer.colors = [color0, color1, color2]
        gradientLayer.locations = nil //spread evenly
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        self.showFullX.isHidden = true
        self.showFullVi.isHidden = true
        self.showFullVf.isHidden = true
        self.showFullA.isHidden = true
        self.showFullT.isHidden = true
        
        //show work button
        self.showWorkButton.isHidden = true
        
        //style of transitioning modally to self
        self.modalTransitionStyle = .flipHorizontal
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //MARK: Present alert controller with message
    func presentAlertWithMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Solve/Reset
    
    @IBAction func solveResetPressed(_ sender: AnyObject) {
        
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
                    button.setTitle("Reset", for: UIControlState())
                    self.showWorkButton.isHidden = false
                    let solutionValues = EquationValidator.solveForUnknowns(valuesDict)
                    self.solutionValues = solutionValues
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
            button.setTitle("Solve!", for: UIControlState())
            self.showWorkButton.isHidden = true
            self.resetValues()
        }
    }

    //MARK: Show work
    
    @IBAction func showWorkPressed(_ sender: AnyObject) {
        let vc = ShowWorkViewController(nibName: "ShowWorkViewController", bundle: nil)
        var equationIndices: [Int] = [] //array to encode which equations we used in solution
        let varsArray = self.solutionValues.keys
        
        if varsArray.contains("a") && varsArray.contains("t"){
            equationIndices = [12,16]
        }
        else if varsArray.contains("vf") && varsArray.contains("t"){
            equationIndices = [11,4]
        }
        else if varsArray.contains("vf") && varsArray.contains("a"){
            equationIndices = [15,3]
        }
        else if varsArray.contains("vi") && tVal == ""{
            equationIndices = [10]
        }
        else if varsArray.contains("vi") && aVal == ""{
            equationIndices = [14]
        }
        else if varsArray.contains("vi") && vfVal == ""{
            equationIndices = [2]
        }
        else if varsArray.contains("x") && varsArray.contains("t"){
            equationIndices = [9,8]
        }
        else if varsArray.contains("x") && varsArray.contains("a"){
            equationIndices = [13,7]
        }
        else if varsArray.contains("x") && varsArray.contains("vf"){
            equationIndices = [1,6]
        }
        else{ //contains vi, xVal = ""
            equationIndices = [5]
        }
        vc.equationIndices = equationIndices
        vc.mainController = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: Change units
    @IBAction func changeUnitsPressed(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Choose Units", preferredStyle: .actionSheet)
        let siAction = UIAlertAction(title: "SI (meters, seconds)", style: .default) { (action) in
            self.displacementLabel.text = "Displacement (m)"
            self.initVelLabel.text = "Initial Velocity (m/s)"
            self.finalVelLabel.text = "Final Velocity (m/s)"
            self.accelLabel.text = "Acceleration (m/s\u{00B2})"
            self.timeLabel.text = "Time (s)"
            
            self.switchToSIUnits()
        }
        let eng1Action = UIAlertAction(title: "English (feet, seconds)", style: .default) { (action) in
            self.displacementLabel.text = "Displacement (ft)"
            self.initVelLabel.text = "Initial Velocity (ft/s)"
            self.finalVelLabel.text = "Final Velocity (ft/s)"
            self.accelLabel.text = "Acceleration (ft/s\u{00B2})"
            self.timeLabel.text = "Time (s)"
            
            self.switchToEngUnits1()
        }
        let eng2Action = UIAlertAction(title: "English (miles, hours)", style: .default) { (action) in
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
        
        self.present(alertController, animated: true, completion: nil)
    }
    //switch to meters, seconds
    func switchToSIUnits(){
        let currentUnits = self.units
        //if already SI, do nothing
        if currentUnits == .si{
            return
        }
        //eng1 to SI
        else if currentUnits == .eng1{
            //feet to meters
            let feetMeterFactor = 0.3048
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal] //the values affected by this conversion
            for i in 0..<valsArray.count{
                let stringValue = valsArray[i]
                //if value isn't blank, convert and fill in
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    doubleValue *= feetMeterFactor
                    let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                    let finalDoubleString = String(finalDoubleValue)
                    let index = i
                    
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
        else if currentUnits == .eng2{
            //miles to meters
            let mileMeterFactor = 1609.344
            //hours to seconds
            let hourSecondFactor = 3600.0
            //mi/hr to meters/sec
            let ratioFactor = mileMeterFactor / hourSecondFactor
            //mi/h^2 to m/sec^2
            let ratioFactorSquared = mileMeterFactor / (hourSecondFactor * hourSecondFactor)
            
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal, tVal, t2Val]
            for i in 0..<valsArray.count{
                let stringValue = valsArray[i]
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    let index = i
                    switch index{
                    case 0:
                        doubleValue *= mileMeterFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.xVal = String(finalDoubleValue)
                    case 1:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.viVal = String(finalDoubleValue)
                    case 2:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vi2Val = String(finalDoubleValue)
                    case 3:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vfVal = String(finalDoubleValue)
                    case 4:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vf2Val = String(finalDoubleValue)
                    case 5:
                        doubleValue *= ratioFactorSquared
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.aVal = String(finalDoubleValue)
                    case 6:
                        doubleValue *= hourSecondFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.tVal = String(finalDoubleValue)
                    case 7:
                        doubleValue *= hourSecondFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.t2Val = String(finalDoubleValue)
                    default:
                        return
                    }
                }
            }
        }
        self.units = .si
        self.updateTextFieldValues()
    }
    //switch to feet, seconds
    func switchToEngUnits1(){
        let currentUnits = self.units
        
        if currentUnits == .si{
            //meters to feet
            let meterFeetFactor = 3.2808399
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal] //the values affected by this conversion
            for i in 0..<valsArray.count{
                let stringValue = valsArray[i]
                //if value isn't blank, convert and fill in
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    doubleValue *= meterFeetFactor
                    let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                    let finalDoubleString = String(finalDoubleValue)
                    let index = i
                    
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
        else if currentUnits == .eng1{
            return
        }
        else if currentUnits == .eng2{
            //miles to feet
            let mileFeetFactor = 5280.0
            //hours to seconds
            let hourSecondFactor = 3600.0
            //mi/hr to ft/sec
            let ratioFactor = mileFeetFactor / hourSecondFactor
            //mi/h^2 to ft/sec^2
            let ratioFactorSquared = mileFeetFactor / (hourSecondFactor * hourSecondFactor)
            
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal, tVal, t2Val]
            for i in 0..<valsArray.count{
                let stringValue = valsArray[i]
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    let index = i
                    switch index{
                    case 0:
                        doubleValue *= mileFeetFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.xVal = String(finalDoubleValue)
                    case 1:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.viVal = String(finalDoubleValue)
                    case 2:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vi2Val = String(finalDoubleValue)
                    case 3:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vfVal = String(finalDoubleValue)
                    case 4:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vf2Val = String(finalDoubleValue)
                    case 5:
                        doubleValue *= ratioFactorSquared
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.aVal = String(finalDoubleValue)
                    case 6:
                        doubleValue *= hourSecondFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.tVal = String(finalDoubleValue)
                    case 7:
                        doubleValue *= hourSecondFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.t2Val = String(finalDoubleValue)
                    default:
                        return
                    }
                }
            }
        }
        
        self.units = .eng1
        self.updateTextFieldValues()
    }
    //switch to miles, hours
    func switchToEngUnits2(){
        
        let currentUnits = self.units
        
        if currentUnits == .si{
            //meters to miles
            let meterMileFactor = 1/1609.344
            //seconds to hours 
            let secondHourFactor = 1/3600.0
            //m/s to mi/hr
            let ratioFactor = meterMileFactor / secondHourFactor
            //m/s^2 to mi/hr^2
            let ratioFactorSquared = meterMileFactor / (secondHourFactor*secondHourFactor)
            
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal, tVal, t2Val]
            for i in 0..<valsArray.count{
                let stringValue = valsArray[i]
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    let index = i
                    switch index{
                    case 0:
                        doubleValue *= meterMileFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.xVal = String(finalDoubleValue)
                    case 1:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.viVal = String(finalDoubleValue)
                    case 2:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vi2Val = String(finalDoubleValue)
                    case 3:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vfVal = String(finalDoubleValue)
                    case 4:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vf2Val = String(finalDoubleValue)
                    case 5:
                        doubleValue *= ratioFactorSquared
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.aVal = String(finalDoubleValue)
                    case 6:
                        doubleValue *= secondHourFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.tVal = String(finalDoubleValue)
                    case 7:
                        doubleValue *= secondHourFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.t2Val = String(finalDoubleValue)
                    default:
                        return
                    }
                }
            }
        }
        else if currentUnits == .eng1{
            //feet to miles
            let feetMileFactor = 1/5280.0
            //seconds to hours
            let secondHourFactor = 1/3600.0
            //m/s to mi/hr
            let ratioFactor = feetMileFactor / secondHourFactor
            //m/s^2 to mi/hr^2
            let ratioFactorSquared = feetMileFactor / (secondHourFactor*secondHourFactor)
            
            let valsArray = [xVal, viVal, vi2Val, vfVal, vf2Val, aVal, tVal, t2Val]
            for i in 0..<valsArray.count{
                let stringValue = valsArray[i]
                if stringValue != ""{
                    var doubleValue = Double(stringValue)!
                    let index = i
                    switch index{
                    case 0:
                        doubleValue *= feetMileFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.xVal = String(finalDoubleValue)
                    case 1:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.viVal = String(finalDoubleValue)
                    case 2:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vi2Val = String(finalDoubleValue)
                    case 3:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vfVal = String(finalDoubleValue)
                    case 4:
                        doubleValue *= ratioFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.vf2Val = String(finalDoubleValue)
                    case 5:
                        doubleValue *= ratioFactorSquared
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.aVal = String(finalDoubleValue)
                    case 6:
                        doubleValue *= secondHourFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.tVal = String(finalDoubleValue)
                    case 7:
                        doubleValue *= secondHourFactor
                        let finalDoubleValue = self.roundToSixPlaces(doubleValue)
                        self.t2Val = String(finalDoubleValue)
                    default:
                        return
                    }
                }
            }
        }
        else if currentUnits == .eng2{
            return
        }
        
        self.units = .eng2
        self.updateTextFieldValues()
    }
    
    //MARK: Help
    @IBAction func helpPressed(_ sender: AnyObject) {
        let vc = HelpViewController(nibName: "HelpViewController", bundle: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: Text field delegate
    //we want to disable editing if we're in the "reset" state
    //we want to disable editing if 3 fields are already filled and we're trying to edit the fourth and beyond
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
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
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    @IBAction func xTextChanged(_ sender: UITextField) {
        xVal = sender.text!
    }
    @IBAction func viTextChanged(_ sender: UITextField) {
        viVal = sender.text!
    }
    @IBAction func vfTextChanged(_ sender: UITextField) {
        vfVal = sender.text!
    }
    @IBAction func aTextChanged(_ sender: UITextField) {
        aVal = sender.text!
    }
    @IBAction func tTextChanged(_ sender: UITextField) {
        tVal = sender.text!
    }
    
    //when we've solved the equation, this updates the values variables.  We also handle rounding here.
    func fillInValues(_ valuesDict: [String:Double]){
        
        //get rid of clear buttons
        xTextField.clearButtonMode = .never
        viTextField.clearButtonMode = .never
        vfTextField.clearButtonMode = .never
        aTextField.clearButtonMode = .never
        tTextField.clearButtonMode = .never
        
        if valuesDict["x"] != nil{
            let x = roundToSixPlaces(valuesDict["x"]!)
            xVal = String(x)
        }
        if valuesDict["vi"] != nil{
            let vi = roundToSixPlaces(valuesDict["vi"]!)
            viVal = String(vi)
            if valuesDict["vi2"] != nil{
                let vi2 = roundToSixPlaces(valuesDict["vi2"]!)
                vi2Val = String(vi2)
            }
        }
        if valuesDict["vf"] != nil{
            let vf = roundToSixPlaces(valuesDict["vf"]!)
            vfVal = String(vf)
            if valuesDict["vf2"] != nil{
                let vf2 = roundToSixPlaces(valuesDict["vf2"]!)
                vf2Val = String(vf2)
            }
        }
        if valuesDict["a"] != nil{
            let a = roundToSixPlaces(valuesDict["a"]!)
            aVal = String(a)
        }
        if valuesDict["t"] != nil{
            let t = roundToSixPlaces(valuesDict["t"]!)
            tVal = String(t)
            if valuesDict["t2"] != nil{
                let t2 = roundToSixPlaces(valuesDict["t2"]!)
                t2Val = String(t2)
            }
        }
        
        self.updateTextFieldValues()
    }
    //helper function to round to six places
    func roundToSixPlaces(_ num: Double) -> Double{
        return Double(round(1000000*num)/1000000)
    }
    //when we've updated our values variables, this updates the text field values.  Also handle display of the "show full" buttons.
    func updateTextFieldValues(){
        xTextField.text = xVal
        if xTextField.text?.characters.count > maxChars{
            showFullX.isHidden = false
        }
        viTextField.text = viVal
        if vi2Val != ""{
            viTextField.text = viTextField.text! + " or " + vi2Val
        }
        if viTextField.text?.characters.count > maxChars{
            showFullVi.isHidden = false
        }
        vfTextField.text = vfVal
        if vf2Val != ""{
            vfTextField.text = vfTextField.text! + " or " + vf2Val
        }
        if vfTextField.text?.characters.count > maxChars{
            showFullVf.isHidden = false
        }
        aTextField.text = aVal
        if aTextField.text?.characters.count > maxChars{
            showFullA.isHidden = false
        }
        tTextField.text = tVal
        if t2Val != ""{
            tTextField.text = tTextField.text! + " or " + t2Val
        }
        if tTextField.text?.characters.count > maxChars{
            showFullT.isHidden = false
        }
    }
    //showing full values
    @IBAction func showFullXPressed(_ sender: AnyObject) {
        self.presentAlertWithMessage(title: "Displacement", message: xTextField.text!)
    }
    @IBAction func showFullViPressed(_ sender: AnyObject) {
        self.presentAlertWithMessage(title: "Initial Velocity", message: viTextField.text!)
    }
    @IBAction func showFullVfPressed(_ sender: AnyObject) {
        self.presentAlertWithMessage(title: "Final Velocity", message: vfTextField.text!)
    }
    @IBAction func showFullAPressed(_ sender: AnyObject) {
        self.presentAlertWithMessage(title: "Acceleration", message: aTextField.text!)
    }
    @IBAction func showFullTPressed(_ sender: AnyObject) {
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
        xTextField.clearButtonMode = .always
        viTextField.clearButtonMode = .always
        vfTextField.clearButtonMode = .always
        aTextField.clearButtonMode = .always
        tTextField.clearButtonMode = .always
        
        //get rid of show full buttons
        showFullX.isHidden = true
        showFullVi.isHidden = true
        showFullVf.isHidden = true
        showFullA.isHidden = true
        showFullT.isHidden = true
        
        //clear solution values
        self.solutionValues = [:]
    }
    
}

