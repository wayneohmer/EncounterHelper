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
    var titles = ["Actions", "Special Abilities", "Legondary Actions", "Reactions", "Log"]
    var monsterVc: DetailViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 50
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
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
            headerView.contentView.backgroundColor = UIColor(red: 45/255, green: 44/255, blue: 44/255, alpha: 1)
            headerView.textLabel?.textAlignment = .center
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.backgroundColor = .clear
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell

        cell.nameLabel.text = monster.allActions[indexPath.section][indexPath.row].name
        cell.descriptionLabel.text = monster.allActions[indexPath.section][indexPath.row].desc
        cell.nameLabel.isHidden = cell.nameLabel.text ?? "" == ""

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if monster.allActions[indexPath.section][indexPath.row].damage_dice != nil {
            self.performSegue(withIdentifier: "showAttack", sender: monster.allActions[indexPath.section][indexPath.row])
        } else if monster.allActions[indexPath.section][indexPath.row].spells != nil {
            self.performSegue(withIdentifier: "showSpells", sender: monster.allActions[indexPath.section][indexPath.row])
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAttack", let action = sender as? Action, let vc = segue.destination as? DiceController {

            vc.popoverPresentationController?.sourceRect = (CGRect(x: self.view.bounds.width/2, y: 250, width: 10, height: 10))
            vc.rollName = action.name
            vc.fyreDice = FyreDice()
            vc.fyreDice.dice = [20: 1]
            vc.fyreDice.modifier = action.attack_bonus ?? 0
            vc.damageRollName = "\(action.name) Damage"
            vc.logManager = self.monsterVc
            let diceComponents = action.damage_dice?.split(separator: "+")
            for diceStr in diceComponents ?? [Substring(action.damage_dice ?? "")] {
                let components = diceStr.split(separator: "d")
                vc.damageDice.add(multipier: Int(components[0].trimmingCharacters(in: .whitespaces)) ?? 0, d: Int(components[1].trimmingCharacters(in: .whitespaces)) ?? 0)
                vc.damageDice.modifier = action.damage_bonus ?? 0
            }
        }
        if segue.identifier == "showSpells", let action = sender as? Action {
            let splitViewController = segue.destination as! UISplitViewController
            splitViewController.preferredPrimaryColumnWidthFraction = 0.25
            var navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-2] as! UINavigationController
            navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-2] as! UINavigationController

            if let vc = navigationController.topViewController as? SpellMasterController {
                vc.spells =  [Spell]()
                for model in action.spells ?? [SpellModel]() {
                    vc.spells.append(Spell(model: model))
                }
            }
            splitViewController.delegate = self
        }
    }

}

extension ActionTableViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? SpellDetailController else { return false }
        if topAsDetailController.spell == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
}
