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
    @IBOutlet weak var operationsDisplay: UILabel!
    
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
            
            if !brain.pendingResult {
                brain.resetDescription()
            }
        }
    }
    
    @IBAction func touchDot(_ sender: UIButton) {
        let dot = sender.currentTitle!
        
        print("touching dot")
        
        if !userIsInTheMiddleOfTyping && !userIsInTheMiddleOfMakingDecimal{
            print("User not in the middle of typing and making a decimal")
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
        
        print("User is in the middle of typing \(userIsInTheMiddleOfTyping)")
        print("User is in the middle of making decimal \(userIsInTheMiddleOfMakingDecimal)")
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            if result.isEqual(to: 0){
                display.text = "0"
            } else {
                displayValue = result
            }
        }
        
        // set the operations display
        if brain.pendingResult {
            operationsDisplay.text = brain.description + "..."
        } else if brain.description != ""{
            operationsDisplay.text = brain.description + "="
        } else {
            operationsDisplay.text = brain.description
        }
    }
}

