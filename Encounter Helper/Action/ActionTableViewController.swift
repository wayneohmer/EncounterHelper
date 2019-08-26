//
//  ActionTableViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/19/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class ActionTableViewController: UITableViewController {

    var monster = Monster()
    var titles = ["Actions","Special Abilities","Legondary Actions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 50
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return monster.allActions[section].count > 0 ? 35 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monster.allActions[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
            headerView.textLabel?.textColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell

        cell.nameLabel.text = monster.allActions[indexPath.section][indexPath.row].name
        cell.descriptionLabel.text = monster.allActions[indexPath.section][indexPath.row].desc
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if monster.allActions[indexPath.section][indexPath.row].damage_dice != nil {
            self.performSegue(withIdentifier: "showAttack", sender: monster.allActions[indexPath.section][indexPath.row])
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAttack", let action = sender as? Action, let vc = segue.destination as? DiceController {
            vc.rollName = action.name
            vc.fyreDice = FyreDice()
            vc.fyreDice.dice = [20:1]
            vc.fyreDice.modifier = action.attack_bonus ?? 0
            vc.damageRollName = "\(action.name) Damage"
            if let components = action.damage_dice?.split(separator: "d") {
                vc.damageDice.dice = [Int(components[1]) ?? 0:Int(components[0]) ?? 0]
                vc.damageDice.modifier = action.damage_bonus ?? 0
            }
        }
    }
    
    

}
