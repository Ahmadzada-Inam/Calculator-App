//
//  ViewController.swift
//  Calculator
//
//  Created by Inam Ahmad-zada on 2017-03-16.
//  Copyright © 2017 Inam Ahmad-zada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var descriptionDisplay: UILabel!
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let currentlyInDisplay = display.text!
            if digit == "." && currentlyInDisplay.contains(".") == true{
                return
            }
            display.text = currentlyInDisplay + digit
        }else{
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    @IBAction func clear(_ sender: UIButton) {
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        brain.clear()
        descriptionDisplay.text = " "
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if !userIsInTheMiddleOfTyping && displayValue != 0{
            if let mathematicalSymbol = sender.currentTitle {
                brain.performOperation(mathematicalSymbol)
                descriptionDisplay.text = brain.descriptionResult()
            }
        }
        
        if let result = brain.result {
            displayValue = result
        }
    }
}

