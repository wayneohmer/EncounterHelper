//
//  ConditionsController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/25/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class ConditionsController: UIViewController {
    
    var switchDict = [String:UISwitch]()
    var monsterVc = DetailViewController()
    
    @IBOutlet weak var mainStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for stack in mainStack.subviews {
            if let stack2 = stack as? UIStackView {
                for stack3 in stack2.subviews {
                    if let stack4 = stack3 as? UIStackView {
                        var dictSwitch:UISwitch?
                        var key:String?
                        for view in stack4.subviews {
                            if let thisSwitch = view as? UISwitch {
                                dictSwitch = thisSwitch
                            }
                            if let label = view as? UILabel {
                                key = label.text
                            }
                            if let myKey = key, let mySwitch = dictSwitch {
                                switchDict[myKey] = mySwitch
                            }
                        }
                    }
                }
            }
        }
        if let conditions = monsterVc.monster?.monsterModel.conditions {
            for condition in conditions {
                switchDict[condition]?.isOn = true
            }
        }
        if let monster = monsterVc.monster {
            let ci = monster.conditionImmunities.split(separator: ",")
            for key in ci {
                switchDict[key.trimmingCharacters(in: [" "]).capitalized]?.isEnabled = false
            }
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let monster = monsterVc.monster else { return }
        var conditions = Set<String>()
        for (key,item) in switchDict {
            if item.isOn {
                conditions.insert(key)
            }
        }
        monster.monsterModel.conditions = conditions
        monsterVc.conditionsLabel.text = monster.conditions
        monsterVc.masterVc?.tableView.reloadData()
        monsterVc.masterVc?.selectMonsterWith(name: monster.name)
    }
    
    

}
