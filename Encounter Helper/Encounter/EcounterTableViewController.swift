//
//  EcounTableViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/19/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class EcounterTableViewController: UITableViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        Spell.readSpells()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    @IBAction func plusTouched(_ sender: Any) {
        let alert = UIAlertController(title: "Name", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            let newEncounter = Encounter(name:alert.textFields?[0].text ?? "")
            Encounter.sharedEncounters.append(newEncounter)
            self.performSegue(withIdentifier: "newEncounter", sender: newEncounter)
        })
        self.present(alert, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Encounter.sharedEncounters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EncounterCell", for: indexPath) as! EncounterCell

        let encounter = Encounter.sharedEncounters[indexPath.row]
        cell.nameLabel.text = "\(encounter.name) - \(encounter.monsters.map({$0.experience}).reduce(0, + ))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "newEncounter", sender: Encounter.sharedEncounters[indexPath.row])
    }


    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
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
        
    }

}
