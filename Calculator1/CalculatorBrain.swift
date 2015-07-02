//
//  CalculatorBrain.swift
//  Calculator1
//
//  Created by Chuning Song on 29/06/2015.
//  Copyright (c) 2015 The University of Melbourne. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Unknown(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Unknown(let unknown):
                    return unknown
                }
            }
        }
    }
    
    var variableValues = [String:Double]()
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()    //dictionary
    
    var description: String {
        get{
            if let result = parse() {
                return result
            }
            return "What the hell's going on?"
        }
    }
    
    init(){
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("⨯", *))
        knownOps["÷"] = Op.BinaryOperation("÷"){ $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-"){ $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
    }
    
    var program: AnyObject { //guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand,remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Unknown(let unknown):
                return (variableValues[unknown], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func parse() -> String? {
        let (result, remainder) = parseStack(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        println(description)
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Unknown(symbol))
        println(description)
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        println(description)
        return evaluate()
    }
    
    private func parseStack(ops:[Op]) -> (result: String?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand.description, remainingOps)
            case .UnaryOperation(let description, _):
                let operandParse = parseStack(remainingOps)
                if let operand = operandParse.result {
                    return (description + "(\(operand))",operandParse.remainingOps)
                }
            case .BinaryOperation(let description,_):
                let op1Parse = parseStack(remainingOps)
                if let operand1 = op1Parse.result {
                    let op2Parse = parseStack(op1Parse.remainingOps)
                    if let operand2 = op2Parse.result {
                        return ("\(operand1)" + description + "\(operand2)", op2Parse.remainingOps)
                    }
                }
            case .Unknown(let unknown):
                return (unknown, remainingOps)
            }
        }
        return (nil, ops)
    }
    
}
