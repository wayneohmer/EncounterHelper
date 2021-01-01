//
//  EcounTableViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/19/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit
import CloudKit

class EncounterTableViewController: UITableViewController, UISplitViewControllerDelegate {

    var collapsedSections = [String: Bool]()
    var lastGroup = "A"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100

        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    var encounters: [[Encounter]] {
        if Encounter.sharedEncounters.count == 0 {
            return [[Encounter]]()
        }
        //convert dict to array, then sort by key.
        var sortedEncounters = Encounter.sharedEncounters.map({ $0.value }).sorted(by: {  $0.key < $1.key })
        var group = sortedEncounters[0].group
        var returnArray = [[Encounter]]()
        var inner: [Encounter] = [sortedEncounters[0]]
        sortedEncounters.remove(at: 0)
        for encounter in sortedEncounters {
            if encounter.group == group {
                inner.append(encounter)
            } else {
                returnArray.append(inner)
                group = encounter.group
                inner = [encounter]
            }
        }
        returnArray.append(inner)
        return returnArray
    }

    // MARK: - Table view data source

    @IBAction func cloudTouched(_ sender: UIBarButtonItem) {

        let searchPredicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Encounter", predicate: searchPredicate)
        let container = CKContainer.default()
        let cloudDb = container.publicCloudDatabase
        cloudDb.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print(error)
            } else {
                if let records = records {
                    for record in records {
                        if let json = record["json"] as? String {
                            let decoder = JSONDecoder()
                            if let cloundEncounter = try? decoder.decode(CloudEncounter.self, from: json.data(using: .utf8, allowLossyConversion: true) ?? Data()) {
                                let newEncounter = Encounter(cloud: cloundEncounter)
                                Encounter.sharedEncounters[newEncounter.key] = newEncounter

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return encounters.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return encounters[section].count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if collapsedSections[encounters[indexPath.section][indexPath.row].group] ?? false {
            return 0
        }

        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EncounterCell", for: indexPath) as! EncounterCell

        let encounter = encounters[indexPath.section][indexPath.row]
        let exp = encounter.monsters.map({$0.experience}).reduce(0, + )
        if Character.sharedParty.count == 0 {
            cell.nameLabel.text = "\(encounter.name)"
        } else {
            cell.nameLabel.text = "\(encounter.name) - \(exp) - \(encounter.totalXP) - \(encounter.threshold) - \(exp/Character.sharedParty.count) per character"
        }
        cell.nameLabel.textColor = encounter.isCompleted ? .lightGray : .white
        cell.detailsLabel.text = encounter.details
        cell.editButton.tag = indexPath.row
        cell.encounter = encounter
        cell.table = self

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openEncounter", sender: encounters[indexPath.section][indexPath.row])
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            encounters[indexPath.section][indexPath.row].remove()
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .black
            headerView.textLabel?.textAlignment = .center
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.backgroundColor = .clear
            let recog = UITapGestureRecognizer(target: self, action: #selector(collaspeSection(_:)))
            recog.name = self.encounters[section][0].group
            headerView.addGestureRecognizer(recog)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if Character.sharedParty.count == 0 {
            return self.encounters[section][0].group
        } else {
            let sum = self.encounters[section].reduce(0) { sum, encounter in
                sum + encounter.monsters.map({$0.experience}).reduce(0, + )
            }
            return "\(self.encounters[section][0].group) - \(sum/Character.sharedParty.count) per character"
        }
    }

    @objc func collaspeSection(_ sender: UITapGestureRecognizer) {
           self.collapsedSections[sender.name ?? ""] = !(self.collapsedSections[sender.name ?? ""] ?? false)
           var section = 0
           for (idx, array) in encounters.enumerated() {
               if array[0].group == sender.name {
                   section = idx
               }
           }
           self.tableView.reloadSections([section], with: .fade)
       }

    @IBAction func collapseAll(_ sender: Any) {
        for section in encounters {
            self.collapsedSections[section[0].group] = true
        }
        self.tableView.reloadData()
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.monster == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {

        case "openEncounter":
            let splitViewController = segue.destination as! UISplitViewController
            splitViewController.preferredPrimaryColumnWidthFraction = 0.25
            var navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-2] as! UINavigationController

            if let vc = navigationController.topViewController as? MasterViewController {
                if let encounter = sender as? Encounter {
                    vc.encounter = encounter
                    vc.parentVc = self
                    vc.modalPresentationStyle = .fullScreen
                }
            }
            splitViewController.delegate = self
        case "NewEncounter":
            if let vc = segue.destination as? EncounterDetailController {
                vc.parentVc = self
            }
        case "EditEncounter":
            if let vc = segue.destination as? EncounterDetailController {
                vc.parentVc = self
                vc.encounter = sender as? Encounter ?? Encounter()
            }

        case "party":
            break
        default:
            break
        }

    }

}
