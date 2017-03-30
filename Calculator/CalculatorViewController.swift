//
//  ViewController.swift
//  Calculator
//
//  Created by Inam Ahmad-zada on 2017-03-16.
//  Copyright © 2017 Inam Ahmad-zada. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var graphBtn: UIButton!{
        didSet{
            graphBtn.isEnabled = false
        }
    }
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    private var variableValues = [String:Double]()
    
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
    
    var displayResult: (result: Double?, isPending: Bool, description: String) = (nil, false, " "){
        didSet {
            if let result = displayResult.result{
                displayValue = result
            } else if displayResult.description == "?"{
                displayValue = 0.0
            }
            descriptionDisplay.text = displayResult.description + (displayResult.isPending ? " …" : " =")
            graphBtn.isEnabled = !displayResult.isPending
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        variableValues = [:]
        brain.clear()
        descriptionDisplay.text = " "
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        variableValues[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValues)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !displayResult.isPending
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationViewController = destination as? UINavigationController{
            destination = navigationViewController.visibleViewController ?? destination
        }
        if let graphViewController = destination as? GraphViewController,
            segue.identifier == "graphVC"{
            prepareGraphVC(graphViewController)
        }
    }
    
    func prepareGraphVC(_ graphVC: GraphViewController){
        graphVC.navigationItem.title = displayResult.description
        graphVC.yForX = { [weak weakSelf = self ] x in
            weakSelf?.variableValues["M"] = x
            return weakSelf?.brain.evaluate(using: weakSelf?.variableValues).result
            //return weakSelf?.displayResult.result
        }
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            guard !display.text!.isEmpty else {return}
            display.text = String(display.text!.characters.dropLast())
            if display.text!.isEmpty {
                displayValue = 0.0
                userIsInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValues)
            }
        }
        else{
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
        }
    }
}

