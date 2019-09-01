//
//  Oops.swift
//  Fyre Dice
//
//  Created by Wayne Ohmer on 11/19/17.
//  Copyright © 2017 Wayne Ohmer. All rights reserved.
//

import UIKit

class Oops {
    
    enum OopsType {
        case buttonTouch
        case roll
        case saveDelete
        case save
        case hit
    }
    
    var fyreDice = FyreDice()
    var type = OopsType.buttonTouch
    var saveIndex = Int(0)
    
    convenience init(fyreDice:FyreDice, type:OopsType) {
        self.init()
        self.fyreDice = fyreDice
        self.type = type
    }
    
}
