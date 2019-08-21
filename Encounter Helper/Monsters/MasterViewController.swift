//
//  MasterViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var filterdMonsters = [Monster]()
    var encounter = Encounter()
    let searchController = UISearchController(searchResultsController: nil)

    var monsters = [Monster]()
    var isEncounter:Bool { return monsters.count != Monster.sharedMonsters.count }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        Monster.readMonsters()
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Monsters"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.tableView.estimatedRowHeight = 60
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.title = encounter.name
        self.monsters = encounter.monsters
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @IBAction func SaveTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flipTouched(_ sender: Any) {
        monsters = isEncounter ? Monster.sharedMonsters : encounter.monsters
        tableView.reloadData()
    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.monster = isFiltering() ? filterdMonsters[indexPath.row] : monsters[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filterdMonsters.count
        }
        return monsters.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonsterListCell", for: indexPath) as! MonsterListCell

        let monster = isFiltering() ? filterdMonsters[indexPath.row] : monsters[indexPath.row]
        
        cell.monster = monster
        cell.encounter = encounter
        cell.isEncounter = isEncounter
        cell.updateCell()
        cell.addRemoveButton.tag = indexPath.row
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterdMonsters = monsters.filter({( monster:Monster) -> Bool in
            return monster.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @IBAction func tableButtonTouched(_ sender: UIButton) {
        if sender.title(for: .normal) == "+" {
            self.encounter.monsters.append(monsters[sender.tag])
            tableView.reloadRows(at: [IndexPath(item: sender.tag, section: 0)], with: .automatic)
        } else {
            self.encounter.monsters.remove(at: sender.tag)
            self.monsters = self.encounter.monsters
            tableView.deleteRows(at: [IndexPath(item: sender.tag, section: 0)], with: .fade)

        }
    }
    

}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)

    }
}


