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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100

        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
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
                                Encounter.sharedEncounters.append(newEncounter)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Encounter.sharedEncounters.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EncounterCell", for: indexPath) as! EncounterCell

        let encounter = Encounter.sharedEncounters[indexPath.row]
        let exp = encounter.monsters.map({$0.experience}).reduce(0, + )
        cell.nameLabel.text = "\(encounter.name) - \(exp) - \(encounter.totalXP) - \(encounter.threshold) - \(exp/Character.sharedParty.count) per character"
        cell.detailsLabel.text = encounter.details
        cell.editButton.tag = indexPath.row
        cell.encounter = encounter

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openEncounter", sender: Encounter.sharedEncounters[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Encounter.sharedEncounters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
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
                }
            }
            splitViewController.delegate = self
        case "NewEncounter":
            if let vc = segue.destination as? EncounterDetailController {
                vc.parentVc = self
            }
        case "EditEncounter":
            if let vc = segue.destination as? EncounterDetailController, let button = sender as? UIButton {
                vc.parentVc = self
                vc.encounter = Encounter.sharedEncounters[button.tag]
            }

        case "party":
            break
        default:
            break
        }

    }

}
