//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Inam Ahmad-zada on 2017-03-16.
//  Copyright © 2017 Inam Ahmad-zada. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private var accumulator: Double?
    
    private var resultIsPending: Bool {
        get{
            return pendingBinaryOperation != nil
        }
    }
    
    private enum Precedence: Int {
        case Min = 0, Max
    }
    
    private var currentPrecedence = Precedence.Max
    
    var description: String{
        get{
            return descriptionAcc
        }
        set{
            descriptionAcc = newValue
        }
    }
    
    private var descriptionAcc = ""
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double, Precedence)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "x²": Operation.unaryOperation({pow($0, 2)}),
        "±": Operation.unaryOperation({-$0}),
        "﹢": Operation.binaryOperation({$0 + $1}, Precedence.Min),
        "﹣": Operation.binaryOperation({$0 - $1}, Precedence.Min),
        "×": Operation.binaryOperation({$0 * $1}, Precedence.Max),
        "÷": Operation.binaryOperation({$0 / $1}, Precedence.Max),
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumulator = value
                description = symbol
                pendingBinaryOperation = nil
            case .unaryOperation(let function):
                if accumulator != nil{
                    accumulator = function(accumulator!)
                    description = symbol + "(\(description))"
                }
            case .binaryOperation(let function, let precedence):
                if accumulator != nil{
                    if currentPrecedence.rawValue < precedence.rawValue {
                        description = "(\(description))"
                    }
                    currentPrecedence = precedence
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    description += symbol
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation(){
        if accumulator != nil && pendingBinaryOperation != nil{
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double{
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double){
        if resultIsPending{
            description += "\(operand)"
        }else{
            description = "\(operand)"
        }
        accumulator = operand
    }
    
    var result: Double?{
        get {
            return accumulator
        }
    }
    
    func descriptionResult() -> String{
        return resultIsPending ? (description + " ...") : (description + " =")
    }
    
    mutating func clear(){
        pendingBinaryOperation = nil
        description = "0"
        accumulator = 0
        currentPrecedence = Precedence.Max
    }
}
