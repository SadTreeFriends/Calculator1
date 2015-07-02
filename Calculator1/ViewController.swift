//
//  ViewController.swift
//  Calculator1
//
//  Created by Chuning Song on 29/06/2015.
//  Copyright (c) 2015 The University of Melbourne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton){
        let digit = sender.currentTitle!
        
        if (digit == "π"){
            brain.variableValues["π"] = 35
            display.text = "π"
        } else if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }

    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.variableValues[display.text!] { //if var exists in dictionary
            displayValue = brain.pushOperand(display.text!)
        }
        displayValue = brain.pushOperand(displayValue!)
    }
    
    var displayValue: Double? {
        get {
            if let result = NSNumberFormatter().numberFromString(display.text!)?.doubleValue {
                return result
            }
            return brain.variableValues[display.text!]
        }
        
        set {
            if let result = newValue {
                display.text = "\(result)"
            } else {
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

