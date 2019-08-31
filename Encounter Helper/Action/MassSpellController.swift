//
//  MassSpellController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/26/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class MassSpellController: UIViewController, UITextFieldDelegate {

    var encounter = Encounter()
    var monsterTableVc = MassSpellMonsterController()
    var attribute = Attribute.Strength
    var restoreMonsters = [MonsterModel]()
    var conditionController = ConditionsController()
    
    @IBOutlet weak var damageField: UITextField!
    @IBOutlet weak var halfDamageField: UITextField!
    @IBOutlet weak var dcField: UITextField!
    @IBOutlet weak var rollbutton: BlackButton!
    @IBOutlet weak var DCLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for monster in encounter.monsters {
            self.restoreMonsters.append(monster.monsterModel)
        }
        self.DCLabel.text = attribute.rawValue
        self.dcField.becomeFirstResponder()
    }
    
    @IBAction func donePressed() {
        self.dismiss(animated: true, completion: nil)
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.dcField {
            
            self.damageField.becomeFirstResponder()
        } else if textField == self.damageField {
            if let damage = Int(textField.text ?? "") {
                self.halfDamageField.text = "\(damage/2)"
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func rollTouched() {
        var conditions = Set<String>()
        for (key,item) in conditionController.switchDict {
            if item .isOn {
                conditions.insert(key)
            }
        }
        if let dc = Int(self.dcField.text ?? "") {
            monsterTableVc.rollSave(save: attribute, dc: dc, full: Int(self.damageField.text ?? ""), half: Int(self.halfDamageField.text ?? ""), conditions: conditions)
            if monsterTableVc.selectedIdexes.count > 0 {
                self.rollbutton.isEnabled = true
            }
        }
    }
    
    @IBAction func restoreTouched(_ sender: Any) {
        monsterTableVc.saveidx.removeAll()
        monsterTableVc.failidx.removeAll()
        
        for (idx,model) in restoreMonsters.enumerated() {
            encounter.monsters[idx].restoreWith(model: model)
        }
        monsterTableVc.tableView.reloadData()
        

    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MassSpellMonsterController {
            vc.encounter = self.encounter
            self.monsterTableVc = vc
        } else if let vc = segue.destination as? ConditionsController {
            conditionController = vc
        }
    }

}
