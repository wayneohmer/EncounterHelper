//
//  ConditionsController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/25/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class ConditionsController: UIViewController {

    var switchDict = [String: UISwitch]()
    var monsterVc = DetailViewController()

    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var DamageField: UITextField!
    @IBOutlet var saveButtons: [BlackButton]!
    @IBOutlet weak var saveDCField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        for stack in mainStack.subviews {
            if let stack2 = stack as? UIStackView {
                for stack3 in stack2.subviews {
                    if let stack4 = stack3 as? UIStackView {
                        var dictSwitch: UISwitch?
                        var key: String?
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
            if let save = monster.monsterModel.eotSave {
                for button in saveButtons {
                    button.isEnabled = button.title(for: .normal) != save
                }
                self.saveDCField.text = "\(monster.eotSaveDC ?? 0)"

            }
        }

    }

    @IBAction func switchChanged(_ sender: UISwitch) {

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let monster = monsterVc.monster else { return }
        var conditions = Set<String>()
        let oldConditions = monster.conditions
        for (key, item) in switchDict {
            if item.isOn {
                conditions.insert(key)
            }
        }
        monster.monsterModel.eotSave = nil
        monster.monsterModel.eotDamage = nil
        if let dmg = Int(self.DamageField.text ?? ""), dmg != 0 {
            monster.monsterModel.eotDamage = dmg
        }
        for button in saveButtons {
            if button.isEnabled == false, button.title(for: .normal) != "None" {
                monster.monsterModel.eotSave = button.title(for: .normal)
                monster.monsterModel.eotSaveDC = Int(self.saveDCField.text ?? "")
            }
        }
        monster.monsterModel.conditions = conditions
        monsterVc.conditionsLabel.text = monster.conditions
        monsterVc.masterVc?.tableView.reloadData()
        monsterVc.masterVc?.selectMonsterWith(name: monster.name)
        if oldConditions != monster.conditions {
            if monster.conditions == "" {
                monsterVc.logMessage(message: "Conditions Removed: \(oldConditions)")

            } else if oldConditions == "" {
                monsterVc.logMessage(message: "Conditions Added: \(monster.conditions)")
            } else {
                monsterVc.logMessage(message: "Conditions Changed: \(oldConditions) To \(monster.conditions)")
            }
        }

    }

    @IBAction func SaveButtonTouched(_ sender: BlackButton) {
        for button in saveButtons {
            if button == sender {
                button.isEnabled = false
            } else {
                button.isEnabled = true
            }
        }
        if sender.title(for: .normal) == "None" {
            self.saveDCField.text = ""
        }
    }

}
