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
            enter()
            display.text = "\(M_PI)"
            enter()
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
        displayValue = brain.pushOperand(displayValue!)
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
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

