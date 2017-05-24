//
//  ViewController.swift
//  Calculator
//
//  Created by Priscila Cortez on 5/16/17.
//  Copyright © 2017 Priscila Cortez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var userIsInTheMiddleOfMakingDecimal = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping{
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func touchDot(_ sender: UIButton) {
        let dot = sender.currentTitle!
        
        if !userIsInTheMiddleOfTyping && !userIsInTheMiddleOfMakingDecimal{
            display.text = "0" + dot
            userIsInTheMiddleOfTyping = true
            userIsInTheMiddleOfMakingDecimal = true
        }
        else if !userIsInTheMiddleOfMakingDecimal {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + dot
            userIsInTheMiddleOfMakingDecimal = true
        }
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userIsInTheMiddleOfMakingDecimal = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            displayValue = result
        }
    }
}

