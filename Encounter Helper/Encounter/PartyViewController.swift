//
//  PartyViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/11/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit
import CloudKit

class PartyViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.isEditing = true

    }

    @IBAction func cloudTouched(_ sender: UIBarButtonItem) {

        let searchPredicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Party", predicate: searchPredicate)
        let container = CKContainer.default()
        let cloudDb = container.publicCloudDatabase

        Character.sharedParty.removeAll()
        cloudDb.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print(error)
            } else {
                if let records = records {
                    for record in records {
                        if let json = record["json"] as? String {
                            let decoder = JSONDecoder()

                            if let character = try? decoder.decode(Character.self, from: json.data(using: .utf8, allowLossyConversion: true) ?? Data()) {
                                Character.sharedParty.append(character)
                            }

                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? Character.sharedParty.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as! CharacterCell

        if indexPath.section == 0 {
            cell.nameField.text = Character.sharedParty[indexPath.row].name
            cell.levelField.text  = "\(Character.sharedParty[indexPath.row].level)"
            cell.acField.text = "\(Character.sharedParty[indexPath.row].armorClass)"
            cell.perceptionField.text = "\(Character.sharedParty[indexPath.row].passivePerception)"
            cell.experiencePointField.text = "\(Character.sharedParty[indexPath.row].experiencePoints)"
            cell.row = indexPath.row
        } else {
            cell.nameField.text = ""
            cell.levelField.text  = ""
            cell.acField.text = ""
            cell.perceptionField.text = ""
            cell.experiencePointField.text = ""

            cell.row = nil
        }
        cell.parent = self

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Character.sharedParty.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.saveParty()
    }

}
