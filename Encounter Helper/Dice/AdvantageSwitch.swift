//
//  AdvantageSwitch.swift
//  Fyre Dice
//
//  Created by Wayne Ohmer on 10/14/17.
//  Copyright © 2017 Wayne Ohmer. All rights reserved.
//

import UIKit

class AdvantageSwitch: UISwitch {
    
    var companion:AdvantageSwitch?
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                self.setOn(false, animated: true)
            }
        }
    }
    
    func fixCompanion() {
        guard let companion = self.companion else {
            return
        }
        if isOn && companion.isOn {
            companion.setOn(false, animated: true)
        }
    }

}
