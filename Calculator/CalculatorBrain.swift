//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Priscila Cortez on 5/23/17.
//  Copyright © 2017 Priscila Cortez. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var allOperationsMade = ""
    private var temporaryOperationMade = ""
    private var constantToWrite = ""
    private var makingFloatingPointNumber = false
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private var operations : Dictionary<String, Operation> = [
        "π"     : Operation.constant(Double.pi),
        "e"     : Operation.constant(M_E),
        "√"     : Operation.unaryOperation(sqrt),
        "cos"   : Operation.unaryOperation(cos),
        "sin"   : Operation.unaryOperation(sin),
        "±"     : Operation.unaryOperation({ -$0 }),
        "1/x"   : Operation.unaryOperation({ 1/$0 }),
        "x²"    : Operation.unaryOperation({ $0 * $0 }),
        "×"     : Operation.binaryOperation({ $0 * $1 }),
        "÷"     : Operation.binaryOperation({ $0 / $1 }),
        "+"     : Operation.binaryOperation({ $0 + $1 }),
        "-"     : Operation.binaryOperation({ $0 - $1 }),
        "="     : Operation.equals,
        "C"     : Operation.clear
    ]
    
    private var complexWrittenUnaryOperations : Dictionary<String, (String) -> String> = [
        "1/x"   : {"1/(\($0))"},
        "x²"    : {"(\($0))²"},
    ]
    
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumulator = value
                
                // if not currently writing a function and a constant was clicked, then starting a new expression
                if pendingBinaryOperation == nil {
                    resetDescription()
                }
                
                constantToWrite = symbol
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    
                    if temporaryOperationMade.isEmpty {
                        allOperationsMade = applyUnaryOperation(with: symbol, on: allOperationsMade)
                    } else {
                        temporaryOperationMade = applyUnaryOperation(with: symbol, on: temporaryOperationMade)
                    }
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    // if there is a constant we need to write, then we are definitely using constant in binary expression
                    if !constantToWrite.isEmpty {
                        temporaryOperationMade += constantToWrite
                        constantToWrite = ""
                    }
                    allOperationsMade += "\(temporaryOperationMade) \(symbol) "
                    temporaryOperationMade = ""
                    
                    // perform binary operation with current accumulater if we already had one pending
                    if pendingBinaryOperation != nil {
                        performPendingBinaryOperation()
                    }
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
                
                if !constantToWrite.isEmpty {
                    allOperationsMade = constantToWrite
                    constantToWrite = ""
                }
            case .clear:
                pendingBinaryOperation = nil
                accumulator = nil
                resetDescription()
            }
        }
    }
    
    mutating func resetDescription(){
        temporaryOperationMade = ""
        allOperationsMade = ""
        constantToWrite = ""
    }
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
        temporaryOperationMade = String(operand)
        
        // Remove trailing .0 if number is an integer
        if (operand.truncatingRemainder(dividingBy: 1) == 0){
            temporaryOperationMade = String(Int(operand))
        } else {
            temporaryOperationMade = String(operand)
        }
        
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var pendingResult: Bool {
        get {
            if pendingBinaryOperation != nil {
                return true
            }
            return false
        }
    }
    
    var description: String {
        get {
            return allOperationsMade + temporaryOperationMade
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private mutating func applyUnaryOperation(with symbol: String, on operationsMade: String ) -> String {
        if let writeComplexOperation = complexWrittenUnaryOperations[symbol]{
            return writeComplexOperation(operationsMade)
            
        }
        return "\(symbol) (\(operationsMade))"
    }
    
    private mutating func performPendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
            // Add operand that we have accumulated to all the operations made so far
            if !constantToWrite.isEmpty {
                temporaryOperationMade += constantToWrite
                constantToWrite = ""
            }
            
            allOperationsMade += temporaryOperationMade
            temporaryOperationMade = ""
            
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
}
