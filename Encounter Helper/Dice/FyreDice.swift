//
//  FyreDice.swift
//  Fyre Dice
//
//  Created by Wayne Ohmer on 10/8/17.
//  Copyright © 2017 Wayne Ohmer. All rights reserved.
//

import UIKit

class FyreDice {
    
    var dice = [Int:Int]()
    var diceResults = [Int:Int]()
    var modifier = 0
    var rollValue = 0
    var advantageDisplayString = ""
    static var shardedHistory = [FyreDice]()
    
    var advantage = false {
        didSet {
            if advantage {
                self.disadvantage = false
            }
        }
    }
    var disadvantage = false {
        didSet {
            if disadvantage {
                self.advantage = false
            }
        }
    }
    
    var max:Int {
        get {
            var returnValue = 0
            for (die,multiplier) in self.dice {
                returnValue += multiplier*die
            }
            return returnValue + self.modifier
        }
    }
    
    var min:Int {
        get {
            var returnValue = 0
            for (_,multiplier) in self.dice {
                returnValue += multiplier
            }
            return returnValue + self.modifier
        }
    }
    
    var numberOfDice:Int {
        get {
            var returnValue = 0
            for (_,multiplier) in self.dice {
                returnValue += multiplier
            }
             return returnValue
        }
    }
    
    var isAdvantageAllowed:Bool {
        if let d20 = self.dice[20] {
            return d20 == 1
        }
        return false
    }
    
    var display:String {
        var returnString = ""
        for (die,multiplier) in self.dice.sorted(by: {$0 < $1}) {
            if multiplier != 0 {
                if returnString != "" {
                    let sign = multiplier > 0 ? "+" : ""
                    returnString += sign
                }
                returnString += "\(multiplier)d\(die)"
            }
        }
        if self.modifier != 0 {
            let sign = modifier > 0 ? "+" : ""
            returnString += "\(sign)\(self.modifier)"
        }
        return returnString == "" ? " " : returnString
    }
    
    var resultDisplay:String {
        var returnString = ""
        for (die,result) in self.diceResults.sorted(by: {$0 < $1}) {
            if die == 20 && (self.advantage || self.disadvantage) {
                returnString += "\(self.dice[die] ?? 0)d\(die)(\(self.advantageDisplayString))"
            } else {
                returnString += "\(self.dice[die] ?? 0)d\(die)(\(result))"
            }
        }
        return returnString
    }
    
    var historyDisplay:String {
        var returnString = ""
        for (die,result) in self.diceResults.sorted(by: {$0 < $1}) {
            if die == 20 && (self.advantage || self.disadvantage) {
                returnString += "\(self.dice[die] ?? 0)d\(die)(\(self.advantageDisplayString))"
            } else {
                returnString += "\(self.dice[die] ?? 0)d\(die)(\(result))"
            }
        }
        if self.modifier != 0 {
            let sign = modifier > 0 ? "+" : ""
            returnString += "\(sign)\(self.modifier)"
        }
        returnString += " = \(self.rollValue)"
        
        return returnString
    }
    
    convenience init(with fyreDice:FyreDice, includeResult isResultIncluded:Bool = false) {
        self.init()
        self.dice = fyreDice.dice
        self.modifier = fyreDice.modifier
        self.advantage = fyreDice.advantage
        self.disadvantage = fyreDice.disadvantage
        if isResultIncluded {
            self.diceResults = fyreDice.diceResults
            self.rollValue = fyreDice.rollValue
        }
    }
    
    func add(multipier:Int, d die:Int) {
        if var newValue = self.dice[die] {
            newValue += multipier
            self.dice[die] = newValue
        } else {
            self.dice[die] = multipier
        }
    }
    
    func clear() {
        self.dice.removeAll()
        self.diceResults.removeAll()
        self.rollValue = 0
        self.advantageDisplayString = ""
        self.modifier = 0
        self.advantage = false
        self.disadvantage = false
    }
    
    func roll() {
        for (die,multiplier) in dice {
            var thisResult = Int(0)
            if die == 20 && (self.advantage || self.disadvantage) {
                let r1 = Int(arc4random_uniform(UInt32(die)) + 1)
                let r2 = Int(arc4random_uniform(UInt32(die)) + 1)
                if self.advantage {
                    thisResult = r1 > r2 ? r1 : r2
                    self.advantageDisplayString = r1 > r2 ? "\(r1) \(r2)" : "\(r2) \(r1)"
                } else {
                    thisResult = r1 < r2 ? r1 : r2
                    self.advantageDisplayString = r1 < r2 ? "\(r1) \(r2)" : "\(r2) \(r1)"
                }
            } else {
                let sign = multiplier > 0
                for _ in 1 ... abs(multiplier) {
                    if sign {
                        thisResult += Int(arc4random_uniform(UInt32(die)) + 1)
                    } else {
                        thisResult -= Int(arc4random_uniform(UInt32(die)) + 1)
                    }
                }
            }
            self.diceResults[die] = thisResult
        }
        
        self.rollValue = self.diceResults.reduce(0,{$0 + $1.value}) + self.modifier
    }

}
    

