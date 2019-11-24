//
//  HitPointEditorController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/24/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class HitPointEditorController: UIViewController {

    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var healButton: BlackButton!
    @IBOutlet weak var damageButton: BlackButton!

    var monsterVc = DetailViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.damageButton.color = .red
        self.healButton.color = .blue
        self.hpLabel.layer.cornerRadius = 8

    }

    @IBAction func numTouched(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            self.hpLabel.text = "\(self.hpLabel.text ?? "")\(title)"
        }

    }

    @IBAction func xTouched(_ sender: Any) {
        self.hpLabel.text = ""
    }

    @IBAction func backspaceTouched(_ sender: Any) {
        self.hpLabel.text = String(self.hpLabel.text?.dropLast() ?? "")
    }

    @IBAction func damageTouched(_ sender: BlackButton) {
        guard let monster = monsterVc.monster else { return }
        guard let damage = Int(self.hpLabel.text ?? "") else { return }
        if monster.monsterModel.currentHitPoints == nil {
            if monster.monsterModel.maxHitPoints == nil {
                monster.monsterModel.maxHitPoints = monster.monsterModel.hit_points
            }
            monster.monsterModel.currentHitPoints = monster.monsterModel.maxHitPoints
        }
        if sender.title(for: .normal) == "Heal" {
            if let hp = monster.monsterModel.currentHitPoints {
                monster.monsterModel.currentHitPoints = min(hp + damage, monster.monsterModel.maxHitPoints ?? monster.monsterModel.hit_points)
                self.monsterVc.logMessage(message: "Heal - \(damage)")
            }
        } else {
            monster.monsterModel.currentHitPoints? -= damage
            self.monsterVc.logMessage(message: "Damage - \(damage)")
        }
        self.dismiss(animated: true, completion: {
             self.monsterVc.updateHP()
             self.monsterVc.updateMasterVc()
             self.monsterVc.actionVc.tableView.reloadData()
        })
    }

}
