//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Inam Ahmad-zada on 2017-03-16.
//  Copyright © 2017 Inam Ahmad-zada. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
//    @available(IOS, deprecated, message: "No longer needed")
    
    private enum OpStack {
        case Operand(Double)
        case Operation(String)
        case Variable(String)
    }
    
    private var internalProgram = [OpStack]()
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, ((String) -> String)?)
        case binaryOperation((Double, Double)-> Double, ((String, String)->String)?)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, nil),
        "±": Operation.unaryOperation({-$0}, nil),
        "х²": Operation.unaryOperation({$0 * $0}, { "(" + $0 + ")²"}),
        "х⁻¹": Operation.unaryOperation({1.0 / $0}, { "(" + $0 + ")⁻¹"}),
        "cos": Operation.unaryOperation(cos, nil),
        "sin": Operation.unaryOperation(sin, nil),
        "tan": Operation.unaryOperation(tan, nil),
        "cos⁻¹": Operation.unaryOperation(acos, nil),
        "sin⁻¹": Operation.unaryOperation(asin, nil),
        "tan⁻¹": Operation.unaryOperation(atan, nil),
        "log": Operation.unaryOperation(log10, nil),
        "ln": Operation.unaryOperation(log, nil),
        "﹢": Operation.binaryOperation({$0+$1}, nil),
        "﹣": Operation.binaryOperation({$0-$1}, nil),
        "×": Operation.binaryOperation({$0*$1}, nil),
        "÷": Operation.binaryOperation({$0/$1}, nil),
        "=": Operation.equals
    ]
    
    mutating func setOperand(_ operand: Double){
        internalProgram.append(OpStack.Operand(operand))
    }
    
    mutating func setOperand(variable named: String){
        internalProgram.append(OpStack.Variable(named))
    }
    
    mutating func performOperation(_ symbol: String){
        internalProgram.append(OpStack.Operation(symbol))
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        
        var accumulator: Double?
        var descriptionAccumulator: String = " "
        var pendingBinaryOperation: PendingBinaryOperation?
        
        var description: String{
            get{
                if pendingBinaryOperation == nil {
                    return descriptionAccumulator
                }else{
                    return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
                }
            }
        }
        
        var result: Double?{
            get{
                return accumulator
            }
        }
        
        var resultIsPending: Bool{
            get{
                return pendingBinaryOperation != nil
            }
        }
        
        func setOperand(_ operand: Double){
            accumulator = operand
            if let value = accumulator {
                descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
            }
        }
        
        func setOperand(variable named: String){
            accumulator = variables?[named] ?? 0
            descriptionAccumulator = named
        }
        
        func performOperation(_ symbol: String){
            if let operation = operations[symbol]{
                switch operation{
                case .constant(let value):
                    accumulator = value
                    descriptionAccumulator = symbol
                case .unaryOperation(let function, var descriptionFunction):
                    if accumulator != nil{
                        accumulator = function(accumulator!)
                        if descriptionFunction == nil{
                            descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                        descriptionAccumulator = descriptionFunction!(descriptionAccumulator)
                }
                case .binaryOperation(let function, var descriptionFunction):
                    performPendingBinaryOperation()
                    if accumulator != nil{
                        if(descriptionFunction == nil){
                            descriptionFunction = {$0 + symbol + $1}}
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!,
                                                                        descriptionFunction: descriptionFunction!, descriptionOperand: descriptionAccumulator)
                        accumulator = nil
                    }
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
        func performPendingBinaryOperation(){
            if pendingBinaryOperation != nil && accumulator != nil{
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator)
                pendingBinaryOperation = nil
            }
        }
        
        struct PendingBinaryOperation {
            let function: (Double, Double)->Double
            let firstOperand: Double
            var descriptionFunction: (String, String) -> String
            var descriptionOperand: String
            
            func perform(with secondOperand: Double) -> Double{
                return function(firstOperand, secondOperand)
            }
            
            func performDescription(with secondOperand: String) -> String{
                return descriptionFunction(descriptionOperand, secondOperand)
            }
        }
        
        guard !internalProgram.isEmpty else{ return(nil, false, "?")}
        
        for op in internalProgram{
            switch op{
            case .Operand(let operand):
                setOperand(operand)
            case .Operation(let function):
                performOperation(function)
            case .Variable(let symbol):
                setOperand(variable: symbol)
            }
        }
        
        return(result, resultIsPending, description)
    }
    
    mutating func clear(){
        internalProgram.removeAll()
    }
    
    mutating func undo(){
        if !internalProgram.isEmpty{
            internalProgram = Array(internalProgram.dropLast())
        }
    }
}

let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.groupingSeparator = ","
    formatter.locale = Locale.current
    return formatter
}()
