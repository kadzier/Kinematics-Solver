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

