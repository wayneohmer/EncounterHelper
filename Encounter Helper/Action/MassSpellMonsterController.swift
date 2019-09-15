//
//  MassSpellMonsterController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/26/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class MassSpellMonsterController: UITableViewController {

    var encounter = Encounter()
    var saveidx = Set<IndexPath>()
    var failidx = Set<IndexPath>()
    var selectedIdexes = Set<IndexPath>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

    }

    func rollSave(save: Attribute, dc: Int, full: Int?, half: Int?, conditions: Set<String> ) {

        guard let selectedPaths = self.tableView?.indexPathsForSelectedRows else { return }
        saveidx.removeAll()
        failidx.removeAll()
        for idx in selectedPaths {
            let dice = FyreDice()
            dice.dice = [20: 1]
            switch save {
            case .Strength:
                dice.modifier = encounter.monsters[idx.row].strengthSave ?? (encounter.monsters[idx.row].strength - 10) / 2
            case .Dexterity:
                dice.modifier = encounter.monsters[idx.row].dexteritySave ?? (encounter.monsters[idx.row].dexterity - 10) / 2
            case .Constitution:
                dice.modifier = encounter.monsters[idx.row].constitutionSave ?? (encounter.monsters[idx.row].constitution - 10) / 2
            case .Intelligence:
                dice.modifier = encounter.monsters[idx.row].intelligenceSave ?? (encounter.monsters[idx.row].intelligence - 10) / 2
            case .Wisdom:
                dice.modifier = encounter.monsters[idx.row].wisdomSave ?? (encounter.monsters[idx.row].wisdom - 10) / 2
            case .Charisma:
                dice.modifier = encounter.monsters[idx.row].charismaSave ?? (encounter.monsters[idx.row].charisma - 10) / 2
            }
            dice.roll()
            if dice.rollValue > dc {
                saveidx.insert(idx)
                if let half = half {
                    encounter.monsters[idx.row].monsterModel.currentHitPoints! -= half
                }
            } else {
                failidx.insert(idx)
                if let full = full {
                    encounter.monsters[idx.row].monsterModel.currentHitPoints! -= full
                }
                if encounter.monsters[idx.row].monsterModel.conditions == nil {
                    encounter.monsters[idx.row].monsterModel.conditions = conditions
                } else {
                    encounter.monsters[idx.row].monsterModel.conditions?.formUnion(conditions)
                }
            }
        }
        self.tableView.reloadRows(at: selectedPaths, with: .none)
        for indexPath in saveidx.union(failidx) {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.encounter.monsters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonsterEncounterCell", for: indexPath) as! MonsterListCell

        let monster = encounter.monsters[indexPath.row]

        cell.monster = monster
        cell.encounter = encounter
        cell.isEncounter = true
        cell.updateCell()
        cell.addRemoveButton?.tag = indexPath.row

        if saveidx.contains(indexPath) {
            cell.saveLabel?.isHidden = false
            cell.saveLabel?.text = "SAVE"
            cell.saveLabel?.textColor = .green
        } else if failidx.contains(indexPath) {
            cell.saveLabel?.isHidden = false
            cell.saveLabel?.text = "FAIL"
            cell.saveLabel?.textColor = .red

        } else {
            cell.saveLabel?.isHidden = true
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let selectedPaths = self.tableView?.indexPathsForSelectedRows else { return indexPath }

        if selectedPaths.contains(indexPath) {
            self.tableView.deselectRow(at: indexPath, animated: false)
            return nil
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}
